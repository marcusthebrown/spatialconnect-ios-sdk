/**
 * Copyright 2016 Boundless http://boundlessgeo.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

#import "SCNotification.h"
#import "SCRemoteConfig.h"
#import "SCService.h"
#import "SCServiceLifecycle.h"
#import "Scmessage.pbobjc.h"
#import <MQTTFramework/MQTTFramework.h>
#import <MQTTFramework/MQTTSessionManager.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UserNotifications/UserNotifications.h>

@interface SCBackendService
    : SCService <SCServiceLifecycle, UNUserNotificationCenterDelegate> {
  NSString *mqttEndpoint;
  NSString *mqttPort;
  NSString *mqttProtocol;
  NSString *httpProtocol;
  NSString *httpEndpoint;
  NSString *httpPort;
  MQTTSessionManager *sessionManager;
  RACSignal *multicast;
}

@property(readonly, strong) NSString *backendUri;
@property(readonly, strong) RACSignal *notifications;
@property(readonly, strong) RACBehaviorSubject *configReceived;
@property(readonly, strong) RACBehaviorSubject *connectedToBroker;

- (id)initWithRemoteConfig:(SCRemoteConfig *)cfg;
- (void)publish:(SCMessage *)msg onTopic:(NSString *)topic;
- (void)publishAtMostOnce:(SCMessage *)msg onTopic:(NSString *)topic;
- (void)publishAtLeastOnce:(SCMessage *)msg onTopic:(NSString *)topic;
- (void)publishExactlyOnce:(SCMessage *)msg onTopic:(NSString *)topic;
- (RACSignal *)publishReplyTo:(SCMessage *)msg onTopic:(NSString *)topic;
- (RACSignal *)listenOnTopic:(NSString *)topic;

@end
