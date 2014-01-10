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

#import <UIKit/UIKit.h>
#import "CloudControllerDelegate.h"
#import "CloudEntityActionDelegate.h"

// Notification triggered when user is signed in.
extern NSString *const kMessageTableVCUserSignInNotification;
// Notification triggered when user is signed out.
extern NSString *const kMessageTableVCUserSignOutNotification;

// Displays a list of guestbook messages retrieved from the backend service,
// and provides user interface for insert, update, and delete messages
@interface MessagesTableViewController : UITableViewController
    <UITextViewDelegate, CloudEntityActionDelegate, CloudControllerDelegate>
@end
