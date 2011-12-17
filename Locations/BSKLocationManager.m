//
//  LocationManager.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSKLocationManager.h"
#import "BSKLocationClient.h"

@interface BSKLocationManager()<CLLocationManagerDelegate> {
	BOOL _enabled;
	BOOL _updatingLocation;
	BOOL _monitoringSignificantLocationChange;
	BOOL _workInBackground;
	BOOL _authorized;
	CLLocationDistance _distanceFilter;
	CLLocationAccuracy _desiredAccuracy;
	
	BOOL _inBackground;
	
	CLLocationManager *locationManager;
}

@property(retain) NSMutableSet *clients;

- (void)updateLocationManagerEnabled:(BOOL)enabled 
					workInBackground:(BOOL)workInBackground 
					  distanceFilter:(CLLocationDistance)distanceFilter
					 desiredAccuracy:(CLLocationAccuracy)desiredAccuracy;

@end

@implementation BSKLocationManager

static BSKLocationManager *sharedManager = nil;

+ (BSKLocationManager *)sharedManager {
	if (sharedManager == nil) {
		@synchronized(self) {
			if (sharedManager == nil) {
				sharedManager = [[BSKLocationManager alloc] init];
				
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseSharedManager:) name:UIApplicationWillTerminateNotification object:nil];
			}
		}
	}
	
	return sharedManager;
}

+ (void)releaseSharedManager:(NSNotification *)notification {
	[sharedManager autorelease];
}

@synthesize clients=clients_;

- (id)init {
	self = [super init];
	if (self) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		
		_distanceFilter = locationManager.distanceFilter;
		_desiredAccuracy = locationManager.desiredAccuracy;
		_inBackground = ([UIApplication sharedApplication].applicationState != UIApplicationStateActive);
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
		[center addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.clients = nil;
	
	locationManager.delegate = nil;
	[locationManager release];
	
    [super dealloc];
}

- (void)reset {
	self.updatingLocation = NO;
	self.monitoringSignificantLocationChange = NO;
	
	for (CLRegion *region in locationManager.monitoredRegions) {
		[locationManager stopMonitoringForRegion:region];
	}
	
	[self setNeedCollectClientRequest];
}

- (void)startMonitoringForRegion:(CLRegion *)region {
	[self startMonitoringForRegion:region desiredAccuracy:kCLLocationAccuracyBest];
}

- (void)startMonitoringForRegion:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
	[locationManager startMonitoringForRegion:region desiredAccuracy:desiredAccuracy];
}

- (void)stopMonitoringForRegion:(CLRegion *)region {
	[locationManager stopMonitoringForRegion:region];
}

- (BOOL)updatingLocation {
	return _updatingLocation;
}

- (void)setUpdatingLocation:(BOOL)flag {
	if (flag != _updatingLocation) {
		[self willChangeValueForKey:BSKLocationManagerUpdatingLocationKey];
		_updatingLocation = flag;
		[self didChangeValueForKey:BSKLocationManagerUpdatingLocationKey];
		
		[self setNeedCollectClientRequest];
		
		if (flag) {
			[locationManager startUpdatingLocation];
		} else {
			[locationManager stopUpdatingLocation];
		}
	}
}

- (BOOL)monitoringSignificantLocationChange {
	return _monitoringSignificantLocationChange;
}

- (void)setMonitoringSignificantLocationChange:(BOOL)flag {
	if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		if (flag != _monitoringSignificantLocationChange) {
			[self willChangeValueForKey:BSKLocationManagerMonitoringSignificantLocationChangeKey];
			_monitoringSignificantLocationChange = flag;
			[self didChangeValueForKey:BSKLocationManagerMonitoringSignificantLocationChangeKey];
			
			if (flag) {
				[locationManager startMonitoringSignificantLocationChanges];
			} else {
				[locationManager stopMonitoringSignificantLocationChanges];
			}
		}
	}
}

- (NSString *)purpose {
	return locationManager.purpose;
}

- (void)setPurpose:(NSString *)purpose {
	[self willChangeValueForKey:BSKLocationManagerPurposeKey];
	locationManager.purpose = purpose;
	[self didChangeValueForKey:BSKLocationManagerPurposeKey];
}

- (void)updateLocationManagerEnabled:(BOOL)enabled 
					workInBackground:(BOOL)workInBackground 
					  distanceFilter:(CLLocationDistance)distanceFilter
					 desiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
	locationManager.distanceFilter = distanceFilter;
	locationManager.desiredAccuracy = desiredAccuracy;
	
	if (enabled) {
		if (_inBackground == NO) {
			self.updatingLocation = YES;
			self.monitoringSignificantLocationChange = NO;
		} else if (workInBackground) {
			self.updatingLocation = NO;
			self.monitoringSignificantLocationChange = YES;
		} else {
			self.updatingLocation = NO;
			self.monitoringSignificantLocationChange = NO;
		}
	} else {
		self.updatingLocation = NO;
		self.monitoringSignificantLocationChange = NO;
	}
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
		
		[self setNeedCollectClientRequest];
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
		
		[self setNeedCollectClientRequest];
	}
}

- (CLLocationDistance)distanceFilter {
	return _distanceFilter;
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter {
	if (_distanceFilter != distanceFilter) {
		[self willChangeValueForKey:BSKLocationManagerDistanceFilterKey];
		_distanceFilter = distanceFilter;
		[self didChangeValueForKey:BSKLocationManagerDistanceFilterKey];
		
		[self setNeedCollectClientRequest];
	}
}

- (CLLocationAccuracy)desiredAccuracy {
	return _desiredAccuracy;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
	if (_desiredAccuracy != desiredAccuracy) {
		[self willChangeValueForKey:BSKLocationManagerDesiredAccuracyKey];
		_desiredAccuracy = desiredAccuracy;
		[self didChangeValueForKey:BSKLocationManagerDesiredAccuracyKey];
		
		[self setNeedCollectClientRequest];
	}
}

#pragma mark - plain accessors

- (BOOL)authorized {
	return _authorized;
}

- (void)setAuthorized:(BOOL)flag {
	if (flag != _authorized) {
		[self willChangeValueForKey:BSKLocationManagerAuthorizedKey];
		_authorized = flag;
		[self didChangeValueForKey:BSKLocationManagerAuthorizedKey];
	}
}

#pragma mark Norifications

- (void)resignActive:(NSNotification *)notification {
	_inBackground = YES;
	
	[self setNeedCollectClientRequest];
}

- (void)becomeActive:(NSNotification *)notification {
	_inBackground = NO;
	
	[self setNeedCollectClientRequest];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  newLocation, BSKLocationManagerLocationUserInfoKey, 
							  oldLocation, BSKLocationManagerOldLocationUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidUpdateToLocationNotification
														object:self 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  newHeading, BSKLocationManagerHeadingUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidUpdateHeadingNotification
														object:self 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  region, BSKLocationManagerRegionUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidEnterRegionNotification
														object:region 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  region, BSKLocationManagerRegionUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidExitRegionNotification
														object:region 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  error, BSKLocationManagerErrorUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidFailWithErrorNotification
														object:self 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  error, BSKLocationManagerErrorUserInfoKey, 
							  region, BSKLocationManagerRegionUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerMonitoringRegionDidFailWithErrorNotification
														object:region 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:status], BSKLocationManagerAuthorizationStatusUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidChangeAuthorizationStatusNotification
														object:self 
													  userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  region, BSKLocationManagerRegionUserInfoKey, 
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerDidStartMonitoringForRegionNotification
														object:region 
													  userInfo:userInfo];
}

@end

NSString *BSKLocationManagerEnabledKey = @"locationEnabled";
NSString *BSKLocationManagerUpdatingLocationKey = @"updatingLocation";
NSString *BSKLocationManagerMonitoringSignificantLocationChangeKey = @"monitoringSignificantLocationChange";
NSString *BSKLocationManagerWorkInBackgroundKey = @"workInBackgroud";
NSString *BSKLocationManagerAuthorizedKey = @"authorized";
NSString *BSKLocationManagerPurposeKey = @"purpose";
NSString *BSKLocationManagerDistanceFilterKey = @"distanceFilter";
NSString *BSKLocationManagerDesiredAccuracyKey = @"desiredAccuracy";


NSString *BSKLocationManagerDidUpdateToLocationNotification = @"locationManager:didUpdateToLocation:fromLocation:";
NSString *BSKLocationManagerDidUpdateHeadingNotification = @"locationManager:didUpdateHeading:";
NSString *BSKLocationManagerDidEnterRegionNotification = @"locationManager:didEnterRegion:";
NSString *BSKLocationManagerDidExitRegionNotification = @"locationManager:didExitRegion:";
NSString *BSKLocationManagerDidFailWithErrorNotification = @"locationManager:didFailWithError:";
NSString *BSKLocationManagerMonitoringRegionDidFailWithErrorNotification = @"locationManager:monitoringDidFailForRegion:withError:";
NSString *BSKLocationManagerDidChangeAuthorizationStatusNotification = @"locationManager:didChangeAuthorizationStatus:";
NSString *BSKLocationManagerDidStartMonitoringForRegionNotification = @"locationManager:didStartMonitoringForRegion:";

NSString *BSKLocationManagerLocationUserInfoKey = @"location";
NSString *BSKLocationManagerOldLocationUserInfoKey = @"oldLocation";
NSString *BSKLocationManagerHeadingUserInfoKey = @"heading";
NSString *BSKLocationManagerRegionUserInfoKey = @"region";
NSString *BSKLocationManagerErrorUserInfoKey = @"error";
NSString *BSKLocationManagerAuthorizationStatusUserInfoKey = @"status";

@implementation BSKLocationManager(ClientManagement)

- (void)collectAndUpdateClientRequests:(NSSet *)clients {
	BOOL enabled = self.enabled;
	BOOL workInBackground = self.workInBackground;
	BOOL hasDistanceFilter = (self.distanceFilter != kCLDistanceFilterNone);
	CLLocationDistance distanceFilter = self.distanceFilter;
	CLLocationAccuracy desiredAccuracy = self.desiredAccuracy;
	
	for (BSKLocationClient *client in clients) {
		if (client.enabled) enabled = YES;
		
		if (client.workInBackground) workInBackground = YES;
		
		if (hasDistanceFilter || client.distanceFilter != kCLDistanceFilterNone) {
			if (distanceFilter != kCLDistanceFilterNone || client.distanceFilter < distanceFilter) {
				hasDistanceFilter = YES;
				distanceFilter = client.distanceFilter;
			}
		}
		
		if (client.desiredAccuracy < desiredAccuracy) {
			desiredAccuracy = client.desiredAccuracy;
		}
	}
	
	[self updateLocationManagerEnabled:enabled
					  workInBackground:workInBackground
						distanceFilter:distanceFilter
					   desiredAccuracy:desiredAccuracy];
}

- (void)setNeedCollectClientRequest {
	@synchronized(self) {
		if (self.clients == nil) {
			self.clients = [NSMutableSet setWithCapacity:5];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:BSKLocationManagerSendClientRequestNotification object:self];
				// After this notification, all active clients already send itself to manager.
				
				[self collectAndUpdateClientRequests:self.clients];
				
				// no need to keep the clients. free them.
				self.clients = nil;
			});
		}
	}
}

- (void)receiveCientRequest:(BSKLocationClient *)client {
	[self.clients addObject:client];
}

@end

NSString *BSKLocationManagerSendClientRequestNotification = @"BSKLocationManagerSendClientRequestNotification";

