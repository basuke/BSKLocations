//
//  AppDelegate.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "BSKLocationManager.h"

@implementation AppDelegate

@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize events=_events;
@synthesize regions=_regions;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BSKLocationManager *manager = [BSKLocationManager sharedManager];
	manager.purpose = @"`Locations` uses location information to test the location functions of iOS.";
	
	// reset previous requests. you should setup location requests by your self.
	[manager reset];
	
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)dealloc {
	[_window release];
	[_tabBarController release];
	[_events release];
	[_regions release];
    [super dealloc];
}

@end

