const express = require("express")
const actions = require("../methods/actions")
const router = express.Router()


router.post("/oauth/signup", actions.signUp)
router.post("/oauth/signin", actions.signIn)
router.get("/oauth/getinfo", actions.getInfo)

module.exports = router