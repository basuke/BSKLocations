//
//  AppDelegate.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet UITabBarController *tabBarController;

@property (strong, atomic) NSMutableArray *events;
@property (strong, atomic) NSMutableArray *regions;

@end

