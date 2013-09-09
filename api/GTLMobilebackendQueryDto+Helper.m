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
#import "GTLMobilebackendFilterDto.h"
#import "GTLMobilebackendQueryDto+Helper.h"


@implementation GTLMobilebackendQueryDto (Helper)

- (BOOL)isContinuousQuery {
  return ((self.scope == kCloudEntityScopeFuture) ||
          (self.scope == kCloudEntityScopeFutureAndPast));
}

- (id)copyWithZone:(NSZone *)zone {
  GTLMobilebackendQueryDto *copy = [[[self class] alloc] init];

  copy.filterDto = self.filterDto;
  copy.kindName = self.kindName.copy;
  copy.limit = self.limit.copy;
  copy.queryId = self.queryId.copy;
  copy.regId = self.regId.copy;
  copy.scope = self.scope.copy;
  copy.sortAscending = self.sortAscending.copy;
  copy.sortedPropertyName = self.sortedPropertyName.copy;
  copy.subscriptionDurationSec = self.subscriptionDurationSec.copy;

  return copy;
}

- (void)setDefaultQueryIDIfNeeded {
  if (!self.queryId) {
    NSString *queryDtoJSON = [self JSONString];
    NSString *filterDtoJSON = [self.filterDto JSONString];
    NSString *uniqueString =
        [NSString stringWithFormat:@"%@%@", queryDtoJSON, filterDtoJSON];
    NSLog(@"hash uniqueString = %@", uniqueString);
    NSString *hashcode = [NSString stringWithFormat:@"%d", uniqueString.hash];

    self.queryId = hashcode;
  }
}

@end
