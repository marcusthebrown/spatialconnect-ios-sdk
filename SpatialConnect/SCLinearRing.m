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

#import "SCBoundingBox.h"
#import "SCLinearRing.h"
#import "SCPoint.h"

@implementation SCLinearRing

- (id)initWithCoordinateArray:(NSArray *)coords {
  if (self = [super init]) {
    if (coords.count < 3) {
      return nil;
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSArray *coord in coords) {
      [array addObject:[[SCPoint alloc] initWithCoordinateArray:coord]];
    }
    if (array.count > 0 &&
        ![((SCPoint *)array.firstObject)
            equals:((SCPoint *)array.lastObject)]) {
      [array addObject:array.firstObject];
    }
    self.points = [[NSArray alloc] initWithArray:array];
    self.bbox = [[SCBoundingBox alloc] initWithPoints:self.points];
  }
  return self;
}

- (GeometryType)type {
  return LINEARRING;
}

- (NSString *)description {
  NSMutableString *str =
      [[NSMutableString alloc] initWithString:@"LinearRing["];
  [self.points
      enumerateObjectsUsingBlock:^(SCPoint *point, NSUInteger idx, BOOL *stop) {
        [str appendString:[point description]];
      }];
  [str appendString:@"]"];
  return str;
}

- (BOOL)isContained:(SCBoundingBox *)bbox {
  __block BOOL response = NO;
  [self.points
      enumerateObjectsUsingBlock:^(SCPoint *p, NSUInteger idx, BOOL *stop) {
        if ([bbox pointWithin:p]) {
          response = YES;
          *stop = YES;
        }
      }];
  return response;
}

- (SCSimplePoint *)centroid {
  __block double x = 0;
  __block double y = 0;
  [self.points
      enumerateObjectsUsingBlock:^(SCPoint *p, NSUInteger idx, BOOL *stop) {
        x += p.x;
        y += p.y;
      }];
  return [[SCSimplePoint alloc] initWithX:(x / self.points.count)
                                        Y:(y / self.points.count)];
}

@end
