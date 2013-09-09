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

#import "GTLMobileBackendEntityDto.h"
#import "GTLServiceMobilebackend.h"

@class CloudEntity;

typedef void (^CloudEntityQueryCompletionCallback)(CloudEntity *, NSError *);

// Wraps around GTLCbDto object and provides methods to send create, update and
// delete requests to cloud backend.
@interface CloudEntity : NSObject

// Generic id used for a Cloud Entity instance if an identifier was not defined.
// Caller can use this value to check if an Cloud Entity instance has ID
// defined.
extern NSString *const kCloudEntityGenericID;

// Field names correspond directly to the backend attribute names, which are
// handy for formulating a GTLCbQuery or GTLCbFilter
extern NSString *const kCloudEntityFieldNameUpdatedBy;
extern NSString *const kCloudEntityFieldNameCreatedBy;
extern NSString *const kCloudEntityFieldNameUpdatedAt;
extern NSString *const kCloudEntityFieldNameCreatedAt;
extern NSString *const kCloudEntityFieldNameIdentity;
extern NSString *const kCloudEntityFieldNameOwner;
extern NSString *const kCloudEntityFieldNameKindName;
extern NSString *const kCloudEntityFieldNameProperties;

extern NSString *const kCloudEntityScopePast;
extern NSString *const kCloudEntityScopeFuture;
extern NSString *const kCloudEntityScopeFutureAndPast;

// Read and write properties
@property(nonatomic, copy) NSString *kindName;
@property(nonatomic) NSMutableDictionary *properties;

// Read only properties
@property(nonatomic, readonly, copy) NSString *updatedBy;
@property(nonatomic, readonly, copy) NSString *createdBy;
@property(nonatomic, readonly, copy) NSString *owner;
@property(nonatomic, readonly, copy) NSString *identifier;
@property(nonatomic, readonly, strong) NSDate *updatedAtUTC;
@property(nonatomic, readonly, strong) NSDate *createdAtUTC;
@property(nonatomic, readonly, copy) NSString *localizedUpdatedAt;
@property(nonatomic, readonly, copy) NSString *localizedCreatedAt;
@property(nonatomic, readonly, strong) GTLMobilebackendEntityDto *innerObject;

// Instantiate a CloudEntity object with kindName and properties.
+ (CloudEntity *)entityWithKind:(NSString *)kindName
                     properties:(NSDictionary *)properties;

// Instantiate a CloudEntity object with the native object.
+ (CloudEntity *)entityWithRawObject:(GTLMobilebackendEntityDto *)rawObject;

// Bind cloud endpoint service for all CloudEntity instances.
+ (void)setCloudEndpointService:(GTLServiceMobilebackend *)service;

// Delete a cloud instance in the cloud backend with the provided identifier and
// kindName.  Caller to define callback block with cloud entity and error
// response objects as input from the cloud backend server.
+ (void)removeInstanceWithIdentifier:(NSString *)identifier
                            kindName:(NSString *)name
                           indexPath:(NSIndexPath *)indexPath
                            callback:(CloudEntityQueryCompletionCallback)block;

// Retrieve a CloudEntity based on the ID and kindName from the backend.
// Caller to define callback block with cloud entity and error
// response objects as input from the cloud backend server.
+ (void)fetchInstanceWithIdentifier:(NSString *)identifier
                           kindName:(NSString *)name
                           callback:(CloudEntityQueryCompletionCallback)block;

// Convert UTC time datetime to local time zone date time.
+ (NSString *)localDateTimeStringFromUTC:(NSDate *)datetime;

// Insert this instance via the cloud backend.  Caller to define callback block
// with cloud entity and error response objects as input from the cloud backend
// server.
- (void)insertInstanceWithCallback:(CloudEntityQueryCompletionCallback)block;

// Update this instance via the cloud backend. Caller to define callback block
// with cloud entity and error response objects as input from the cloud backend
// server.
- (void)putInstanceAtIndexPath:(NSIndexPath *)indexPath
                      callback:(CloudEntityQueryCompletionCallback)block;

// Delete this instance via the cloud backend. Caller to define callback block
// with cloud entity and error response objects as input from the cloud backend
// server.
- (void)removeInstanceAtIndexPath:(NSIndexPath *)indexPath
                         callback:(CloudEntityQueryCompletionCallback)block;

@end
