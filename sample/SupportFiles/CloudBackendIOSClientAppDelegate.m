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

#include <TargetConditionals.h>

#import "CloudBackendIOSClientAppDelegate.h"
#import "CloudEntityCollection.h"
#import "CloudControllerHelper.h"


@implementation CloudBackendIOSClientAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if (TARGET_IPHONE_SIMULATOR)
  NSLog(@"This application uses the push notification functionality. %@",
        @"It has to be executed on a physical device instead of a simulator.");

  return NO;
#endif

  // Register for push notification
  UIRemoteNotificationType types =
      (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];

  return YES;
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString *token = [self hexStringFromData:deviceToken];
  NSLog(@"content---%@", token);

  // Save the token
  self.tokenString = token;

  // Notify controller that device token is received
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kCloudControllerDeviceTokenNotification
                    object:self];
}

// Returns an NSString object that contains a hexadecimal representation of the
// receiver’s contents.
- (NSString *)hexStringFromData:(NSData *)data {
  NSUInteger dataLength = [data length];
  NSMutableString *stringBuffer =
      [NSMutableString stringWithCapacity:dataLength * 2];
  const unsigned char *dataBuffer = [data bytes];
  for (int i=0; i<dataLength; i++) {
    [stringBuffer appendFormat:@"%02x", (NSUInteger)dataBuffer[i]];
  }

  return stringBuffer;
}

- (void)application:(UIApplication *)app
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  NSLog(@"%@", err);
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"Alert: %@", userInfo);

  NSString *message = userInfo[@"hiddenMessage"];
  // message is in the format of "<regId>:query:<clientSubId>" based on the
  // backend
  NSArray *tokens = [message componentsSeparatedByString:@":"];

  // Tokens are not expected, do nothing
  if ([tokens count] != 3) {
    NSLog(@"Message doesn't conform to the subId format at the backend: %@",
          message);
    return;
  }

  // Token type isn't "query", do nothing
  if (![tokens[1] isEqual: @"query"]) {
    NSLog(@"Message is not in type QUERY: %@", message);
    return;
  }

  // Handle this push notification based on this topicID
  NSString *topicID = tokens[2]; // clientSubId
  CloudEntityCollection *entityCollection =
      [CloudEntityCollection sharedInstance];
  [entityCollection handlePushNotificationWithTopicID:topicID];
}

@end
