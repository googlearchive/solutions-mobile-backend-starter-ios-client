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

// Users to replace project client ID, client secret and service URL before
// executing the sample.

// Google API installed application client ID. Replace with your own Client ID.
// MOE:begin_strip
NSString *const kCloudBackendClientID =
    @"687054978296-5ibfbj1695lgitflnqfciup3ghoeh101.apps.googleusercontent.com";
/* MOE:end_strip_and_replace
NSString *const kCloudBackendClientID = @"{{{ INSERT ID }}}";
*/

// Google API installed application client secret. Replace with your own Client
// Secret.
// MOE:begin_strip
NSString *const kCloudBackendClientSecret = @"svyEdIMPtfSVHBIo4m-mIIy1";
/* MOE:end_strip_and_replace
NSString *const kCloudBackendClientSecret = @"{{{ INSERT SECRET }}}";
*/

// Arbitrary name for local keychain name.
NSString *const kCloudBackendChainName = @"cloudbackendiosclient";

// Mobile backend service URL in string format.  Replace with your own service
// URL.
// MOE:begin_strip
NSString *const kCloudBackendServiceURL =
    @"https://mobilebackend11.appspot.com/_ah/api/rpc?prettyPrint=false";
/* MOE:end_strip_and_replace
NSString *const kCloudBackendServiceURL =
    @"https://{{{ INSERT APP ID }}}.appspot.com/_ah/api/rpc?prettyPrint=false";
*/

// Notification key for hiding the splash screen
NSString *const kHideSplashScreenKey = @"hideSplashScreen";

// Storyboard name
NSString *const kMainStoryboard = @"iphone";

// Navigation storyboard id
NSString *const kNavigationStoryboardId = @"ApplicationStart";

