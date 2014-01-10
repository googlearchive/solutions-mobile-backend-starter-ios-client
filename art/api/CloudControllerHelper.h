/* Copyright (c) 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "CloudAuthenticatorDelegate.h"
#import "CloudBackendIOSClientAppDelegate.h"
#import "CloudControllerDelegate.h"
#import "CloudEntityCollection.h"
#import "GTLMobilebackend.h"

// Notification name to notify receiving device token from APNS.
extern NSString *const kCloudControllerDeviceTokenNotification;

// Provides built-in user authentication, push notification registration, and
// broadcasting functionality in a UIViewController.
// Any application client desires these functionalities can instantiate this
// class and implement CloudControllerDelegate protocol.
@interface CloudControllerHelper : NSObject<CloudAuthenticatorDelegate>

// Reference to the application
@property(nonatomic, retain) CloudBackendIOSClientAppDelegate *appDelegate;
// Reference to mobile backend service.
@property(nonatomic, strong, readonly) GTLServiceMobilebackend *cloudEndpointService;

// Start common services for the application (i.e. Authentication service,
// Cloud endpoint service, APNS etc).
- (void)startCommonServices;

// New init method to initialize values needed for this class.
- (id)initWithClientID:(NSString *)clientID
                secret:(NSString *)clientSecret
             chainName:(NSString *)chainName
            serviceURL:(NSString *)serviceURL
              delegate:(id<CloudControllerDelegate>)delegate;

// List collection of data with the provided kind.
- (void)listCollectionWithKind:(NSString *)kind
                     pastScope:(BOOL)pastScope
              completionHandle:(CloudEntityCollectionQueryCompletion)block;

// Allow client to sign in.
- (void)signIn;

// Allow client to sign out.
- (void)signOut;

@end
