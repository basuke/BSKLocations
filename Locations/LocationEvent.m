//
//  LocationEvent.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LocationEvent.h"

@implementation LocationEvent

+ (LocationEvent *)eventWithTitle:(NSString *)title {
	LocationEvent *event = [[[LocationEvent alloc] init] autorelease];
	event.title = title;
	return event;
}

+ (LocationEvent *)eventWithTitle:(NSString *)title location:(CLLocation *)location {
	LocationEvent *event = [self eventWithTitle:title];
	event.location = location;
	return event;
}

+ (LocationEvent *)eventWithTitle:(NSString *)title error:(NSError *)error {
	LocationEvent *event = [self eventWithTitle:title];
	event.error = error;
	return event;
}

+ (LocationEvent *)eventWithTitle:(NSString *)title region:(CLRegion *)region {
	LocationEvent *event = [self eventWithTitle:title];
	event.region = region;
	return event;
}

@synthesize location, error, region, title, inBackground, timestamp;

- (id)init {
	self = [super init];
	if (self) {
		self.timestamp = [NSDate date];
		self.inBackground = ([UIApplication sharedApplication].applicationState != UIApplicationStateActive);
	}
	return self;
}

- (void)dealloc {
	self.location = nil;
	self.error = nil;
	self.region = nil;
	self.title = nil;
	
    [super dealloc];
}

- (NSString *)description {
	if (self.location) return [self.location description];
	if (self.error) return [self.error localizedDescription];
	if (self.region) return [self.region description];
	return @"";
}

@end
