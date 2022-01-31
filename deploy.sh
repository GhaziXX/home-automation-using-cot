#/bin/bash

#Ensure we remove the old folder
sudo rm -r api
echo "Folder removed"
#Clone the repo
git clone https://github.com/GhaziXX/home-automation-using-cot.git /home/ghazi_tounsi/api
echo "Repo cloned succesfully"
# copy the .env file
cp /home/ghazi_tounsi/.env api/api/
echo "Environment variabls files copied succesfully"
# move to the api directory
cd api/api
echo "I am in the Api directory"
#run npm install
npm install
echo "Packages installed successfully"
# Ensure that nothing uses the https port
sudo systemctl stop nginx
# Run the server
sudo /home/ghazi_tounsi/.nvm/versions/node/v16.13.0/bin/node main/launch.js
