# Blue Iris PiCamMonitor

View an ip camera feed on RPi 3B+ triggered by BI alert. A stand alone PiCamMonitor.

# Installation

### HARDWARE:

* Raspberry Pi 3 B+
* 5.2 vdc 3 amp power supply, I've found the 2.5 amp to be too weak to power the Pi and screen.
* 16 - 32 GB micro sd card
* Official Raspberry Pi 7" touch screen 
* SmartiPi Touch Case* - https://smarticase.com available on Amazon.com

### OPTIONAL:

* Piezo buzzer - https://www.amazon.com/Cylewet-Mainboard-Computer-Internal-Speaker/dp/B01MR1A4NV/ref=sr_1_1_sspa?s=electronics&ie=UTF8&qid=1550533551&sr=1-1-spons&keywords=piezo+buzzer&psc=1 I realize there are 10, but they are cheap and once you get one of these running, you may just want a few more. This connects to GPIO pins 9 thru 15 with the black wire on pin 9. https://pinout.xyz
* Heatsinks - 

Assemble the Smarti Pi case, screen and raspberry pi, instructions and video here - https://smarticase.com/products/smartipi-touch .

Download the full version of Raspbian Stretch with Desktop and recommended software found here - https://www.raspberrypi.org/downloads/raspbian/ .
Extract the files.

Using Etcher (Mac) https://www.balena.io/etcher/ , or
Win32DiskManager (PC) https://sourceforge.net/projects/win32diskimager/ , image the micro sd card.
After imaging, insert the sd card into the pi, replace the cover, plug in a usb mouse and keyboard and power up. The mouse and keyboard are only needed for the initial set-up.

You will be presented with the Welcome screen.

Follow the promts to set up your device, connect to your wifi and then update the software. (This will take a while) (If you encounter an error before the updates start just click Back and start again, it happens.)

While you wait for the Pi to update, you may want VNC viewer installed on your main computer. https://www.realvnc.com/en/connect/download/viewer/ You might find it useful to install the VNC viewer on an iPad or other tablet.

When the updates have been installed, click OK and then reboot. Click the raspberry in the top left corner and select Preferences/Raspberry Pi Configuration.

On the first page select Wait for Network. Select Interfaces tab and check SSH and VNC enable. Select Performance tab and change the GPU memory to 256. Click OK then YES to reboot.

Set a static ip address. Depending on your system there are various way to achieve this. On the Pi itself, open the terminal window and enter 'sudo nano /etc/dhcpcd.conf' , hit enter and scroll to the bottom.

Enter (editing the ip numbers to match your network configuration, eth0=wired, wlan0=wireless):

    interface eth0

    static ip_address=192.168.0.10/24
    static routers=192.168.0.1
    static domain_name_servers=192.168.0.1
    
    interface wlan0
    
    static ip_address=192.168.0.200/24
    static routers=192.168.0.1
    static domain_name_servers=192.168.0.1

Exit the editor, press ctrl+x, press the letter 'Y' then enter. Note your ip address and 
type 'sudo reboot' and hit enter for the changes to take affect. 
You can now move to VNC, ssh or continue with the mouse and keyboard.

Next we need to stop the screen from blanking after 10 minutes. In the terminal enter 'sudo apt-get install xscreensaver' then hit enter. Once all the files are installed and you are back to the prompt, type 'sudo reboot' and hit enter. When the Pi is back up to the desktop select the raspberry/Preferences/Screensaver and set the Mode: to Disable Screen Saver and close the window. Now the screen should stay on like we want.

Set up Samba so you can transfer your pictures, in the terminal enter 'sudo apt-get install samba samba-common-bin' and hit enter. Back at the prompt enter: 'sudo nano /etc/samba/smb.conf' and hit enter. Scroll to the very bottom and enter:

    [global]

    workgroup = workgroup 
    server string = %h  
    wins support = no
    dns proxy = no
    security = user
    map to guest = Bad User
    encrypt passwords = yes
    panic action = /usr/share/samba/panic-action %d
  

    [Home]

    comment = Home Directory
    path = /home/pi
    browseable = yes
    writeable = yes
    guest ok = yes
    read only = no
    force user = root
  
Again, press ctrl+x hit 'Y' then enter to save the file. Enter: 'sudo samba restart' enter for the changes to take effect. When you connect from your computer, log in as guest and copy your pictures to the appropriate folder under the Pictures folder.
  
Two more quick installs and we are ready for Polyglot.
* Install screen: sudo apt-get install screen
* Install feh: sudo apt-get install feh

# Camera Feeds and Paths

With high resolution cameras you will use the sub stream, the higher resolutions will not play properly. Log into your camera through a web brower and make sure your sub stream is enabled, set to 640x480 and the highest frame rate. Set the key frame to twice the max frame rate. This will make your streams load faster.

A lower resolution camera like the Foscam C1, which is still 720p can be streamed from the main feed.

A typical path to the sub feed of a high quality camera. (Amcrest and others in the range)\(PLEASE NOTE the backslash between the 1 and the &, this is a requirement if there is an ampersand in your path)

    rtsp://user:password@192.192.192.195:544/cam/realmonitor?chanel=1\&subtype=1 


A typical path to the main stream on lower end camera such as a Foscam C1.

    rtsp://user:password@192.192.192.192:544/videoMain 


You can search the web for the settings to reach your particular camera.

#### Test your camera feed paths on the Pi using this command line edited with your information:

    sh -c 'omxplayer --win "0 0 800 480" rtsp://USERNAME:PWORD@172.16.2.110:554/cam/realmonitor?channel=1\&subtype=1; exec bash'
This will run the sub stream on an Amcrest and most other high resolution cameras. If you are successful, save your feed path for use in the custom configuration parameters. Use ctrl+c to stop the player.

#### Install the files:

* In terminal: git clone https://github.com/markv58/BlueIris-PiCam.git

* cd BlueIris-PiCam

* chmod +x install.sh

* ./install.sh

After the reboot you will need to edit any start files you will use with your camera feeds. You can also adjust the screen brightness. All of the files are in the /home/pi/cgi-bin folder. There are copies in the BlueIris-PiCam directory if you need to replace one in the cgi-bin directory, just be sure to 'chmod +x <file name>' after you copy one.

The echo 130 | sudo tee /sys/class/backlight/rpi_backlight/brightness line is the brightness level 0 - 255

After editing, a reboot will refresh everything and is recommended.

This is the Camera1start file:

    #!/bin/bash

    echo 1 | sudo tee /sys/class/backlight/rpi_backlight/bl_power
    sudo pkill feh
    sudo killall omxplayer.bin
    screen -X -S stream1 quit
    screen -dmS stream1 sh -c 'omxplayer --win "0 0 800 480" rtsp://user:password@192.192.192.120:554/cam/realmonitor?channel=1\&subtype=1 -b --live; exec bash'
    /home/pi/cgi-bin/./2tone
    echo 130 | sudo tee /sys/class/backlight/rpi_backlight/brightness
    sleep 1s
    echo 0 | sudo tee /sys/class/backlight/rpi_backlight/bl_power



#### Triggering with Blue Iris

* Camera Properties
* Alerts
* Post to a web address or MQTT server
* Configure

Use http://.  In the top it will be something like this:

    <ip of the Pi>:6502/cgi-bin/<file with start at the end>
    
In the bottom it will be something like this:

    <ip of the Pi>:6502/cgi-bin/<file with stop at the end>
    
The files that start with PF are for the Picture Frame option. It will display any files in the /home/pi/Pictures folder.    
