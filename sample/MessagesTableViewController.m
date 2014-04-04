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

#import <Foundation/NSNotification.h>
#import <QuartzCore/QuartzCore.h>

#import "CloudControllerHelper.h"
#import "CloudEntity.h"
#import "Constants.h"
#import "EditModeUITextView.h"
#import "GTLMobilebackend.h"
#import "MessagesTableViewController.h"

NSString *const kMessageTableVCUserSignInNotification =
    @"userSignInNotification";
NSString *const kMessageTableVCUserSignOutNotification =
    @"userSignOutNotification";

@implementation MessagesTableViewController {
  NSMutableArray *_messages; // of CloudEntity
  EditModeUITextView *_textView;
  CloudControllerHelper *_controllerHelper;
}

static NSString *const kCellName = @"Message Detail";
static NSString *const kGuestbookEntityName = @"Guestbook";
static NSString *const kGuestbookPropMessage = @"message";
static int const kLeftRightScreenMargin = 110;

- (void)viewDidLoad {
  [self setupControllerHelper];
}

- (EditModeUITextView *)textView {
  if (!_textView) {
    // Set up new text view for enter text
    CGRect frame = CGRectMake(10, 20, 300, 160);
    _textView =
        [[EditModeUITextView alloc] initWithFrame:frame];
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDone;
  }

  return _textView;
}

- (void)setupControllerHelper {
  _controllerHelper =
      [[CloudControllerHelper alloc] initWithClientID:kCloudBackendClientID
                                               secret:kCloudBackendClientSecret
                                            chainName:kCloudBackendChainName
                                           serviceURL:kCloudBackendServiceURL
                                             delegate:self];
  [_controllerHelper startCommonServices];
}

#pragma mark - Cloud controller delegate

- (UIViewController *)presentingViewController {
  return self;
}

// Action after user sign in
- (void)signInWithCloudControllerHelper:(CloudControllerHelper *)controllerHelper {
  [self showSignoutToolBarButton];

  // Refresh the table view if APNS device token is availble
  if (_controllerHelper.appDelegate.tokenString) {
    [self getAllMessagesManually:NO];
  }
}

// Action after user sign out
- (void)signOutWithCloudControllerHelper:(CloudControllerHelper *)controllerHelper {
  [self showSigninToolBarButton];
}

// Action after the device token being received
- (void)handleDeviceTokenNotification:(NSNotification *)notification
                       userAuthorized:(BOOL)authorized {
  if (authorized) {
    [self getAllMessagesManually:NO];
  }
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               buttonLabel:(NSString *)label
               forDuration:(NSTimeInterval)seconds {
  // Make sure there is a way for the alert to dismiss (auto or manual)
  if (seconds <= 0 && !label) {
    label = @"Dismiss";
  }

  UIAlertView *popupView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:label
                                            otherButtonTitles:nil];
  [popupView show];

  // Auto dismiss the alert window
  if (seconds > 0) {
    [self performSelector:@selector(dismissAlertView:)
               withObject:popupView
               afterDelay:seconds];
  }
}

#pragma mark - Guestbook model

// Issue cloud backend service call to get a list of messages manually.
// Pass in YES if it's manually refresh; NO if it's automatic.
- (void)getAllMessagesManually:(BOOL)manually {
  [self updateUIByReloadingTable:NO showSpinner:YES];

  [_controllerHelper listCollectionWithKind:kGuestbookEntityName
                                  pastScope:manually
                           completionHandle:^(NSArray *array, NSError *error) {
                               [self listCollectionCompletedWithArray:array
                                                                error:error];
                           }];
}

#pragma mark - GUI specific methods

- (void)showSigninToolBarButton {
  self.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Sign in"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(signinPressed:)];
}

- (void)showSignoutToolBarButton {
  self.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Sign out"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(signoutPressed:)];
}

- (IBAction)signoutPressed:(id)sender {
  [_controllerHelper signOut];
}

- (IBAction)signinPressed:(id)sender {
  [_controllerHelper signIn];
}

// Perform actions when cancel button being pressed.
- (IBAction)cancelButtonPressed:(id)sender {
  // Remove floating text view
  [[self textView] hide];

  // Show add toolbar button again
  [self resetToolBarWithAddButton];
}

// Perform actions when add button being pressed.
- (IBAction)addButtonPressed:(id)sender {
  // Show the floating text view for user input
  self.textView.mode = kTextViewModeInsert;
  [self updateUIByShowingFloatingTextView];
}

- (void)updateUIByShowingFloatingTextView {
  // Change the add button to cancel button
  [self showToolbarCancelWithAction:@selector(cancelButtonPressed:)];

  // Diable tableView user interaction at this point
  [self.view addSubview:self.textView];
  [self.textView show];
}

// Update the view controller UI based on caller inputs. If showSpinner is YES,
// this method will display a spinner at the top right toolbar.  If showSpinner
// is NO, this method will display an "add" button instead.
- (void)updateUIByReloadingTable:(BOOL)reloadTable
                     showSpinner:(BOOL)showSpinner {
  if (showSpinner) {
    [self.tableView setUserInteractionEnabled:NO];
    [self showToolbarSpinner];
  } else {
    [self resetToolBarWithAddButton];
  }

  if (reloadTable) {
    UITableView *tableView = self.tableView;
    [tableView reloadData];
  }
}

- (void)showToolbarSpinner {
  UIActivityIndicatorView *spinner =
      [[UIActivityIndicatorView alloc]
          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [spinner startAnimating];

  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)showToolbarAddWithAction:(SEL)addAction {
  UIBarButtonItem *addButton =
      [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                               target:self
                               action:addAction];

  self.navigationItem.rightBarButtonItem = addButton;
}

- (void)showToolbarCancelWithAction:(SEL)cancelAction {
  UIBarButtonItem *cancelButton =
      [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self
                               action:cancelAction];

  self.navigationItem.rightBarButtonItem = cancelButton;
}

- (CGFloat)heightForCellTextString:(NSString *)text
                            UIFont:(UIFont *)font {
  if (!text) {
    text = @"(null)";
  }
  CGSize textSize = [text sizeWithFont:font];
  // Adjust the screen width available for cell text
  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  screenWidth -= kLeftRightScreenMargin;

  CGFloat newValue = ceil(textSize.width / screenWidth) * textSize.height;
  return newValue;
}

- (void)dismissAlertView:(UIAlertView *)alertView {
  [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - Cloud entity action delegate (callback after executing queries)

- (void)resetToolBarWithAddButton {
  [self showToolbarAddWithAction:@selector(addButtonPressed:)];
  [self.tableView setUserInteractionEnabled:YES];
}

- (void)showPopupMessageWithVerb:(NSString *)action {
  NSString *message =
      [NSString stringWithFormat:@"Encounter error when %@ entity", action];
  [self showAlertWithTitle:@"Error"
                   message:message
               buttonLabel:@"OK"
               forDuration:0];
}

- (void)removeCompletedWithObject:(CloudEntity *)returnedObject
                            index:(NSIndexPath *)indexPath
                            error:(NSError *)error {
  if (error) {
    [self showPopupMessageWithVerb:@"deleting"];
  } else {
    // Remove the same item from the local list and the view
    [_messages removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (void)insertCompletedWithObject:(CloudEntity *)returnedObject
                            error:(NSError *)error {
  if (error) {
    [self showPopupMessageWithVerb:@"inserting"];
    [self resetToolBarWithAddButton];
  }
}

- (void)putCompletedWithObject:(CloudEntity *)returnedObject
                         index:(NSIndexPath *)indexPath
                         error:(NSError *)error {
  if (error) {
    [self showPopupMessageWithVerb:@"updating"];
    [self resetToolBarWithAddButton];
  }
}

- (void)listCollectionCompletedWithArray:(NSArray *)returnedArray
                                   error:(NSError *)error {
  if (error) {
    [self showPopupMessageWithVerb:@"listing"];
    [self resetToolBarWithAddButton];
  } else {
    // Assign the array into ivar, and reload table accordingly
    NSMutableArray *array = [returnedArray mutableCopy];
    if (![_messages isEqual:array]) {
      _messages = array; // An array of CloudEntity

      [self updateUIByReloadingTable:YES showSpinner:NO];
    }
  }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kCellName
                                      forIndexPath:indexPath];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:kCellName];
  }

  CloudEntity *record = _messages[indexPath.row];
  cell.textLabel.text = record.properties[kGuestbookPropMessage];
  cell.textLabel.numberOfLines = 0;

  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",
                                  record.localizedUpdatedAt,
                                  record.updatedBy];
  cell.detailTextLabel.numberOfLines = 0;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CloudEntity *record = _messages[indexPath.row];
  NSDictionary *propertyBag = record.properties;
  NSString *message = propertyBag[kGuestbookPropMessage];

  UIFont *detailFont = [UIFont systemFontOfSize:14.0f];
  UIFont *titleFont = [UIFont systemFontOfSize:18.0f];

  CGFloat totalDetailHeight =
      [self heightForCellTextString:record.localizedUpdatedAt
                             UIFont:detailFont] +
      [self heightForCellTextString:record.updatedBy UIFont:detailFont];
  CGFloat totalTitleHeight =
      [self heightForCellTextString:message UIFont:titleFont];
  CGFloat padding = 29.0f;

  return totalDetailHeight + totalTitleHeight + padding;
}

#pragma mark - Table view editing

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete at the backend
    CloudEntity *record = _messages[indexPath.row];

    [record removeInstanceAtIndexPath:indexPath
                             callback:^(CloudEntity *entity, NSError *error) {
                                 [self removeCompletedWithObject:entity
                                                           index:indexPath
                                                           error:error];
                             }];
  }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CloudEntity *record = _messages[indexPath.row];
  NSDictionary *properties = record.properties;

  // Show the text view for edit
  self.textView.mode = kTextViewModeEdit;
  self.textView.text = properties[kGuestbookPropMessage];
  self.textView.cellIndexPath = indexPath;
  [self updateUIByShowingFloatingTextView];
}

#pragma mark - Text view delegate

- (BOOL)textView:(EditModeUITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  // Done key is pressed
  if ([text isEqual:@"\n"]) {
    // Update the user interface
    [textView hide];

    // Show add toolbar button again
    [self showToolbarAddWithAction:@selector(addButtonPressed:)];

    // Make appropiate backend call to save messages
    CloudEntity *record = nil;

    if (textView.mode == kTextViewModeInsert) {
      // Insert request is detected
      NSDictionary *dict = @{kGuestbookPropMessage:textView.text};

      CloudEntity *record = [CloudEntity entityWithKind:kGuestbookEntityName
                                             properties:dict];

      [record insertInstanceWithCallback:^(CloudEntity *entity, NSError *error) {
          [self insertCompletedWithObject:entity error:error];
      }];
    } else if (textView.mode == kTextViewModeEdit) {
      // Update request is detected
      record = _messages[textView.cellIndexPath.row];
      NSMutableDictionary *dict = record.properties;
      dict[kGuestbookPropMessage] = textView.text;

      [record putInstanceAtIndexPath:textView.cellIndexPath
                            callback:^(CloudEntity *entity, NSError *error) {
                                [self putCompletedWithObject:entity
                                    index:textView.cellIndexPath
                                    error:error];
                            }];
    }

    return NO;
  }

  return YES;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
  NSLog(@"%0.01f", velocity.y);
  if (scrollView.contentOffset.y < 0 && velocity.y > -0.8 && velocity.y < 0) {
    // Only refresh the list if the user dragged the list down slow enough
    [self getAllMessagesManually:YES];
  }
}

@end
