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
#import "GTLQueryMobilebackend.h"


@implementation CloudEntity

NSString *const kCloudEntityGenericID = @"myID";
NSString *const kCloudEntityFieldNameUpdatedBy = @"_updatedBy";
NSString *const kCloudEntityFieldNameCreatedBy = @"_createdBy";
NSString *const kCloudEntityFieldNameUpdatedAt = @"_updatedAt";
NSString *const kCloudEntityFieldNameCreatedAt = @"_createdAt";
NSString *const kCloudEntityFieldNameIdentity = @"ID";
NSString *const kCloudEntityFieldNameOwner = @"_owner";
NSString *const kCloudEntityFieldNameKindName = @"_kindName";
NSString *const kCloudEntityFieldNameProperties = @"properties";

NSString *const kCloudEntityScopePast = @"PAST";
NSString *const kCloudEntityScopeFuture = @"FUTURE";
NSString *const kCloudEntityScopeFutureAndPast = @"FUTURE_AND_PAST";

static GTLServiceMobilebackend *gCloudEndpointService;

@synthesize innerObject = _innerObject;

- (CloudEntity *)initWithObject:(GTLMobilebackendEntityDto *)object {
  self = [super init];
  if (self) {
    _innerObject = object;
  }

  return self;
}

- (void)setKindName:(NSString *)string {
  _innerObject.kindName = string;
}

- (NSString *)kindName {
  return _innerObject.kindName;
}

- (void)setProperties:(NSDictionary *)dictionary {
  _innerObject.properties = [dictionary mutableCopy];
  [_innerObject setJSONValue:dictionary forKey:kCloudEntityFieldNameProperties];
}

- (NSMutableDictionary *)properties {
  return [_innerObject JSONValueForKey:kCloudEntityFieldNameProperties];
}

- (NSString *)updatedBy {
  return _innerObject.updatedBy;
}

- (NSString *)createdBy {
  return _innerObject.createdBy;
}

- (NSString *)owner {
  return _innerObject.owner;
}

- (NSString *)identifier {
  // Make sure identifier always return a string
  NSString *identifier = _innerObject.identifier;
  return identifier ? identifier : kCloudEntityGenericID;
}

- (NSDate *)updatedAtUTC {
  return _innerObject.updatedAt.date;
}

- (NSDate *)createdAtUTC {
  return _innerObject.createdAt.date;
}

- (NSString *)localizedUpdatedAt {
  return [CloudEntity localDateTimeStringFromUTC:self.updatedAtUTC];
}

- (NSString *)localizedCreatedAt {
  return [CloudEntity localDateTimeStringFromUTC:self.createdAtUTC];
}

+ (void)setCloudEndpointService:(GTLServiceMobilebackend *)service {
  gCloudEndpointService = service;
}

+ (GTLServiceMobilebackend *)cloudEndpointService {
  NSAssert(gCloudEndpointService != nil,
           @"cloudEndpointService not initialized");
  return gCloudEndpointService;
}

+ (CloudEntity *)entityWithKind:(NSString *)kindName
                     properties:(NSDictionary *)properties {
  GTLMobilebackendEntityDto *rawObject =
      [[GTLMobilebackendEntityDto alloc] init];

  CloudEntity *entity = [[CloudEntity alloc] initWithObject:rawObject];
  entity.kindName = kindName;
  entity.properties = [properties mutableCopy];
  return entity;
}

+ (CloudEntity *)entityWithRawObject:(GTLMobilebackendEntityDto *)rawObject {
  CloudEntity *entity = [[CloudEntity alloc] initWithObject:rawObject];
  return entity;
}

// Log response and execute the callback with response object and errors.
+ (void)logAndExecuteWithObject:(GTLMobilebackendEntityDto *)object
                  responseError:(NSError *)error
                    requestType:(NSString *)type
                       callBack:(CloudEntityQueryCompletionCallback)block {
  if (error) {
    NSLog(@"%@: %@", type, error);
  } else {
    NSLog(@"%@: %@", type, object);
  }

  if (block) {
    CloudEntity *entity = [CloudEntity entityWithRawObject:object];
    block(entity, error);
  }
}

+ (void)removeInstanceWithIdentifier:(NSString *)identifier
                            kindName:(NSString *)name
                           indexPath:(NSIndexPath *)indexPath
                            callback:(CloudEntityQueryCompletionCallback)block {
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1DeleteWithKind:name
                                                   identifier:identifier];
  [[CloudEntity cloudEndpointService] executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityDto *object,
                          NSError *error) {
          [self logAndExecuteWithObject:object
                          responseError:error
                            requestType:@"DELETE"
                               callBack:block];
      }];
}

+ (void)fetchInstanceWithIdentifier:(NSString *)identifier
                           kindName:(NSString *)name
                           callback:(CloudEntityQueryCompletionCallback)block {
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1GetWithKind:name
                                                identifier:identifier];

  GTLServiceMobilebackend *service = [CloudEntity cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityDto *object,
                          NSError *error) {
          [self logAndExecuteWithObject:object
                          responseError:error
                            requestType:@"GET"
                               callBack:block];
      }];

}

+ (NSString *)localDateTimeStringFromUTC:(NSDate *)datetime {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
  [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
  return [dateFormatter stringFromDate:datetime];
}

- (void)insertInstanceWithCallback:(CloudEntityQueryCompletionCallback)block {
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1InsertWithObject:self.innerObject
                                                           kind:self.kindName];

  GTLServiceMobilebackend *service = [CloudEntity cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityDto *object,
                          NSError *error) {
          [CloudEntity logAndExecuteWithObject:object
                                responseError:error
                                  requestType:@"INSERT"
                                     callBack:block];
      }];
}

- (void)putInstanceAtIndexPath:(NSIndexPath *)indexPath
                      callback:(CloudEntityQueryCompletionCallback)block {
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1UpdateWithObject:self.innerObject
                                                           kind:self.kindName];

  GTLServiceMobilebackend *service = [CloudEntity cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityDto *object,
                          NSError *error) {
          [CloudEntity logAndExecuteWithObject:object
                                 responseError:error
                                   requestType:@"UPDATE"
                                      callBack:block];
      }];
}

- (void)removeInstanceAtIndexPath:(NSIndexPath *)indexPath
                         callback:(CloudEntityQueryCompletionCallback)block {
  GTLQueryMobilebackend *query =
      [GTLQueryMobilebackend queryForEndpointV1DeleteWithKind:self.kindName
                                                   identifier:self.identifier];
  GTLServiceMobilebackend *service = [CloudEntity cloudEndpointService];
  [service executeQuery:query
      completionHandler:^(GTLServiceTicket *ticket,
                          GTLMobilebackendEntityDto *object,
                          NSError *error) {
          [CloudEntity logAndExecuteWithObject:object
                                responseError:error
                                  requestType:@"DELETE"
                                     callBack:block];
      }];
}

@end
