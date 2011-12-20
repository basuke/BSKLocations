//
//  SettingsViewController.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "BSKLocationManager.h"

@interface SettingsViewController()

- (float)distanceFilterToSliderValue:(CLLocationDistance)distance;
- (CLLocationDistance)sliderValueToDistanceFilter:(float)value;
- (NSString *)distanceFilterToString:(CLLocationDistance)distance;

- (float)desiredAccuracyToSliderValue:(CLLocationAccuracy)accuracy;
- (CLLocationAccuracy)sliderValueToDesiredAccuracy:(float)value;
- (NSString *)desiredAccuracyToString:(CLLocationDistance)accuracy;

@end

@implementation SettingsViewController

@synthesize locationEnabled, workInBackground, distanceFilter, distanceFilterLabel, desiredAccuracy, desiredAccuracyLabel, buildInfoLabel;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	BSKLocationManager *manager = [BSKLocationManager sharedManager];
	
	self.locationEnabled.on = manager.enabled;
	
	self.workInBackground.on = manager.workInBackground;
	
	self.distanceFilter.value = [self distanceFilterToSliderValue:manager.distanceFilter];
	self.distanceFilterLabel.text = [self distanceFilterToString:manager.distanceFilter];
	
	self.desiredAccuracy.value = [self desiredAccuracyToSliderValue:manager.desiredAccuracy];
	self.desiredAccuracyLabel.text = [self desiredAccuracyToString:manager.desiredAccuracy];
	
	self.buildInfoLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"BUILD_INFO" value:@"" table:@"Build"];
	
}

- (void)viewDidUnload {
	self.locationEnabled = nil;
	self.workInBackground = nil;
	self.distanceFilter = nil;
	self.distanceFilterLabel = nil;
	self.desiredAccuracy = nil;
	self.desiredAccuracyLabel = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions

- (IBAction)locationEnabledChanged:(id)sender {
	BSKLocationManager *manager = [BSKLocationManager sharedManager];
	manager.enabled = self.locationEnabled.on;
}

- (IBAction)workInBackgroundChanged:(id)sender {
	BSKLocationManager *manager = [BSKLocationManager sharedManager];
	manager.workInBackground = self.workInBackground.on;
}

- (IBAction)distanceFilterChanged:(id)sender {
	CLLocationDistance distance = [self sliderValueToDistanceFilter:self.distanceFilter.value];
	self.distanceFilterLabel.text = [self distanceFilterToString:distance];
	
	BSKLocationManager *manager = [BSKLocationManager sharedManager];
	manager.distanceFilter = distance;
}

- (IBAction)desiredAccuracyChanged:(id)sender {
	CLLocationAccuracy accuracy = [self sliderValueToDesiredAccuracy:self.desiredAccuracy.value];
	self.desiredAccuracyLabel.text = [self desiredAccuracyToString:accuracy];
	
	BSKLocationManager *manager = [BSKLocationManager sharedManager];
	manager.desiredAccuracy = accuracy;
}

- (IBAction)copyright:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/basuke"]];
}

#pragma mark - value conversion

- (float)distanceFilterToSliderValue:(CLLocationDistance)distance {
	if (distance == kCLDistanceFilterNone) return 0;
	if (distance >= 100) return 100;
	return distance;
}

- (CLLocationDistance)sliderValueToDistanceFilter:(float)value {
	if (value == 0) return kCLDistanceFilterNone;
	return value;
}

- (NSString *)distanceFilterToString:(CLLocationDistance)distance {
	if (distance == kCLDistanceFilterNone) return @"None";
	
	return [NSString stringWithFormat:@"%dm", (int)distance];
}

- (float)desiredAccuracyToSliderValue:(CLLocationAccuracy)accuracy {
	if (accuracy >= kCLLocationAccuracyThreeKilometers) {
		return 5;
	}
	
	if (accuracy >= kCLLocationAccuracyKilometer) {
		return 4;
	}
	
	if (accuracy >= kCLLocationAccuracyHundredMeters) {
		return 3;
	}
	
	if (accuracy >= kCLLocationAccuracyNearestTenMeters) {
		return 2;
	}
	
	if (accuracy == kCLLocationAccuracyBest) {
		return 1;
	}
	
	return 0;
}

- (CLLocationAccuracy)sliderValueToDesiredAccuracy:(float)value {
	NSInteger index = (value + 0.5);
	
	if (index >= 5) {
		return kCLLocationAccuracyThreeKilometers;
	}
	
	if (index == 4) {
		return kCLLocationAccuracyKilometer;
	}
	
	if (index == 3) {
		return kCLLocationAccuracyHundredMeters;
	}
	
	if (index == 2) {
		return kCLLocationAccuracyNearestTenMeters;
	}
	
	if (index == 1) {
		return kCLLocationAccuracyBest;
	}
	
	return kCLLocationAccuracyBestForNavigation;
}

- (NSString *)desiredAccuracyToString:(CLLocationDistance)accuracy {
	if (accuracy == kCLLocationAccuracyBestForNavigation) return @"Best for navi";
	if (accuracy == kCLLocationAccuracyBest) return @"Best";
	
	return [NSString stringWithFormat:@"about %dm", (int)accuracy];
}

@end
