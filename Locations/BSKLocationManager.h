//
//  BSKLocationManager.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class BSKLocationClient;

@interface BSKLocationManager : NSObject

+ (BSKLocationManager *)sharedManager;

@property (assign) BOOL enabled;
@property (assign) BOOL updatingLocation;
@property (assign) BOOL monitoringSignificantLocationChange;
@property (assign) BOOL workInBackground;
@property (assign) BOOL authorized;
@property (retain) NSString *purpose;
@property (assign) CLLocationDistance distanceFilter;
@property (assign) CLLocationAccuracy desiredAccuracy;

- (void)reset;

- (void)startMonitoringForRegion:(CLRegion *)region;
- (void)startMonitoringForRegion:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)desiredAccuracy;
- (void)stopMonitoringForRegion:(CLRegion *)region;

@end

extern NSString *BSKLocationManagerEnabledKey;
extern NSString *BSKLocationManagerUpdatingLocationKey;
extern NSString *BSKLocationManagerMonitoringSignificantLocationChangeKey;
extern NSString *BSKLocationManagerWorkInBackgroundKey;
extern NSString *BSKLocationManagerAuthorizedKey;
extern NSString *BSKLocationManagerPurposeKey;
extern NSString *BSKLocationManagerDistanceFilterKey;
extern NSString *BSKLocationManagerDesiredAccuracyKey;

extern NSString *BSKLocationManagerDidUpdateToLocationNotification;
extern NSString *BSKLocationManagerDidUpdateHeadingNotification;
extern NSString *BSKLocationManagerDidEnterRegionNotification;
extern NSString *BSKLocationManagerDidExitRegionNotification;
extern NSString *BSKLocationManagerDidFailWithErrorNotification;
extern NSString *BSKLocationManagerMonitoringRegionDidFailWithErrorNotification;
extern NSString *BSKLocationManagerDidChangeAuthorizationStatusNotification;
extern NSString *BSKLocationManagerDidStartMonitoringForRegionNotification;

extern NSString *BSKLocationManagerLocationUserInfoKey;
extern NSString *BSKLocationManagerOldLocationUserInfoKey;
extern NSString *BSKLocationManagerHeadingUserInfoKey;
extern NSString *BSKLocationManagerRegionUserInfoKey;
extern NSString *BSKLocationManagerErrorUserInfoKey;
extern NSString *BSKLocationManagerAuthorizationStatusUserInfoKey;

@interface BSKLocationManager(ClientManagement)

- (void)setNeedCollectClientRequest;
- (void)receiveCientRequest:(BSKLocationClient *)client;

@end

extern NSString *BSKLocationManagerSendClientRequestNotification;

