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
#import "GTLMobilebackendFilterDto.h"

// Defines simpler model to create filter for GTLMobeilbackendQueryDto
@interface CloudFilter : NSObject

typedef enum { FilterOperatorEQ, FilterOperatorLT, FilterOperatorLE,
  FilterOperatorGT, FilterOperatorGE, FilterOperatorNE, FilterOperatorIN,
  FilterOperatorAND, FilterOperatorOR, FilterOperatorNumber}
  FilterOperator;

@property(nonatomic, strong) GTLMobilebackendFilterDto *filterDto;

// Create a Filter for EQUAL operation.
+ (CloudFilter *)cloudFilterEq:(NSString *)property value:(id)value;

// Create a Filter for LESS THAN operation.
+ (CloudFilter *)cloudFilterLt:(NSString *)property value:(id)value;

// Create a Filter for LESS THAN OR EQUAL TO operation.
+ (CloudFilter *)cloudFilterLe:(NSString *)property value:(id)value;

// Create a Filter for GREATER THAN operation.
+ (CloudFilter *)cloudFilterGt:(NSString *)property value:(id)value;

// Create a Filter for GREATER THAN OR EQUAL TO operation.
+ (CloudFilter *)cloudFilterGe:(NSString *)property value:(id)value;

// Create a Filter for NOT EQUAL operation.
+ (CloudFilter *)cloudFilterNe:(NSString *)property value:(id)value;

// Create a Filter for IN operation.
+ (CloudFilter *)cloudFilterInValues:(NSString *)property values:(id)value, ...
    NS_REQUIRES_NIL_TERMINATION;

// Create a Filter for AND operation.
+ (CloudFilter *)cloudFilterAndFilters:(CloudFilter *)filter, ...
    NS_REQUIRES_NIL_TERMINATION;

// Create a Filter for OR operation.
+ (CloudFilter *)cloudFilterOrFilters:(CloudFilter *)filter, ...
    NS_REQUIRES_NIL_TERMINATION;

@end
