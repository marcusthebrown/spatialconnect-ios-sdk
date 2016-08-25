/*****************************************************************************
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 ******************************************************************************/

#import "JSONKit.h"
#import "SCNotification.h"
#import "SCPoint.h"
#import "Scmessage.pbobjc.h"
#import "SpatialConnect.h"
#import "SpatialConnectHelper.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface SCMQTTTest : XCTestCase {
  SpatialConnect *sc;
}
@end

@implementation SCMQTTTest

- (void)setUp {
  [super setUp];
  sc = [SpatialConnectHelper loadRemoteConfig];
}

- (void)tearDown {
  [super tearDown];
  [sc stopAllServices];
}

- (void)testMQTT {
  XCTestExpectation *expect = [self expectationWithDescription:@"MQTT"];
  [sc.networkService start];
  SCMessage *msg = [[SCMessage alloc] init];
  msg.correlationId = 234;
  msg.action = 456;
  NSString *replyTo = [NSString
      stringWithFormat:@"/device/%@-replyTo", sc.configService.identifier];
  msg.replyTo = replyTo;
  [[sc.networkService publishReplyTo:msg onTopic:@"/ping"]
      subscribeNext:^(id x) {
        [expect fulfill];
      }
      error:^(NSError *error) {
        [expect fulfill];
      }
      completed:^{
        [expect fulfill];
      }];
  [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testTrackingNotification {
  XCTestExpectation *expect = [self expectationWithDescription:@"MQTT"];
  [sc.networkService start];
  [sc.backendService start];
  SCMessage *msg = [[SCMessage alloc] init];
  msg.correlationId = 234;
  msg.action = 456;
  SCPoint *p = [[SCPoint alloc] initWithCoordinateArray:@[
    @(-122.03943729400633),
    @(37.33525848132234)
  ]];
  msg.payload = [[p JSONDict] JSONString];
  [[sc.backendService notifications] subscribeNext:^(SCMessage *m) {
    NSLog(@"%@", m.payload);
    SCNotification *n = [[SCNotification alloc] initWithMessage:m];
    XCTAssertNotNil(n);
    XCTAssertNotNil([n dictionary]);
    [expect fulfill];
  }];
  [sc.networkService publish:msg onTopic:@"/store/tracking"];
  [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end