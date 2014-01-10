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

#import "EditModeUITextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation EditModeUITextView

- (void)setMode:(TextViewMode)mode {
  _mode = mode;

  // Reset the border color based on the edit mode
  CALayer *viewLayer = [self layer];
  if (self.mode == kTextViewModeEdit) {
    [viewLayer setBorderColor:[[UIColor grayColor] CGColor]];
  } else {
    [viewLayer setBorderColor:[[UIColor blueColor] CGColor]];
    self.text = nil; // Reset text field to nothing in insert mode
  }

  [self setFont:[UIFont systemFontOfSize:17.0]];

  [self setReturnKeyType:UIReturnKeySend];

  [[self layer] setBorderWidth:2.5];
  [[self layer] setCornerRadius:0];
  [self setContentInset:UIEdgeInsetsMake(5, 5, 5, 5)];
}

- (void)show {
  [[self superview] setUserInteractionEnabled:NO];
  [self becomeFirstResponder];
}

- (void)hide {
  [self resignFirstResponder];
  [[self superview] setUserInteractionEnabled:YES];
  [self removeFromSuperview];

}

@end
