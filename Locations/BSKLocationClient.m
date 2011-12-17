//
//  BSKLocationClient.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSKLocationClient.h"
#import "BSKLocationManager.h"

@implementation BSKLocationClient

+ (id)client {
	return [[[[self class] alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self) {
		BSKLocationManager *manager = [BSKLocationManager sharedManager];
		
		_distanceFilter = kCLDistanceFilterNone;
		_desiredAccuracy = kCLLocationAccuracyBest;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(sendRequest:) 
													 name:BSKLocationManagerSendClientRequestNotification 
												   object:manager];
		[manager setNeedCollectClientRequest];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BSKLocationManager sharedManager] setNeedCollectClientRequest];
	
	[super dealloc];
}

#pragma mark - Notification

- (void)sendRequest:(NSNotification *)notification {
	[[BSKLocationManager sharedManager] receiveCientRequest:self];
}

#pragma mark - Accessors

- (BOOL)enabled {
	return _enabled;
}

- (void)setEnabled:(BOOL)flag {
	if (flag != _enabled) {
		[self willChangeValueForKey:BSKLocationManagerEnabledKey];
		_enabled = flag;
		[self didChangeValueForKey:BSKLocationManagerEnabledKey];
		
		[[BSKLocationManager sharedManager] setNeedCollectClientRequest];
	}
}

- (BOOL)workInBackground {
	return _workInBackground;
}

- (void)setWorkInBackground:(BOOL)flag {
	if (flag != _workInBackground) {
		[self willChangeValueForKey:BSKLocationManagerWorkInBackgroundKey];
		_workInBackground = flag;
		[self didChangeValueForKey:BSKLocationManagerWorkInBackgroundKey];
		
		[[BSKLocationManager sharedManager] setNeedCollectClientRequest];
	}
}

- (CLLocationDistance)distanceFilter {
	return _distanceFilter;
}

- (void)setDistanceFilter:(CLLocationDistance)distance {
	if (distance != _distanceFilter) {
		[self willChangeValueForKey:BSKLocationManagerDistanceFilterKey];
		_distanceFilter = distance;
		[self didChangeValueForKey:BSKLocationManagerDistanceFilterKey];
		
		[[BSKLocationManager sharedManager] setNeedCollectClientRequest];
	}
}

- (CLLocationAccuracy)desiredAccuracy {
	return _desiredAccuracy;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)accuracy {
	if (accuracy != _desiredAccuracy) {
		[self willChangeValueForKey:BSKLocationManagerDesiredAccuracyKey];
		_desiredAccuracy = accuracy;
		[self didChangeValueForKey:BSKLocationManagerDesiredAccuracyKey];
		
		[[BSKLocationManager sharedManager] setNeedCollectClientRequest];
	}
}

@end
