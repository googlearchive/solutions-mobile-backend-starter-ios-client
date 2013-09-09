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

#import "GTLMobilebackendEntityListDto.h"
#import "GTLMobilebackendQueryDto.h"
#import "GTLServiceMobilebackend.h"

typedef void(^CloudEntityCollectionQueryCompletion)(NSArray *, NSError *);
extern const NSString *kCloudEntityCollectionIOSDevicePrefix;

// Singleton class wraps around GTLCloudBackendEntityListDto. Provide methods
// to send listAll, getAll, insertAll, putAll and deleteAll requests to the
// cloud backend.  It also contains continuous query logic to coordinate
// callback actions for subscribed queries.
@interface CloudEntityCollection : NSObject

// Shared instance for GTMObject Singleton Boilerplate
+ (CloudEntityCollection *)sharedInstance;

// Bind cloud endpoint service to all CloudEntityCollection instances.
- (void)setCloudEndpointService:(GTLServiceMobilebackend *)service;

// Return a dictionary that maps a subscribed topic to its handler/callback.
// Key is subscription id as NSString, object is handler/callback as
// CloudNotificationHandler.
- (NSMutableDictionary *)topicHandlerDictionary;

// Handle dispatched push notification for a specific topicID by triggering
// corresponding handlers and/or callbacks.
- (void)handlePushNotificationWithTopicID:(NSString *)topicID;

// Retreive a collection of cloud entity from the backend based on the input
// cbQuery requirement.  If the retrieval is successful, caller can manipulate
// the returned ClounEntityCollection in the callback block.
- (void)listCollectionWithQuery:(GTLMobilebackendQueryDto *)cbQuery
                       callback:(CloudEntityCollectionQueryCompletion)block;

// Retreive a collection of cloud entity based on kind name.  By default, it
// returns top 100 items in descending order based on "updatedAt" field.
- (void)listCollectionWithKind:(NSString *)name
                         scope:(NSString *)scopeName
                      callback:(CloudEntityCollectionQueryCompletion)block;

// Retreive a collection of cloud entity based on kind name, limit, sort order,
// sort property name and scope.
- (void)listCollectionWithKind:(NSString *)name
              totalResultLimit:(NSInteger)limit
                 sortAscending:(BOOL)isAscending
                        sortBy:(NSString *)propertyName
                         scope:(NSString *)scopeName
                      callback:(CloudEntityCollectionQueryCompletion)block;

// Send insertAll request to cloud backend to bulk insert a list of cloud
// entities.  All input entities items should be in CloudEntity type.
// If the retrieval is successful, caller can manipulate the
// returned ClounEntityCollection in the callback block
- (void)insertCollectionWithArray:(NSArray *)entities
                         callback:(CloudEntityCollectionQueryCompletion)block ;

// Send deleteAll request to cloud backend to bulk delete a list of cloud
// entities.  All input entities items should be in CloudEntity type.
// If the retrieval is successful, caller can manipulate the
// returned ClounEntityCollection in the callback block
- (void)removeCollectionWithArray:(NSArray *)entities
                         callback:(CloudEntityCollectionQueryCompletion)block;

// Send updateAll request to cloud backend to bulk update a list of cloud
// entities.  All input entities items should be in CloudEntity type.
// If the retrieval is successful, caller can manipulate the
// returned ClounEntityCollection in the callback block
- (void)putCollectionWithArray:(NSArray *)entities
                      callback:(CloudEntityCollectionQueryCompletion)block;

// Send getAll request to cloud backend to bulk get a list of cloud entities.
// All input IDArray item should be in NSString type and share the same
// kindName. If the retrieval is successful, caller can manipulate the
// returned ClounEntityCollection in the callback block
- (void)fetchCollectionWithIDArray:(NSArray *)IDArray
                          kindName:(NSString *)name
                          callback:(CloudEntityCollectionQueryCompletion)block;

@end
