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

#import "CloudBackendIOSClientAppDelegate.h"
#import "CloudEntity.h"
#import "CloudEntityCollection.h"
#import "CloudNotificationHandler.h"
#import "GTLQueryMobilebackend.h"
#import "GTLMobilebackendQueryDto+Helper.h"

@interface CloudEntityCollection() {
  // Dictionary which can only be accessed via topicHandlerDictionary method.
  // Key is topic as NSString, object is handler as CloudNotificationHandler.
  NSMutableDictionary *_topicHandlerDictionary;
  GTLServiceMobilebackend *_cloudEndpointService;
  CloudBackendIOSClientAppDelegate *_appDelegate;
}
@end


@implementation CloudEntityCollection

// Match with the Java backend prefix
NSString const *kCloudEntityCollectionIOSDevicePrefix = @"ios_";
static CloudEntityCollection *singleton;

+ (CloudEntityCollection *)sharedInstance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    singleton = [[CloudEntityCollection alloc] init];
  });

  return singleton;
}

- (id)init {
  self = [super init];
  if (self) {
    UIResponder <UIApplicationDelegate> *myDelegate =
        [[UIApplication sharedApplication] delegate];
    _appDelegate = (CloudBackendIOSClientAppDelegate *) myDelegate;
    _topicHandlerDictionary = [NSMutableDictionary dictionary];
  }

  return self;
}

#pragma mark - Public methods

- (void)setCloudEndpointService:(GTLServiceMobilebackend *)service {
  _cloudEndpointService = service;
}

- (NSMutableDictionary *)topicHandlerDictionary {
  return _topicHandlerDictionary;
}

// Called by application delegate didReceiveRemoteNotification method when
// push notification is received.
- (void)handlePushNotificationWithTopicID:(NSString *)topicID {
  // Retrieve the callback handler corresponding to the topicID
  CloudNotificationHandler *handler = self.topicHandlerDictionary[topicID];

  if (!handler) {
    NSLog(@"The client does not have a handler registered for topicID: %@",
        topicID);
    return;
  }

  // Execute the query based on the handler information
  [self listCollectionWithQuery:handler.query callback:handler.callback];
}

- (void)listCollectionWithQuery:(GTLMobilebackendQueryDto *)cbQuery
                       callback:(CloudEntityCollectionQueryCompletion)block {
  // If this is a continuous query, clone the query and put it in the
  // dictionary.
  // When a push notification comes in with the queryID i.e. topicID in future,
  // the push notification handler method will look up the handler for this
  // specific topicID.  The handler's query will then be executed along with the
  // handler's query callback.  This is how this application obtains
  // "Future" messages.
  // Push notification from APNS is received at application delegate's
  // didReceiveRemoteNotification method
  if ([cbQuery isContinuousQuery]) {
    GTLMobilebackendQueryDto *newQueryDto = [cbQuery copy];

    // If this is a continuous query, clone a PAST query so that no
    // more Prospective Search API subscription will be made on the server
    // side.  When notification regarding to this TopicID being received in the
    // future, a PAST query will be executed instead of a FUTURE one.
    newQueryDto.scope = kCloudEntityScopePast;

    [cbQuery setDefaultQueryIDIfNeeded];
    NSString *topicID = cbQuery.queryId;
    NSAssert(topicID, @"TopicID is nil");

    CloudNotificationHandler *handler =
        [[CloudNotificationHandler alloc] init];
    handler.callback = block;
    handler.query = newQueryDto;

    self.topicHandlerDictionary[topicID] = handler;
  }

  // Add the device's token to regId field of the current query
  CloudBackendIOSClientAppDelegate *myApp = [self appDelegate];
  NSAssert([myApp.tokenString length], @"Device token is invalid");
  cbQuery.regId = [kCloudEntityCollectionIOSDevicePrefix
                      stringByAppendingString:myApp.tokenString];

  // Finally execute the current query to get a collection of Cloud Entities
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1ListWithObject:cbQuery];

  GTLServiceMobilebackend *service = [self cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityListDto *object,
                          NSError *error) {
          [self executeWithArray:object.entries
                     requestType:@"LIST ALL"
                           error:error
                        callback:block];
      }];
}

- (void)listCollectionWithKind:(NSString *)name
                         scope:(NSString *)scopeName
                      callback:(CloudEntityCollectionQueryCompletion)block {
  [self listCollectionWithKind:name
              totalResultLimit:100
                 sortAscending:NO
                        sortBy:kCloudEntityFieldNameUpdatedAt
                         scope:scopeName
                      callback:block];
}

- (void)listCollectionWithKind:(NSString *)name
              totalResultLimit:(NSInteger)limit
                 sortAscending:(BOOL)isAscending
                        sortBy:(NSString *)propertyName
                         scope:(NSString *)scopeName
                      callback:(CloudEntityCollectionQueryCompletion)block {
  GTLMobilebackendQueryDto *cloudBackendQuery =
      [GTLMobilebackendQueryDto object];
  cloudBackendQuery.limit = [NSNumber numberWithInteger:limit];
  cloudBackendQuery.kindName = name;
  cloudBackendQuery.sortAscending = @(isAscending);
  cloudBackendQuery.sortedPropertyName = propertyName;
  cloudBackendQuery.scope = scopeName;

  [self listCollectionWithQuery:cloudBackendQuery callback:block];
}

- (void)insertCollectionWithArray:(NSArray *)entities
                         callback:(CloudEntityCollectionQueryCompletion)block {
  GTLMobilebackendEntityListDto *list =
      [self convertToGTLMobileBackendEntityListDto:entities];
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1InsertAllWithObject:list];

  GTLServiceMobilebackend *service = [self cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityListDto *object,
                          NSError *error) {
          [self executeWithArray:object.entries
                     requestType:@"INSERT ALL"
                           error:error
                        callback:block];
      }];
}

- (void)removeCollectionWithArray:(NSArray *)entities
                         callback:(CloudEntityCollectionQueryCompletion)block {
  GTLMobilebackendEntityListDto *list =
      [self convertToGTLMobileBackendEntityListDto:entities];
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1DeleteAllWithObject:list];

  GTLServiceMobilebackend *service = [self cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityListDto *object,
                          NSError *error) {
          [self executeWithArray:object.entries
                     requestType:@"REMOVE ALL"
                           error:error
                        callback:block];
      }];
}

- (void)putCollectionWithArray:(NSArray *)entities
                      callback:(CloudEntityCollectionQueryCompletion)block {
  GTLMobilebackendEntityListDto *list =
      [self convertToGTLMobileBackendEntityListDto:entities];
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1UpdateAllWithObject:list];

  GTLServiceMobilebackend *service =[self cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityListDto *object,
                          NSError *error) {
          [self executeWithArray:object.entries
                     requestType:@"UPDATE ALL"
                           error:error
                        callback:block];
      }];
}

- (void)fetchCollectionWithIDArray:(NSArray *)IDArray
                          kindName:(NSString *)name
                          callback:(CloudEntityCollectionQueryCompletion)block {
  // Create a GTLCbDtoList from ID array
  GTLMobilebackendEntityListDto *list =
      [self convertIDArrayToGTLMobilebackendEntityListDto:IDArray
                                                 kindName:name];

  // Execute query
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1GetAllWithObject:list];

  GTLServiceMobilebackend *service = [self cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityListDto *object,
                          NSError *error) {
          [self executeWithArray:object.entries
                     requestType:@"GET ALL"
                           error:error
                        callback:block];
      }];
}

#pragma mark - Private methods

- (void)executeWithArray:(NSArray *)array
             requestType:(NSString *)requestType
                   error:(NSError *)error
                callback:(CloudEntityCollectionQueryCompletion)block {
  if (error) {
    NSLog(@"%@ Error: %@", requestType, error);
  } else {
    NSLog(@"%@: %@", requestType, array);
  }

  if (block) {
    NSArray *cloudEntityArray = [self convertToCloudEntityArray:array];
    block(cloudEntityArray, error);
  }
}

- (GTLMobilebackendEntityListDto *)convertIDArrayToGTLMobilebackendEntityListDto:(NSArray *)IDArray
    kindName:(NSString *)name {
  GTLMobilebackendEntityListDto *list = [GTLMobilebackendEntityListDto object];
  NSMutableArray *entriesArray = [NSMutableArray array];

  GTLMobilebackendEntityDto *record = nil;
  for (NSString *identifier in IDArray) {
    record = [GTLMobilebackendEntityDto object];
    record.identifier = identifier;
    record.kindName = name;

    [entriesArray addObject:record];
  }

  list.entries = entriesArray;
  return list;
}

// Input array of CloudEntity
- (GTLMobilebackendEntityListDto *)convertToGTLMobileBackendEntityListDto:(NSArray *)array {
  // Key-value coding
  NSArray *returnArray = [array valueForKey:@"innerObject"];

  GTLMobilebackendEntityListDto *list =
      [[GTLMobilebackendEntityListDto alloc] init];
  list.entries = returnArray;
  return list;
}

// Input array of GTLMobilebackendEntityDto
- (NSArray *)convertToCloudEntityArray:(NSArray *)array {
  NSMutableArray *resultArray = [NSMutableArray array];

  CloudEntity *entity = nil;
  for (GTLMobilebackendEntityDto *object in array) {
    entity = [CloudEntity entityWithRawObject:object];
    [resultArray addObject:entity];
  }

  return resultArray;
}

#pragma mark - Private methods

- (GTLServiceMobilebackend *)cloudEndpointService {
  NSAssert(_cloudEndpointService != nil,
           @"cloudEndpointService not initialized");
  return _cloudEndpointService;
}

- (CloudBackendIOSClientAppDelegate *)appDelegate {
  return _appDelegate;
}

@end
