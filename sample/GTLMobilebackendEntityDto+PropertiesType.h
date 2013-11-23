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

// Override the datatype of the properties field for the generated
// GTLMobilebackendEntityDto object such that GTL runtime can use the proper
// fields inside the properties.
@interface GTLMobilebackendEntityDto (PropertiesType)
@property(retain) NSMutableDictionary *properties;
@end
