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

#import "CloudAuthenticator.h"
#import "GTMOAuth2ViewControllerTouch.h"


@interface CloudAuthenticator()

@property(nonatomic, copy) NSString *keyClientID;
@property(nonatomic, copy) NSString *keyClientSecret;
@property(nonatomic, copy) NSString *keyChainName;

@end


@implementation CloudAuthenticator

- (CloudAuthenticator *)initWithClientID:(NSString *)clientID
                            clientSecret:(NSString *)secret
                         clientChainName:(NSString *)chainName {
  self = [super init];
  if (self) {
    _keyClientID = clientID;
    _keyClientSecret = secret;
    _keyChainName = chainName;
  }

  return self;
}

+ (void)showPopup:(NSString *)title
          message:(NSString *)message
           button:(NSString *)label {
  UIAlertView *popupView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:label
                                            otherButtonTitles:nil];
  [popupView show];
}

- (void)showUserLoginView:(UIViewController *)controller {
  GTMOAuth2ViewControllerTouch *oauthViewController;
  oauthViewController =
      [[GTMOAuth2ViewControllerTouch alloc] initWithScope:@""
                  clientID:self.keyClientID
              clientSecret:self.keyClientSecret
          keychainItemName:self.keyChainName
                  delegate:self
          finishedSelector:@selector(viewController:finishedWithAuth:error:)];

  [controller presentViewController:oauthViewController
                           animated:YES
                         completion:nil];
}

- (void)authenticateUserWithInController:(UIViewController *)controller {
  if (!self.authentication) {
    // Instance doesn't have an authentication object, attempt to fetch from
    // keychain.  This method call always returns an authentication object.
    // If nothing is returned from keychain, this will return an invalid
    // authentication
    self.authentication =
        [GTMOAuth2ViewControllerTouch
            authForGoogleFromKeychainForName:self.keyChainName
                                    clientID:self.keyClientID
                                clientSecret:self.keyClientSecret];
  }

  // Now instance has an authentication object, check if it's valid
  if ([self.authentication canAuthorize]) {
    [self resetAccessTokenForCloudEndpoint];
    NSLog(@"%@", self.authentication);
  } else {
    self.authentication = nil;
    [self showUserLoginView:controller];
  }
}

// Reset access token value for authentication object for cloud endpoint.
- (void)resetAccessTokenForCloudEndpoint {
  GTMOAuth2Authentication *myAuth = self.authentication;
  if (myAuth) {
    self.authentication.authorizationTokenKey = @"id_token";

    // Notify client that user is signed in
    [self.delegate authenticationHelper:self stateChanged:AuthStateSignIn];
  }
}

// Callback method after user finished the login.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)oauthViewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
  [oauthViewController.presentingViewController
      dismissViewControllerAnimated:YES
                         completion:nil];

  if (error) {
    [CloudAuthenticator showPopup:@"Error"
                          message:@"Failed to authenticate user"
                           button:@"OK"];
    NSLog(@"%@", error);
  } else {
    self.authentication = auth;
    [self resetAccessTokenForCloudEndpoint];
    NSLog(@"%@", self.authentication);
  }
}

- (void)signOut {
  [GTMOAuth2ViewControllerTouch
      removeAuthFromKeychainForName:self.keyChainName];
  [GTMOAuth2ViewControllerTouch
      revokeTokenForGoogleAuthentication:self.authentication];

  // Notify client that user is signed out
  [self.delegate authenticationHelper:self stateChanged:AuthStateSignOut];
}

@end
