# ESP Touch (Flutter)

While working on a hardware project, I decided to try out the ESP32 platform for my product. I prototyped with the [Particle Photon](https://www.particle.io/), but the platform's monthly charge (for the Particle Cloud) and the fact that they seemed to be abandoning the Photon for the more expensive Argon platform, drove me away. I always wanted to play around with the ESP8266 and even have a few devices laying around, but I never got around to it. The ESP32 looked more capable and were newer, so I decided to give them a try. 

One of the things I quickly learned when I started working with the platform was that it offered an easy way to configure a device's Wi-Fi settings from a mobile app - that seemed cool. The Espressif team (the makers of the ESP32) publish a native sample app for Android and iOS that demonstrates how to use [SmartConfig](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/network/esp_smartconfig.html) and [ESP-Touch](https://www.espressif.com/en/products/software/esp-touch/overview) to get an ESP32 device on a Wi-Fi network. Unfortunately, I planned to use Google's [Flutter](https://flutter.dev/) UI Toolkit for my app and there weren't any full examples for Flutter available online.  

I found the [`esptouch_flutter`](https://pub.dev/packages/esptouch_flutter) plugin which looked helpful but the sample app provided with the plugin was overcomplicated for what I wanted for my app. Buried away in the plugin's source was a simple example that I pulled into a sample app and got working with the complete UI I wanted for my app.  The result is the sample app in this repository (screen shot of the app below).

![Home Page](images/home-page.png)

Let me tell you a bit about the app:

* The app works on Android devices only, I'll explain why in the next bullet.
* The app retrieves the smartphone's Wi-Fi settings using the [Flutter Connectivity](https://pub.dev/packages/connectivity) plugin. Unfortunately, due to some recent security changes Apple made in iOS 13, the Connectivity plugin doesn't work on iOS right now (see this [issue](https://github.com/flutter/flutter/issues/65093) for details). 
* The app uses the Flutter [Permission Handler](https://pub.dev/packages/permission_handler) plugin to prompt Android for permission to access Location information in order for the Flutter Connectivity plugin to obtain Wi-Fi settings for the device running the app. The is required due to some recent security changes in Android, the Flutter Connectivity plugin can't read the device's Wi-Fi settings until the user grants permission and the Connectivity plugin doesn't request the permission (today). 
* The app uses the [ESP Touch Flutter](https://pub.dev/packages/esptouch_flutter) plugin to configure Wi-Fi network settings on a nearby ESP8266 and ESP32 devices.

**Note**: When you look at the app, you'll see that there is some iOS-specific code in there, just ignore it as it just doesn't work right now - I'll update this app when it does.

So, how does this work? 

1. Open the app and make sure the Wi-Fi Network Name (SSID) settings shown at the top of the page is the one you want to configure on Espressif devices. If not, change your device's Wi-Fi settings (connect to the network you want to use) then tap the refresh icon on the toolbar to update the app.
2. Put a nearby Espressif ESP8266 or ESP32 in SmartConfig mode (how you do that it up to you - in my project, I have a button on the board that does that for me). 
3. In the app, tap the **Push Configuration** button to start the configuration process. After anywhere from 10 to 30 seconds, the app should return a success message and update the **IP Address** and **MAC Address** fields with the IP and hardware addresses for the device. 

If you have any questions about this app, create an [issue](https://github.com/johnwargo/esp_touch_flutter/issues) and I'll get back to you as soon as I can.

***

If you find this code useful, and feel like thanking me for providing it, please consider making a purchase from [my Amazon Wish List](https://amzn.com/w/1WI6AAUKPT5P9). You can find information on many different topics on my [personal blog](http://www.johnwargo.com). 