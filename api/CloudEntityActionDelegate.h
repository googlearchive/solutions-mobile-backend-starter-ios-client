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

@class CloudEntity;

// Defines a range of action methods that will be called when a cloud entity
// or a cloud entity collection is being created, updated or deleted at the
// cloud backend.
@protocol CloudEntityActionDelegate <NSObject>

@optional

// Invoke when a cloud entity is deleted.  Cloud backend endpoint
// may return an object via its response to the delete request.  An indexPath
// may present which represents the deleted item position in current view. Error
// may present which represents if any error is encountered.
- (void)removeCompletedWithObject:(CloudEntity *)returnedObject
                            index:(NSIndexPath *)indexPath
                            error:(NSError *)error;

// Invoke when a cloud entity is fetched.
- (void)fetchCompletedWithObject:(CloudEntity *)returnedObject
                           error:(NSError *)error;

// Invoke when a cloud entity is inserted.  Cloud backend endpoint
// may return an object via its response to the create request.  Error is also
// returned if there is any.
- (void)insertCompletedWithObject:(CloudEntity *)returnedObject
                            error:(NSError *)error;

// Invoke when a cloud entity is updated.  Cloud backend endpoint
// may return an object via its response to the update request.  An indexPath
// may present which represents the updated item position in current view. Error
// is also returned if there is any.
- (void)putCompletedWithObject:(CloudEntity *)returnedObject
                         index:(NSIndexPath *)indexPath
                         error:(NSError *)error;

// Invoke after listing a collection of cloud entities.  Cloud
// backend endpoint may return an array of CloudEntity via its response to the
// listCollection request.
- (void)listCollectionCompletedWithArray:(NSArray *)returnedArray
                                   error:(NSError *)error;

// Invoke after inserting a collection of cloud entities.  Cloud
// backend endpoint may return an array of CloudEntity via its response to the
// insertCollection request.
- (void)insertCollectionCompletedWithArray:(NSArray *)returnedArray
                                     error:(NSError *)error;

// Invoke after removing a collection of cloud entities.  Cloud
// backend endpoint may return an array of CloudEntity via its response to the
// removeCollection request.
- (void)removeCollectionCompletedWithArray:(NSArray *)returnedArray
                                     error:(NSError *)error;

// Invoke after updating a collection of cloud entities. Cloud
// backend endpoint may return an array of CloudEntity via its response to the
// putCollection request.
- (void)putCollectionCompletedActionWithArray:(NSArray *)returnedArray
                                        error:(NSError *)error;

// Invoke after getting a collection of cloud entities is successful.  Cloud
// backend endpoint may return an array of CloudEntity via its response to the
// fetchCollection request.
- (void)fetchCollectionCompletedActionWithArray:(NSArray *)returnedObject
                                          error:(NSError *)error;

@end
