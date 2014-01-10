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

#import "CloudEntity.h"
#import "CloudMessagingManager.h"
#import "CloudNotificationHandler.h"
#import "CloudFilter.h"
#import "GTLMobilebackendQueryDto.h"
#import "GTLQueryMobilebackend.h"

@interface CloudMessagingManager() {
  // Dictionary which can only be accessed via topicHandlerDictionary
  // method.
  // Key is topic as NSString, object is handler as
  // CloudEntityCollectionQueryCompletion.
  NSMutableDictionary *_topicHandlerDictionary;
  // Local plist location
  NSString *_localPlistLocation;
}
@end


@implementation CloudMessagingManager

NSString *const kCloudMessagingManagerKindName = @"_CloudMessages";
NSString *const kCloudMessagingPropTopicID = @"topicId";
NSString *const kCloudMessagingPropMessage = @"message";
NSString *const kCloudMessagingPropDuration = @"duration";
NSString *const kCloudMessagingManagerTopicIDBroadcast = @"_broadcast";
NSString *const kCloudMessagingPrefKeyPrefixMsgTimestamp =
    @"PREF_KEY_PREFIX_MSG_TIMESTAMP";

// Subscription for Cloud Message will not expire by default
static const int kCloudMessagingSubscriptionDuration = 0;
// Max number of past messages to receive
static const int kCloudMessagingDefaultMaxMessagesToReceive = 100;
static CloudMessagingManager *singleton;

+ (CloudMessagingManager *)sharedInstance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    singleton = [[CloudMessagingManager alloc] init];
  });

  return singleton;
}

- (id)init {
  self = [super init];
  _topicHandlerDictionary = [NSMutableDictionary dictionary];

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
  NSString *documentsDirectory = [paths lastObject];
  NSString *name = @"com.google.cloudmessages.plist";
  _localPlistLocation =
      [documentsDirectory stringByAppendingPathComponent:name];

  return self;
}

- (NSMutableDictionary *)topicHandlerDictionary {
  return _topicHandlerDictionary;
}

// Return the location of .plist file
- (NSString *)plistLocation {
  return _localPlistLocation;
}

// Refresh an internal dictionary representation of the application .plist file
- (NSDictionary *)plistDictionary {
  NSString *location = [self plistLocation];
  return [[NSDictionary alloc] initWithContentsOfFile:location];
}

// Write local data value to plist file
- (void)writeLocalDataWithKey:(NSString *)key
                         date:(NSDate *)value {
  NSMutableDictionary *dictionary = [[self plistDictionary] mutableCopy];

  if (!dictionary) {
    dictionary = [[NSMutableDictionary alloc] init];
  }

  dictionary[key] = value;
  NSString *location = [self plistLocation];
  NSLog(@"Write %@ to %@", dictionary, location);
  [dictionary writeToFile:location atomically:YES];
}

#pragma mark - Interface methods

// This callback method will be called after subscribe is called and list
// collection is completed.
- (void)listCollectionCompletedWithArray:(NSArray *)returnedArray
                                   error:(NSError *)error {
  // If no messages returned from the backend, do nothing
  if ([returnedArray count] == 0) {
    return;
  }

  // Find out the latest message and store the timestamp locally
  CloudEntity *lastMessage = [returnedArray objectAtIndex:0];
  NSString *topicID =
      [lastMessage.properties objectForKey:kCloudMessagingPropTopicID];
  [self writeLocalDataWithKey:topicID date:lastMessage.createdAtUTC ];

  // Get the callback for the returned array of CloudEntity during subscribe
  CloudEntityCollectionQueryCompletion block =
      self.topicHandlerDictionary[topicID];

  if (!block) {
    return;
  }

  // Renew the subscription to receive new messages from now
  NSNumber *max = @(kCloudMessagingDefaultMaxMessagesToReceive);
  GTLMobilebackendQueryDto *newQueryDto =
      [self queryForCloudMessageForTopic:topicID
                       maxOfflineMessage:max];

  CloudEntityCollection *entityCollection =
      [CloudEntityCollection sharedInstance];
  CloudNotificationHandler *handler =
      entityCollection.topicHandlerDictionary[topicID];
  CloudNotificationHandler *newHandler =
      [[CloudNotificationHandler alloc] init];
  newHandler.query = newQueryDto; // use the new query
  newHandler.callback = handler.callback; // reuse the callback

  entityCollection.topicHandlerDictionary[topicID] = newHandler;

  // Finally call the callback to deal with the CloudEntityCollection
  block(returnedArray, error);
}

- (CloudEntity *)createCloudMessage:(NSString *)topicID {
  NSDictionary *properties = @{kCloudMessagingPropTopicID: topicID};

  CloudEntity *entity =
      [CloudEntity entityWithKind:kCloudMessagingManagerKindName
                       properties:properties];
  return entity;
}

- (CloudEntity *)createBroadcastMessage {
  return [self createCloudMessage:kCloudMessagingManagerTopicIDBroadcast];
}

- (void)sendMessage:(CloudEntity *)message {
  [message insertInstanceWithCallback:^(CloudEntity *entity, NSError *error) {
    if (error) {
      NSLog(@"%@", error);
    }
  }];
}

- (void)sendMessage:(CloudEntity *)message
           onFinish:(CloudEntityQueryCompletionCallback)completionHandler {
  [message insertInstanceWithCallback:completionHandler];
}

- (void)subscribe:(NSString *)topicID
    maxOfflineMessage:(int)max
            onReceive:(CloudEntityCollectionQueryCompletion)completionHandler {
  // Register the list callback for this topicID, so it can be called
  // after this call back
  self.topicHandlerDictionary[topicID] = completionHandler;

  // List message with a callback
  max = MAX(0, max);
  GTLMobilebackendQueryDto *queryDto =
      [self queryForCloudMessageForTopic:topicID maxOfflineMessage:max];

  // Get a list of messages
  CloudEntityCollection *entityCollection =
      [CloudEntityCollection sharedInstance];
  [entityCollection listCollectionWithQuery:queryDto
      callback:^(NSArray *entities, NSError *error) {
          [self listCollectionCompletedWithArray:entities error:error];
      }];
}

- (void)unsubscribe:(NSString *)topicID {
  [self.topicHandlerDictionary delete:topicID];

  CloudEntityCollection *entityCollection =
      [CloudEntityCollection sharedInstance];
  [[entityCollection topicHandlerDictionary] delete:topicID];
}

#pragma mark - Internal methods

// Create pref key for local data storage
- (NSString *)prefKeyForTopic:(NSString *)topicID {
  return [NSString stringWithFormat:@"%@:%@",
      kCloudMessagingPrefKeyPrefixMsgTimestamp, topicID];
}

// Return queryDto for querying cloud message for a specific topic
- (GTLMobilebackendQueryDto *)queryForCloudMessageForTopic:(NSString *)topicID
                                         maxOfflineMessage:(int)max {
  BOOL includeOfflineMessage = max > 0;

  // Figure out the last read message. By default, it's current time
  NSDate *lastTime = [NSDate date];

  if (includeOfflineMessage) {
    NSString *key = [self prefKeyForTopic:topicID];
    NSString *localValue = self.plistDictionary[key];

    // Only change lastTime if local value exists
    if (localValue) {
      NSTimeInterval interval = [localValue doubleValue];
      lastTime = [NSDate dateWithTimeIntervalSince1970:interval];
    }

    NSLog(@"Last message read timestamp: %@", lastTime);
  }

  GTLMobilebackendQueryDto *queryDto = [[GTLMobilebackendQueryDto alloc] init];

  // Set entity kind name
  queryDto.kindName = kCloudMessagingManagerKindName;

  // Set filters
  CloudFilter *topicFilter =
      [CloudFilter cloudFilterEq:kCloudMessagingPropTopicID
                           value:topicID];
  CloudFilter *lastMessageFilter =
      [CloudFilter cloudFilterGt:kCloudEntityFieldNameCreatedAt value:lastTime];
  CloudFilter *combinedFilter =
      [CloudFilter cloudFilterAndFilters:topicFilter, lastMessageFilter, nil];
  [queryDto setFilterDto:combinedFilter.filterDto];

  // Set sorting
  [queryDto setSortedPropertyName:kCloudEntityFieldNameCreatedAt];
  [queryDto setSortAscending:NO]; // desc order

  // Set subscription duration
  [queryDto setSubscriptionDurationSec:
      [NSNumber numberWithInt:kCloudMessagingSubscriptionDuration]];

  // Set limit and scope
  if (includeOfflineMessage) {
    [queryDto setLimit:@(max)];
    [queryDto setScope:kCloudEntityScopeFutureAndPast];
  } else {
    [queryDto setLimit:
        [NSNumber numberWithInt:kCloudMessagingDefaultMaxMessagesToReceive]];
    [queryDto setScope:kCloudEntityScopeFuture];
  }

  // Future cloud entity was received in the form of queryID i.e. topicID via
  // push notification.  Once the notification is received, it is dispatched
  // to CloudEntityCollection to list Cloud Entity.  The corresponding
  // callback will be triggered based on the topicCallbackDictionary in
  // CloudEntityCollection.

  // Set query id
  [queryDto setQueryId:topicID];
  return queryDto;
}

@end
