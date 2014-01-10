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
#import "GTLMobilebackendQueryDto.h"

// Provides helper methods for GTLMobilebackendQueryDto
@interface GTLMobilebackendQueryDto (Helper) <NSCopying>

// Clone the input query
- (id)copyWithZone:(NSZone *)zone;

// Decide if the query instance is continuous
- (BOOL)isContinuousQuery;

// Set the query id to default value if query instance has no query id
- (void)setDefaultQueryIDIfNeeded;

@end
