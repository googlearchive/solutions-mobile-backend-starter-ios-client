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

#import "CloudFilter.h"
#import "GTLDateTime.h"


@implementation CloudFilter

static NSArray *operators;

+ (void)initialize {
  operators = @[@"EQ", @"LT", @"LE", @"GT", @"GE", @"NE", @"IN", @"AND", @"OR"];
}

// Create filter object based on input operator value which excludes IN, AND
// and OR.
+ (CloudFilter *)filterWithOperator:(FilterOperator)operator
           property:(NSString *)property
              value:(id)value {
  CloudFilter *f = [[CloudFilter alloc] init];
  f.filterDto = [[GTLMobilebackendFilterDto alloc] init];

  NSAssert(operator < FilterOperatorIN,
           @"Not supported operator: %d", operator);

  f.filterDto.operatorProperty = operators[operator];

  // Convert type if GTLObject doesn't support it
  if ([value isKindOfClass:[NSDate class]]) {
    GTLDateTime *newValue =
        [GTLDateTime dateTimeWithDate:value
                             timeZone:[NSTimeZone localTimeZone]];
    value = newValue;
  }
  f.filterDto.values = @[property, value];

  return f;
}

// Create filter object based on operator value which can only be AND or OR.
+ (CloudFilter *)filterAndOrWithOperator:(FilterOperator)operator
                    filters:(NSArray *)subfilters { // of filterDto
  CloudFilter *f = [[CloudFilter alloc] init];
  f.filterDto = [[GTLMobilebackendFilterDto alloc] init];

  NSAssert(operator == FilterOperatorAND || operator == FilterOperatorOR,
           @"Not supported operator: %d", operator);

  f.filterDto.operatorProperty = operators[operator];
  if (subfilters) {
    f.filterDto.subfilters = subfilters;
    return f;
  }

  return nil;
}

+ (CloudFilter *)cloudFilterEq:(NSString *)property value:(id)value {
  return [self filterWithOperator:FilterOperatorEQ
                         property:property
                            value:value];
}

+ (CloudFilter *)cloudFilterLt:(NSString *)property value:(id)value {
  return [self filterWithOperator:FilterOperatorLT
                         property:property
                            value:value];
}

+ (CloudFilter *)cloudFilterLe:(NSString *)property value:(id)value {
  return [self filterWithOperator:FilterOperatorLE
                         property:property
                            value:value];
}

+ (CloudFilter *)cloudFilterGt:(NSString *)property value:(id)value {
  return [self filterWithOperator:FilterOperatorGT
                         property:property
                            value:value];
}

+ (CloudFilter *)cloudFilterGe:(NSString *)property value:(id)value {
  return [self filterWithOperator:FilterOperatorGE
                         property:property
                            value:value];
}

+ (CloudFilter *)cloudFilterNe:(NSString *)property value:(id)value {
  return [self filterWithOperator:FilterOperatorNE
                         property:property
                            value:value];
}

+ (CloudFilter *)cloudFilterInValues:(NSString *)property
                              values:(id)value, ... {
  CloudFilter *f = [[CloudFilter alloc] init];
  f.filterDto = [[GTLMobilebackendFilterDto alloc] init];
  f.filterDto.operatorProperty = @"IN";

  if (property && value) {
    va_list argumentList;
    va_start(argumentList, value);

    NSMutableArray *array = [NSMutableArray arrayWithObject:property];
    [array addObjectsFromArray:[self arrayFromAugumentList:value
                                                 arguments:argumentList]];
    f.filterDto.values = array;
    va_end(argumentList);

    return f;
  }

  return nil;
}

+ (CloudFilter *)cloudFilterAndFilters:(CloudFilter *)filter, ... {
  // Loop the rest
  va_list argumentList;
  va_start(argumentList, filter);
  NSArray *subfilters = [self filterDtoArrayFromArgumentList:filter
                                                   arguments:argumentList];
  va_end(argumentList);
  return [CloudFilter filterAndOrWithOperator:FilterOperatorAND
                                      filters:subfilters];
}

+ (CloudFilter *)cloudFilterOrFilters:(CloudFilter *)filter, ... {
  // Loop the rest
  va_list argumentList;
  va_start(argumentList, filter);
  NSArray *subfilters = [self filterDtoArrayFromArgumentList:filter
                                                   arguments:argumentList];
  va_end(argumentList);

  return [CloudFilter filterAndOrWithOperator:FilterOperatorOR
                                      filters:subfilters];
}

// Convert va_list of generic data type into array of the same data type
+ (NSArray *)arrayFromAugumentList:(id)firstObject
                         arguments:(va_list)argumentList {
  NSMutableArray *resultedArray = [[NSMutableArray alloc] init];
  id eachItem = firstObject;
  while (eachItem) {
    [resultedArray addObject:eachItem];
    eachItem = va_arg(argumentList, id);
  }

  return resultedArray;
}

// Convert va_list of CloudFilter into array of filterDto
+ (NSArray *)filterDtoArrayFromArgumentList:(CloudFilter *)firstObject
                                  arguments:(va_list)argumentList {
  NSMutableArray *resultedArray = [[NSMutableArray alloc] init];

  CloudFilter *eachItem = firstObject;
  while (eachItem) {
    if (eachItem.filterDto) {
      [resultedArray addObject:eachItem.filterDto];
    }
    eachItem = va_arg(argumentList, CloudFilter *);
  }

  return resultedArray;
}

@end
