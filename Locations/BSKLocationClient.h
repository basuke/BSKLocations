//
//  BSKLocationClient.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class BSKLocationManager;

@interface BSKLocationClient : NSObject {
	BOOL _enabled;
	BOOL _workInBackground;
	CLLocationDistance _distanceFilter;
	CLLocationAccuracy _desiredAccuracy;
}

+ (id)client;

@property (assign) BOOL enabled;
@property (assign) BOOL workInBackground;
@property (assign) CLLocationDistance distanceFilter;
@property (assign) CLLocationAccuracy desiredAccuracy;

@end
