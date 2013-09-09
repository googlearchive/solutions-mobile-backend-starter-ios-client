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
#import "GTMOAuth2Authentication.h"

// Simplifies UIViewController's handling of the lifecycle of user
// signin, signoff and the storage and refreshment of user OAuth token.
// UIVewController that uses this helper class needs to implement the
// CloudAuthenticationDelegate protocol.
@interface CloudAuthenticator : NSObject

@property(nonatomic, strong) GTMOAuth2Authentication *authentication;
@property(nonatomic, weak) id<CloudAuthenticatorDelegate> delegate;

// Public constructor that allows caller to provide needed information
// for authenticating with cloud backend server.
- (CloudAuthenticator *)initWithClientID:(NSString *)clientID
                            clientSecret:(NSString *)secret
                         clientChainName:(NSString *)chainName;

// Kick off authenticate user process.
- (void)authenticateUserWithInController:(UIViewController *)controller;

// Signing user out and revoke token.
- (void)signOut;

@end
