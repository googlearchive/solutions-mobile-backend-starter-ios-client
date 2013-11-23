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
#import "GTLObject.h"

@interface CloudMessageProperties : GTLObject

// Define CloudEntity properties for cloud message.
// Field "topicId" capitalization is conforming to Java backend implementation.
@property(nonatomic, copy) NSString *topicId;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSNumber *duration;
@property(nonatomic, copy) NSString *kind;

// Override the instantiation of this class.
+ (id)propertiesWithTopicID:(NSString *)topicID;

@end
