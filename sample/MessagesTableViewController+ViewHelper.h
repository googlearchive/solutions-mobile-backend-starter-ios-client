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

#import "CloudAuthenticationUser.h"
#import "EditModeUITextView.h"
#import "GTLDateTime.h"
#import "MessagesTableViewController.h"

// Public constants for UITableViewCell.
extern int const kViewHelperDetailTitleCharLengthPerLine;
extern int const kViewHelperDefaultCellHeight;
extern int const kViewHelperDefaultCellImageWidth;
extern int const kViewHelperDetailTitleHeightPerLine;

// Helper class to assist any computation or rendering for any views.
@interface MessagesTableViewController (ViewHelper)

// Display a top right corner spinner at the top navigation tool bar for the
// to indicate the controller is busy with fetching data from server.
- (void)showToolbarSpinner;

// Display a top right corner add button at the top navigation tool bar to allow
// custom IBAction i.e. adding new table cell. Caller needs to call
// hideToolBarButton to handle the removal of the add button.
- (void)showToolbarAddWithAction:(SEL)addAction;

// Display a top right corner cancel button at the top navigation tool bar to
// allow custom IBAction i.e. remove floating text view.
- (void)showToolbarCancelWithAction:(SEL)cancelAction;

// Calculate the UITableViewCell height based on text provided.
- (CGFloat)heightForCellTextString:(NSString *)text
                            UIFont:(UIFont *)font;

@end
