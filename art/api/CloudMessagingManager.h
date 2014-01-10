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
#import "CloudEntity.h"
#import "CloudEntityCollection.h"

// Enable a publish and subscribe model on iOS client where messages are
// persisted by Cloud Mobile Backend.
@interface CloudMessagingManager : NSObject

// Kind name of CloudEntity for Cloud Message.
extern NSString *const kCloudMessagingManagerKindName;
// Property name of _CloudMessages kind that holds topicId.
extern NSString *const kCloudMessagingPropTopicID;
// Property name of _CloudMessages kind that holds message.
extern NSString *const kCloudMessagingPropMessage;
// Property name of _CloudMessages kind that holds duration.
extern NSString *const kCloudMessagingPropDuration;
// TopicId for broadcast messages.
extern NSString *const kCloudMessagingManagerTopicIDBroadcast;

// Shared instance for the GTMObject Singleton Boilerplate
+ (CloudMessagingManager *)sharedInstance;

// Invoke after listing a collection of cloud entities.  Cloud
// backend endpoint may return an array of CloudEntity via its response to the
// listCollection request.
- (void)listCollectionCompletedWithArray:(NSArray *)returnedArray
                                   error:(NSError *)error;

// Create a CloudEntity for persisting a topic id.
- (CloudEntity *)createCloudMessage:(NSString *)topicID;

// Create a CloudEntity that is going to be broadcast to broadcast-subscribed
// devices.
- (CloudEntity *)createBroadcastMessage;

// Send a message by persisting the Cloud Entity.
- (void)sendMessage:(CloudEntity *)message;

// Send a message by persisting the Cloud Entity asynchronously.
- (void)sendMessage:(NSString *)message
           onFinish:(CloudEntityQueryCompletionCallback)callback;

// Subscribe to a topic
- (void)subscribe:(NSString *)topicID
    maxOfflineMessage:(int)max
            onReceive:(CloudEntityCollectionQueryCompletion)block;

// Unsubscribe to a topic
- (void)unsubscribe:(NSString *)topicID;

@end
