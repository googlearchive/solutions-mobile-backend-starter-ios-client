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
#import "CloudControllerHelper.h"
#import "CloudEntity.h"
#import "CloudEntityCollection.h"
#import "CloudMessagingManager.h"
#import "EditModeUITextView.h"
#import "GTMHTTPFetcherLogging.h"

NSString *const kCloudControllerDeviceTokenNotification =
    @"deviceTokenNotification";

@interface CloudControllerHelper()
@property(nonatomic, weak) id<CloudControllerDelegate> delegate;
@end


@implementation CloudControllerHelper {
  CloudAuthenticator *_authenticator;
  CloudEntityCollection *_entityCollection;
  GTLServiceMobilebackend *_cloudEndpointService;

  // Track future query being sent once per kind to the backend, such that it
  // avoid resetting the expiration in Prospective Search. Key is kind type as
  // NSString, value is BOOL.
  NSMutableDictionary *_futureQuerySentDict;
  NSString *_clientID;
  NSString *_clientSecret;
  NSString *_chainName;
  NSString *_serviceURL;
  BOOL _isSubscribe; // broadcast subscription only once per instance
}

// Strings for checking sample users have changed the value in Constant.m
static NSString *kCloudControllerClientIDFiller = @"{{{ INSERT ID }}}";
static NSString *kCloudControllerClientSecretFiller = @"{{{ INSERT SECRET }}}";
static NSString *kCloudControllerServiceURLFiller = @"{{{ INSERT APP ID }}}";
static const int kCloudControllerOfflineMessageMax = 50;

#pragma mark - Instance methods

- (void)startCommonServices {
  // Turn on loggings and register custom class for the framework
#if (TARGET_IPHONE_SIMULATOR)
  NSLog(@"This application runs on physical device only.");
  return;
#endif

#if DEBUG
  [GTMHTTPFetcher setLoggingEnabled:YES];
#endif

  [self assertClientInfo];

  // Register notification center to receive notification when device token
  // is available
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(handleDeviceTokenNotification:)
             name:kCloudControllerDeviceTokenNotification
           object:nil];

  // Set cloud endpoint service URL if overrided via constant
  if (_serviceURL) {
    self.cloudEndpointService.rpcURL = [NSURL URLWithString:_serviceURL];
  }

  // Delegate cloud entity endpoint service interaction to CloudEntity and
  // CloudEntityCollection
  _entityCollection = [CloudEntityCollection sharedInstance];
  [CloudEntity setCloudEndpointService:self.cloudEndpointService];
  [_entityCollection setCloudEndpointService:self.cloudEndpointService];

  // Delegate the authentication flow to CloudAuthenticationHelper, but
  // this class implements CloudAuthenticationDelegate so that
  // CloudAuthenticationHelper can callback for actions after authentciation
  // is completed.
  _authenticator = [[CloudAuthenticator alloc] initWithClientID:_clientID
                                                   clientSecret:_clientSecret
                                                clientChainName:_chainName];
  _authenticator.delegate = self;

  // This will eventually call authenticationComplete selector
  UIViewController *controller = [_delegate presentingViewController];
  [_authenticator authenticateUserWithInController:controller];
}

- (id)init {
  NSString *msg = @"Use initWithClientID:secret:chainName:serviceURL instead";
  [NSException raise:@"Not implemented method"
              format:@"%@", msg];

  return nil;
}

- (id)initWithClientID:(NSString *)clientID
                secret:(NSString *)clientSecret
             chainName:(NSString *)chainName
            serviceURL:(NSString *)serviceURL
              delegate:(id<CloudControllerDelegate>)delegate {
  self = [super init];

  _clientID = clientID;
  _clientSecret = clientSecret;
  _chainName = chainName;
  _serviceURL = serviceURL;
  _isSubscribe = NO;
  _futureQuerySentDict = [NSMutableDictionary dictionary];
  _delegate = delegate;
  _appDelegate =
      (CloudBackendIOSClientAppDelegate *)
          [[UIApplication sharedApplication] delegate];

  return self;
}

- (GTLServiceMobilebackend *)cloudEndpointService {
  if (!_cloudEndpointService) {
    _cloudEndpointService = [[GTLServiceMobilebackend alloc] init];

    _cloudEndpointService.retryEnabled = YES;
    _cloudEndpointService.shouldFetchNextPages = YES;
  }

  return _cloudEndpointService;
}

- (void)signIn {
  UIViewController *controller = [_delegate presentingViewController];
  [_authenticator authenticateUserWithInController:controller];
}

- (void)signOut {
  [_authenticator signOut];
}

// Ensure sample user defines client id and secret.
- (void)assertClientInfo {
  NSUInteger identity =
      [_clientID rangeOfString:kCloudControllerClientIDFiller].location;

  NSAssert(identity == NSNotFound, @"Client ID not found in Constants.m");

  NSUInteger secret =
      [_clientSecret rangeOfString:kCloudControllerClientSecretFiller].location;
  NSAssert(secret == NSNotFound,
           @"Client Secret not found in Constants.m");

  NSUInteger url =
      [_serviceURL rangeOfString:kCloudControllerServiceURLFiller].location;
  NSAssert(url == NSNotFound,
           @"Service URL is not completed in Constants.m");
}

#pragma mark - Broadcast functionality

- (void)subscribeToBroadcastMessage {
  // Subscribe broadcasting messages
  if (!_isSubscribe) {
    CloudMessagingManager *messageManager =
        [CloudMessagingManager sharedInstance];

    [messageManager subscribe:kCloudMessagingManagerTopicIDBroadcast
            maxOfflineMessage:@(kCloudControllerOfflineMessageMax)
                    onReceive:^(NSArray *entities, NSError *error) {
                        [self onReceiveBroadcastMessage:entities
                                                  error:error];
                    }];

    _isSubscribe = YES;
  };
}

- (void)onReceiveBroadcastMessage:(NSArray *)entities
                            error:(NSError *)error {
  if (error) {
    NSLog(@"%@", error);
  }
  else {
    SEL method = @selector(onReceiveBroadcastMessage:error:);

    // If the client defines the method to handle broadcast messages, delegate
    // the responsiblity to the client.
    if ([_delegate respondsToSelector:method]) {
      [_delegate onReceiveBroadcastMessage:entities error:error];

    } else {
      // Otherwise, execute the default broadcast messages
      // handling (i.e. show auto-dismissed alert for each message)
      BOOL firstEntity = YES;
      int accumulatedDelay = 0;
      for(GTLMobilebackendEntityDto *messageEntity in entities) {
        NSMutableDictionary *property = messageEntity.properties;

        // Show the first toaster right away
        if (firstEntity) {
          [self showPopupAsychronously:property];
          firstEntity = NO;
        } else {
          // Subsequent toaster needs to pace accordingly
          [self performSelector:@selector(showPopupAsychronously:)
                     withObject:property
                     afterDelay:accumulatedDelay];
        }

        accumulatedDelay += [property[kCloudMessagingPropDuration] intValue];
      }
    }
  }
}

- (void)showPopupAsychronously:(NSDictionary *)property {
  NSString *message = [property objectForKey:kCloudMessagingPropMessage];
  NSNumber *number = [property objectForKey:kCloudMessagingPropDuration];

  [_delegate showAlertWithTitle:@"Broadcast Message"
                            message:message
                        buttonLabel:nil
                        forDuration:[number doubleValue]];
}

#pragma mark - Cloud authentication delegate

- (void)authenticationHelper:(CloudAuthenticator *)cloudAuthenticator
                stateChanged:(AuthState)state {
  switch (state) {
    case AuthStateSignIn:
      [self signInWithCloudControllerHelper:self];
      break;

    case AuthStateSignOut:
      [self signOutWithCloudControllerHelper:self];
      break;

    default:
      NSLog(@"Authentication state is invalid");
  }
}

- (void)signInWithCloudControllerHelper:(CloudControllerHelper *)controllerHelper {
  [_cloudEndpointService setAuthorizer:_authenticator.authentication];

  // At this point, we subscribe to boardcast messages if device token exists
  if (self.appDelegate.tokenString) {
    [self subscribeToBroadcastMessage];
  }

  [_delegate signInWithCloudControllerHelper:self];
}

- (void)signOutWithCloudControllerHelper:(CloudControllerHelper *)controllerHelper {
  [_delegate signOutWithCloudControllerHelper:self];
}

// Wait for signal from the app delegate for the device token being received
- (void)handleDeviceTokenNotification:(NSNotification *)notification {
  NSString *name = notification.name;
  NSAssert([name isEqualToString:kCloudControllerDeviceTokenNotification],
           @"Notification name, %@, is not expected", name);

  [self subscribeToBroadcastMessage];

  BOOL authorized = [_authenticator.authentication canAuthorize];
  [_delegate handleDeviceTokenNotification:notification
                            userAuthorized:authorized];
}

#pragma mark - CloudBackend model

// Issue cloud backend service call to get a list of messages manually.
// Pass in YES if it's manually refresh; NO if it's automatic.
- (void)listCollectionWithKind:(NSString *)kind
                     pastScope:(BOOL)pastScope
              completionHandle:(CloudEntityCollectionQueryCompletion)block  {
  BOOL isFutureQuerySent =
      [NSNumber numberWithBool:_futureQuerySentDict[kind]].boolValue;

  if (isFutureQuerySent || pastScope) {
    // Subsequent time should sent the past query only
    [_entityCollection listCollectionWithKind:kind
                                        scope:kCloudEntityScopePast
                                     callback:^(NSArray *array,
                                                NSError *error) {
                                         block(array, error);
                                     }];
  }
  else {
    // First time sending future query
    [_entityCollection listCollectionWithKind:kind
                                        scope:kCloudEntityScopeFutureAndPast
                                     callback:^(NSArray *array,
                                                NSError *error) {
                                            // Only set the flag if there is no
                                             // error returned for listing
                                         if (!error) {
                                           _futureQuerySentDict[kind] = @(YES);
                                         }
                                         block(array, error);
                                     }];
  }
}

@end
