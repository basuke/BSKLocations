//
//  LocationLogger.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LocationLogger.h"
#import "LocationEvent.h"
#import "BSKLocationManager.h"

@interface LocationLogger() {
	NSMutableArray *events;
}

@end

@implementation LocationLogger

@synthesize delegate;

- (id)init {
	self = [super init];
	if (self) {
		events = [[NSMutableArray alloc] initWithCapacity:100];
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		
		[center addObserver:self 
				   selector:@selector(locationDidUpdate:) 
					   name:BSKLocationManagerDidUpdateToLocationNotification 
					 object:nil];
		
		[center addObserver:self 
				   selector:@selector(didEnterInRegion:) 
					   name:BSKLocationManagerDidEnterRegionNotification
					 object:nil];
		
		[center addObserver:self 
				   selector:@selector(didExitFromRegion:) 
					   name:BSKLocationManagerDidExitRegionNotification
					 object:nil];
		
		[center addObserver:self 
				   selector:@selector(didFailWithError:) 
					   name:BSKLocationManagerDidFailWithErrorNotification
					 object:nil];
		
		[center addObserver:self 
				   selector:@selector(didFailWithErrorForRegion:) 
					   name:BSKLocationManagerMonitoringRegionDidFailWithErrorNotification
					 object:nil];
		
		[center addObserver:self 
				   selector:@selector(didChangeAuthorizationStatus:) 
					   name:BSKLocationManagerDidChangeAuthorizationStatusNotification
					 object:nil];
		
		[center addObserver:self 
				   selector:@selector(didStartMonitoringForRegion:) 
					   name:BSKLocationManagerDidStartMonitoringForRegionNotification
					 object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[events release];
	
	[super dealloc];
}

- (NSInteger)count {
	@synchronized(self) {
		return [events count];
	}
}

- (LocationEvent *)eventAtIndex:(NSInteger)index {
	@synchronized(self) {
		return [events objectAtIndex:index];
	}
}

- (void)removeAllEvents {
	@synchronized(self) {
		[events removeAllObjects];
	}
}

#pragma mark - Notifications

- (void)pushEvent:(LocationEvent *)event {
	dispatch_async(dispatch_get_main_queue(), ^{
		[events insertObject:event atIndex:0];
		
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:0];
		[self.delegate locationLogger:self eventDidAdd:event atIndexes:indexes];
	});
}

- (void)locationDidUpdate:(NSNotification *)notification {
	CLLocation *location = [[notification userInfo] objectForKey:BSKLocationManagerLocationUserInfoKey];
	
	[self pushEvent:[LocationEvent eventWithTitle:@"Location" location:location]];
}

- (void)didEnterInRegion:(NSNotification *)notification {
	CLRegion *region = [[notification userInfo] objectForKey:BSKLocationManagerRegionUserInfoKey];
	
	[self pushEvent:[LocationEvent eventWithTitle:@"Enter Region" region:region]];
}

- (void)didExitFromRegion:(NSNotification *)notification {
	CLRegion *region = [[notification userInfo] objectForKey:BSKLocationManagerRegionUserInfoKey];
	
	[self pushEvent:[LocationEvent eventWithTitle:@"Exit Region" region:region]];
}

- (void)didFailWithError:(NSNotification *)notification {
	NSError *error = [[notification userInfo] objectForKey:BSKLocationManagerErrorUserInfoKey];
	
	[self pushEvent:[LocationEvent eventWithTitle:@"Fail" error:error]];
}

- (void)didFailWithErrorForRegion:(NSNotification *)notification {
	NSError *error = [[notification userInfo] objectForKey:BSKLocationManagerErrorUserInfoKey];
	CLRegion *region = [[notification userInfo] objectForKey:BSKLocationManagerRegionUserInfoKey];
	
	LocationEvent *event = [LocationEvent eventWithTitle:@"Fail Region" error:error];
	event.region = region;
	
	[self pushEvent:event];
}

- (void)didChangeAuthorizationStatus:(NSNotification *)notification {
	NSNumber *statusCode = [[notification userInfo] objectForKey:BSKLocationManagerAuthorizationStatusUserInfoKey];
	
	NSString *status = nil;
	switch ([statusCode intValue]) {
		case kCLAuthorizationStatusNotDetermined:
			status = @"Not Determined";
			break;
			
		case kCLAuthorizationStatusRestricted:
			status = @"Restricted";
			break;
			
		case kCLAuthorizationStatusDenied:
			status = @"Denied";
			break;
			
		case kCLAuthorizationStatusAuthorized:
			status = @"Authorized";
			break;
			
		default:
			status = [statusCode stringValue];
			break;
	}
	[self pushEvent:[LocationEvent eventWithTitle:[NSString stringWithFormat:@"Status: %@", status]]];
}

- (void)didStartMonitoringForRegion:(NSNotification *)notification {
	CLRegion *region = [[notification userInfo] objectForKey:BSKLocationManagerRegionUserInfoKey];
	
	[self pushEvent:[LocationEvent eventWithTitle:@"Start Monitoring" region:region]];
}


@end
