//
//  TargetArea.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TargetArea.h"
#import "BSKLocationManager.h"

@implementation TargetArea

@synthesize title=_title;
@synthesize subtitle=_subtitle;
@synthesize region=_region;
@synthesize overlay=_overlay;

- (id)initWithRegion:(CLRegion *)region title:(NSString *)title {
	self = [super init];
	if (self) {
		self.region = region;
		self.title = title;
		self.overlay = [MKCircle circleWithCenterCoordinate:self.region.center radius:self.region.radius];
	}
	return self;
}

- (void)dealloc {
    self.overlay = nil;
    self.region = nil;
    self.title = nil;
	self.subtitle = nil;
	
    [super dealloc];
}

- (CLLocationCoordinate2D)coordinate {
	return self.region.center;
}

@end
