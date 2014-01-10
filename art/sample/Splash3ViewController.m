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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "Splash3ViewController.h"
#import "Constants.h"

@implementation Splash3ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Splash3ViewController *)sender {
  UINavigationController *nextController = segue.destinationViewController;
  if ([nextController isKindOfClass:[UINavigationController class]]) {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (![standardUserDefaults boolForKey:kHideSplashScreenKey]) {
      [standardUserDefaults setBool:YES forKey:kHideSplashScreenKey];
      [standardUserDefaults synchronize];
    }
  }
}

@end
