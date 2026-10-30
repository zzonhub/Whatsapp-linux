# Whatsapp-linux
A bash script that prepares a ready to execute wrapper for WhatsApp web using Firefox profiling on Linux systems.

the script is lightweight and easy to modify. and it don't have unnecessary files that consume system space.

it does not consume extra ram (you don't need to launch an extra wrapper or kiosk application). it is purely working on Firefox browser( with a seperate session).

steps to launch the script

download the WhatsApp.sh file
change its permissions 

chmod +x whatsapp.sh 

run the script

bash whatsapp.sh

the script check for Firefox and then clones it's default .profile into an other profile. this keeps the custom profile a system comparable and reduces the further conflicts. 

this custom profile keeps the WhatsApp session data seperate and independent of firefox normal usuage.

the script prepares a ready to use whatsapp.desktop

if ever what to delete your profile and every thing simply run the cmd.

rm -rf ~/.config/mozilla/whatsapp
rm -rf /usr/local/bin/whatsapp

it erases everything.

if anyone feels the script is not good. they can use chrome's single cmd

google-chrome --user-data-dir="$HOME/.config/chrome-whatsapp" --app="[https://web.whatsapp.com](https://web.whatsapp.com)" &

Google made that for Linux users to give an app like experience. you can replace the WhatsApp address link with your custom site address to launch it.
