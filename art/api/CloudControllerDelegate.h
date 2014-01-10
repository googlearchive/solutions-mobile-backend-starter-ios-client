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

@class CloudControllerHelper;

@protocol CloudControllerDelegate <NSObject>

// Client class must define how to handle user sign in.
- (void)signInWithCloudControllerHelper:(CloudControllerHelper *)controllerHelper;

// Client class must define how to handle user sign out.
- (void)signOutWithCloudControllerHelper:(CloudControllerHelper *)controllerHelper;

// Client class must register for receiving
// kCloudControllerDeviceTokenNotification before this method is called.
- (void)handleDeviceTokenNotification:(NSNotification *)notification
                       userAuthorized:(BOOL)authorized;

// Client class must provides a reference to a view controller where
// CloudControllerHelper can delegate the authentication login dialog
// to be presented at.
- (UIViewController *)presentingViewController;

// Display a standard alert style popup for current view. If duration provided
// is greater than 0, no buttons will be displayed so the popup will be
// dismissed after the specified duration.
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               buttonLabel:(NSString *)label
               forDuration:(NSTimeInterval)seconds;

@optional

// Optional implementation if client wishes to handle broadcast messages
// directly. If this method is implemented, then the default
// CloudControllerHelper broadcast message handling will not be executed.
- (void)onReceiveBroadcastMessage:(NSArray *)entities
                            error:(NSError *)error;

@end
