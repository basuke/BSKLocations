//
//  LocationEvent.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface LocationEvent : NSObject

+ (LocationEvent *)eventWithTitle:(NSString *)title;
+ (LocationEvent *)eventWithTitle:(NSString *)title location:(CLLocation *)location;
+ (LocationEvent *)eventWithTitle:(NSString *)title error:(NSError *)error;
+ (LocationEvent *)eventWithTitle:(NSString *)title region:(CLRegion *)region;

@property(retain) NSString *title;

@property(retain) CLLocation *location;

@property(retain) NSError *error;

@property(retain) CLRegion *region;

@property(assign) BOOL inBackground;

@property(retain) NSDate *timestamp;

@end
