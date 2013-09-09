# Mobile Backend Starter iOS Client

## Copyright
Copyright 2013 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Disclaimer
This sample application is not an official Google product.

## Support Platform and Versions
This sample source code and project is designed to work with XCode 4.6.  The resulted application is tested on iOS 6.1 and iPhone 5.

## Overview
This iOS client is designed to work with Mobile Backend Starter backend.

## Download Instruction
Download this sample code from [Google Cloud Platform Github](https://github.com/GoogleCloudPlatform/solutions-mobile-backend-starter-ios-client).

## Developer Guide
This section provides a step-by-step guide so you can get the sample up and running in Xcode.

### Prerequisite
1. Download and install [Xcode 4.6](https://developer.apple.com/xcode/) on your Mac computer if you don't have it installed.

2. Download the Mobile Backend Starter [backend](https://github.com/GoogleCloudPlatform/solutions-mobile-backend-starter-java).

3. You have a valid SSL certiciate that is APNS enabled (for the Java backend), a corresponding Provisioning Profile installed on your Mac computer.  Otherwise, please follow the [Apple documentation](http://developer.apple.com/library/mac/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW1) to obtain them.

   If you do have a push notification certificate installed prior on your machine.  You can follow these steps to export the \*.p12 file for step 5 below:
      * Open KeyChain Access
      * Browse `My Certificates` under category on the left
      * Expand the `push certificate`
      * Select both the push certificate and key
      * Right click and choose to export 2 items
      * Set a password on the certificate

4. Follow the Mobile Backend Starter README.md and deploy the Mobile Backend Starter to App Engine.

5. Navigate to the Mobile Backend Starter configuration page i.e. *https://your_app_id.appspot.com/admin/configure.jsp* to register iOS Client ID by setting the Authentication/Authorization option to "Secured by Client IDs".  Take a note of this Client ID which will be reentered on the iOS client side.  Next, enable *Google Cloud Messaging and iOS Push Notification* and provide the `APNS Provider Certification Password`.  At last, click *Select APNS Certificate and Save* to upload the \*.p12 certificate and finally save the configuration.

6. You have an iPhone, that is provisioned for development and runs iOS version 6.1.

### Set up Xcode Project

#### Open CloudBackendIOSClient.xcodeproj in Xcode
1. Open a new Finder window and navigate to the directory you extract the sample client code.  Double click on the ClientBackendIOSClient.xcodeproj file. It will open the project in Xcode automatically.

#### Rename the bundle ID
1. The iOS client application bundle ID has to match the one you used for creating the SSL certificate and the Provisioning Profile.  Out-of-the-box bundle ID is `com.google.CloudPushSample.dev`.  Please rename the bundle ID accordingly via project TARGETS in Xcode.

#### Update the Client ID, Client Secret and Service URL
1. Fill in the kCloudBackendClientID and kCloudBackendClientSecret values in Constants.m.  The kCloudBackendClientID has to match with the Client ID you used in the backend as described in step 5 of the Prerequisite.  The kCloudBackendClientSecret is the matching client secret for the Client ID from [API Console](https://code.google.com/apis/console).
2. Replace *{{{ INSERT APP ID }}}* in the kCloudBackendServiceURL variable in Constants.m with the App Engine Application id where the Mobile Backend Starter is deployed to.

#### Update the Code Signing Certificate
1. Click on the project in the Ffile Browser panel
2. Click on the project in the Settings browser
3. Click on the Build Settings tab
4. Browse down to Code Signing Identity
5. Select a valid code signing certificate (APNS enabled provisioning profile)

### Build and Execute Mobile Backend Starter iOS Client
1. On the top left corner of the toolbar, select `[Your bundle ID] > iOS Device`.  Then click the `Run` button to execute the application.
2. The application should open up in your iPhone.

### Testing the Backend and iOS Client Altogether
1. If this is the first time the CloudBackendIOSClient app executes, a Google login page may show up asking for your credential and your consent to identify your account.  Go ahead and sign in.
2. Click on the the "+" sign on the top right corner and enter a message. Hit *return* will save the input.
3. The Guestbook should refresh and show the latest message.  You can also use the pull down gesture to refresh the list manually.  Note that each time when there is a new message or update sent to the backend, this application will be notified by push notification which triggers this application to query against the backend.  You can test this by entering a new message and immediately hitting the *home* key to navigate away from this application.  Within seconds, you will receive a push notification alerting you that a message is received.  When you navigate back to the application, you will see the latest message being queried and displayed.
4. Repeat step 2 a few times. You should see a list of messages displayed in reverse chronological order.
5. If you have a few Android or iOS devices, register them to the same Mobile Backend Starter backend, you can then use this application to communicate among multiple devices.
6. Open any browser and navigate to the [Mobile Backend Starter configuration page](https://your\_app\_id.appspot.com/admin/configure.jsp).  In the *Send Cloud Message* section, click *Send*.  Your phone will then receive a push notification which alerts the Guestbook to display an alert.  This alert will display the broadcast message as specified and dismiss automatically based on the duration value.