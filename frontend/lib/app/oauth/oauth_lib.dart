import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pkce/pkce.dart';
import 'package:random_string/random_string.dart';

typedef OAuthTokenExtractor = OAuthToken Function(Response response);
typedef OAuthTokenValidator = Future<bool> Function(OAuthToken token);

class OAuthException extends Error {
  final String code;
  final String message;

  OAuthException(this.code, this.message) : super();

  @override
  String toString() => 'OAuthException: [$code] $message';
}

/// Interceptor to send the bearer access token and update the access token when needed
class BearerInterceptor extends Interceptor {
  OAuth oauth;

  BearerInterceptor({required this.oauth});

  /// Add Bearer token to Authorization Header
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handle) async {
    final token = await oauth.fetchOrRefreshAccessToken().catchError((err) {
      return null;
    });

    if (token != null) {
      options.headers.addAll({"authorization": "Bearer ${token.accessToken}"});
    }

    return handle.next(options);
  }
}

/// Use to implement a custom grantType
abstract class OAuthGrantType {
  RequestOptions handle(RequestOptions request);
}

/// Obtain an access token using a username and password
class PasswordGrant extends OAuthGrantType {
  final String email;
  final String password;

  PasswordGrant({this.email = '', this.password = ''});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    request.data = {"email": email, "password": password};

    return request;
  }
}

/// Obtain an access token using an refresh token
class RefreshTokenGrant extends OAuthGrantType {
  String refreshToken;
  String oldToken;

  RefreshTokenGrant({required this.oldToken, required this.refreshToken});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    request.data = {"refresh_token": refreshToken};
    request.headers = {"authorization": "Bearer $oldToken"};
    return request;
  }
}

/// Use to implement custom token storage
abstract class OAuthStorage {
  /// Read token
  Future<OAuthToken?> fetch();

  /// Save Token
  Future<OAuthToken> save(OAuthToken token);

  /// Clear token
  Future<void> clear();
}

/// Save Token in secure storage
class OAuthSecureStorage extends OAuthStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String accessTokenKey = 'accessToken';
  final String refreshTokenKey = 'refreshToken';
  final String expiration = 'expiration';

  @override
  Future<OAuthToken> fetch() async {
    String? expire = await storage.read(key: expiration);
    return OAuthToken(
        accessToken: await storage.read(key: accessTokenKey),
        refreshToken: await storage.read(key: refreshTokenKey),
        expiration: expire);
  }

  @override
  Future<OAuthToken> save(OAuthToken token) async {
    await storage.write(key: accessTokenKey, value: token.accessToken);
    await storage.write(key: refreshTokenKey, value: token.refreshToken);
    await storage.write(key: expiration, value: token.expiration.toString());
    return token;
  }

  @override
  Future<void> clear() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);
  }
}

/// Token
class OAuthToken {
  OAuthToken({this.accessToken, this.refreshToken, this.expiration});

  final String? accessToken;
  final String? refreshToken;
  final String? expiration;

  bool get isExpired =>
      expiration != null && DateTime.now().isAfter(DateTime.parse(expiration!));

  factory OAuthToken.fromMap(Map<String, dynamic> map) {
    return OAuthToken(
        accessToken: map['accessToken'],
        refreshToken: map['refreshToken'],
        expiration: map["expiration"]);
  }

  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiration': expiration,
      };

  @override
  String toString() {
    return 'OAuthToken{\naccess_token:$accessToken,\nrefresh_token:$refreshToken,\nexpires_in:$expiration';
  }
}

/// Encode String To Base64
Codec<String, String> stringToBase64 = utf8.fuse(base64);

/// OAuth Client
class OAuth {
  String preLoginUrl;
  String loginUrl;
  String tokenUrl;
  String refreshUrl;
  Dio dio;
  OAuthStorage storage;
  OAuthTokenExtractor extractor;
  OAuthTokenValidator validator;
  OAuth({
    required this.preLoginUrl,
    required this.loginUrl,
    required this.tokenUrl,
    required this.refreshUrl,
    Dio? dio,
    OAuthStorage? storage,
    OAuthTokenExtractor? extractor,
    OAuthTokenValidator? validator,
  })  : dio = dio ?? Dio(),
        storage = storage ?? OAuthSecureStorage(),
        extractor = extractor ?? ((res) => OAuthToken.fromMap(res.data)),
        validator = validator ?? ((token) => Future.value(!token.isExpired));

  final pkcePair = PkcePair.generate(stripTrailingPadding: true);

  Future<OAuthToken> requestTokenAndSave(OAuthGrantType grantType) async {
    return requestToken(grantType).then((token) => storage.save(token));
  }

  Future<OAuthToken> refreshTokenAndSave(OAuthGrantType grantType) async {
    return refreshToken(grantType).then((token) {
      return storage.save(token);
    });
  }

  Future<OAuthToken> refreshToken(OAuthGrantType grantType) {
    final request = grantType.handle(
      RequestOptions(
          method: 'POST', path: '/', contentType: 'application/json'),
    );
    return dio
        .request(refreshUrl,
            data: request.data,
            options: Options(
                contentType: request.contentType,
                headers: request.headers,
                method: request.method))
        .then((token) {
      return OAuthToken(
          accessToken: token.data["access_token"],
          refreshToken: request.data["refresh_token"],
          expiration: token.data["expiration"]);
    });
  }

  Future<String> requestLoginId() {
    final codeChallenge = pkcePair.codeChallenge;
    final clientId = randomAlphaNumeric(10);
    final encoded =
        base64Url.encode(utf8.encode(clientId + "#" + codeChallenge));
    final request = RequestOptions(
      method: 'POST',
      path: '/',
      contentType: 'application/json',
      headers: {"Pre-Authorization": "Bearer $encoded"},
    );

    return dio
        .request(preLoginUrl,
            options: Options(
                contentType: request.contentType,
                headers: request.headers,
                method: request.method))
        .then((value) {
      return value.data["message"]["loginId"];
    });
  }

  Future<String> requestAuthCode(OAuthGrantType grantType) {
    final request = grantType.handle(
      RequestOptions(
        method: 'POST',
        path: '/',
        contentType: 'application/json',
      ),
    );
    return requestLoginId().then((value) {
      request.data["loginId"] = value;
      return dio
          .request(loginUrl,
              data: request.data,
              options: Options(
                  contentType: request.contentType,
                  headers: request.headers,
                  method: request.method))
          .then((value) {
        return value.data["authorizationCode"];
      });
    });
  }

  /// Request a new Access Token using a strategy
  Future<OAuthToken> requestToken(OAuthGrantType grantType) {
    final codeVerifier = pkcePair.codeVerifier;
    return requestAuthCode(grantType).then((value) {
      String bearer = base64Url.encode(utf8.encode(value + "#" + codeVerifier));
      final request = RequestOptions(
        method: 'POST',
        path: '/',
        contentType: 'application/json',
        headers: {"Post-Authorization": "Bearer $bearer"},
      );

      return dio
          .request(tokenUrl,
              options: Options(
                  contentType: request.contentType,
                  headers: request.headers,
                  method: request.method))
          .then((value) {
        return extractor(value);
      });
    });
  }

  /// return current access token or refresh
  Future<OAuthToken?> fetchOrRefreshAccessToken() async {
    OAuthToken? token = await storage.fetch();

    if (token?.accessToken == null) {
      throw OAuthException('missing_refresh_token', 'Missing refresh token!');
    }

    if (await validator(token!)) return token;

    return refreshAccessToken();
  }

  /// Refresh Access Token
  Future<OAuthToken> refreshAccessToken() async {
    OAuthToken? token = await storage.fetch();

    if (token?.refreshToken == null) {
      throw OAuthException('missing_refresh_token', 'Missing refresh token!');
    }

    return refreshTokenAndSave(RefreshTokenGrant(
        oldToken: token!.accessToken!, refreshToken: token.refreshToken!));
  }
}

class OAuthSettings {
  final OAuth _oauth = OAuth(
    tokenUrl: 'https://api.homeautomationcot.me/oauth/token',
    refreshUrl: 'https://api.homeautomationcot.me/oauth/refresh',
    loginUrl: 'https://api.homeautomationcot.me/oauth/signin',
    preLoginUrl: 'https://api.homeautomationcot.me/oauth/presignin',
    storage: OAuthSecureStorage(),
  );
  final Dio _auth = Dio();
  OAuth get oauth {
    return _oauth;
  }

  Dio get authenticatedDio {
    _auth.interceptors.add(BearerInterceptor(oauth: oauth));
    return _auth;
  }
}
