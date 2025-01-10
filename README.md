# iosHeartkitDemo

An iOS/iPadOS application to display data collected by the HeartKit application (https://github.com/kchen3157/heartkit) for Ambiq Apollo 4 Blue Plus MCUs.

The HeartKit application will take in ECG data and send it over BLE to the iOS/iPadOS application. The EVB will then analyze the data locally using a heart rhythm inference model. Data can be collected either through an external sensor connected to the EVB, or through a test stimulus dataset stored in the application.

Xcode 15 and iOS/iPadOS 17 or later are required to build and run this project. The UI is optimized for portrait mode.


## Features:
* Realtime display of ECG data direct from sensor.
* Analysis display on completion of HeartKit inference:
  * Heart Rhythm Type (Normal, Bradycardia, Tachycardia, Arrhythmia)
  * Average Heart Rate
  * Graph of Beat Type analysis (NSR, PAC, PVC)
* EVB disconnection/reconnection handling.


## Requirements:
* Xcode 15 to build project.
* iPhone/iPad running iOS/iPadOS 17 or later
* Ambiq Apollo 4 Blue Plus EVB
* (Optional) Max86150_breakout board from Protocentral connected via Qwiic.


## Usage:
See https://github.com/kchen3157/heartkit for detailed instructions on how to setup heartkit on EVB. Use [web_ble](https://github.com/kchen3157/heartkit/tree/web_ble) branch for best results.
1. Build and deploy iosHeartkitDemo project onto device running iOS/iPadOS 17 or later.
2. Press RST button on EVB to initialize HK application.
3. Press the blue "Start Scan" button to connect to EVB.
4. "Connected" should show up on BLE Status. Press either BTN0 to use external sensor data or BTN1 to use test stimulus data.
5. ECG data should display on the top graph. After inference is complete, analysis of the data will be displayed onscreen.

## Screenshots:

Normal Rhythm              |  Tachycardia Rhythm
:-------------------------:|:-------------------------:
![](https://github.com/kchen3157/iosHeartkitDemo/blob/main/ss_1.jpg?raw=true)  |  ![](https://github.com/kchen3157/iosHeartkitDemo/blob/main/ss_2.jpg?raw=true)
