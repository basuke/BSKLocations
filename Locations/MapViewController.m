//
//  MapViewController.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "BSKLocationManager.h"
#import "TargetArea.h"
#import "BSKLocationClient.h"
#import <AVFoundation/AVFoundation.h>

@interface MapViewController() {
	
}

- (void)addRegion:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)playSound;

@end

@implementation MapViewController

@synthesize mainMapView;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *here = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"GoHere4"] style:UIBarButtonItemStyleBordered target:self action:@selector(currentLocation:)] autorelease];
	
	self.navigationItem.leftBarButtonItem = here;
	
	if ([CLLocationManager regionMonitoringAvailable]) {
		UIBarButtonItem *add = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
		add.enabled = YES;
		
		self.navigationItem.rightBarButtonItem = add;
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions

- (void)currentLocation:(id)sender {
	BSKLocationClient *client = [[BSKLocationClient client] retain];
	client.enabled = YES;
	
	self.navigationItem.leftBarButtonItem.enabled = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:BSKLocationManagerDidUpdateToLocationNotification object:nil];
	
	double delayInSeconds = 3.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		self.navigationItem.leftBarButtonItem.enabled = YES;
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:BSKLocationManagerDidUpdateToLocationNotification object:nil];
		
		[client release];
	});
}

- (void)add:(id)sender {
	[self addRegion:100 desiredAccuracy:kCLLocationAccuracyBest];
}

- (void)addRegion:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy {
	// Create a new region based on the center of the map view.
	CLLocationCoordinate2D coord = self.mainMapView.centerCoordinate;
	static NSInteger sequence = 1;
	
	NSString *title = [NSString stringWithFormat:@"#%d (%.4f, %.4f)", sequence++, coord.latitude, coord.longitude];
	
	CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:radius identifier:title];
	[[BSKLocationManager sharedManager] startMonitoringForRegion:region desiredAccuracy:accuracy];
	
	TargetArea *target = [[TargetArea alloc] initWithRegion:region title:title];
	[self.mainMapView addAnnotation:target];
	[self.mainMapView addOverlay:target.overlay];
	
	[target release];
	[region release];
}

- (void)playSound {
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Purr" withExtension:@"aiff"];
	NSError *error = nil;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	if (player) {
		[player play];
		
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[player release];
		});
	}
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {	
	if([annotation isKindOfClass:[TargetArea class]]) {
		NSString *identifier = @"RegionPin";
		
		MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if (view == nil) {
			view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
			view.canShowCallout = YES;
			view.pinColor = MKPinAnnotationColorGreen;
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
			[button sizeToFit];
			
			view.rightCalloutAccessoryView = button;
		}
		
		view.annotation = annotation;
		return view;
	}
	
	return nil;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKCircle class]]) {
		MKCircleView *circleView = [[[MKCircleView alloc] initWithOverlay:overlay] autorelease];
		circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
		circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
		
		return circleView;		
	}
	
	return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	TargetArea *target = (TargetArea *)view.annotation;
	
	[[BSKLocationManager sharedManager] stopMonitoringForRegion:target.region];
	
	[self.mainMapView removeOverlay:target.overlay];
	[self.mainMapView removeAnnotation:target];
}

#pragma mark - notifications

- (void)locationUpdated:(NSNotification *)notification {
	CLLocation *location = [[notification userInfo] objectForKey:BSKLocationManagerLocationUserInfoKey];
	
	CLLocationCoordinate2D center = location.coordinate;
	CLLocationDistance radius = 500;
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, radius, radius);
	[self.mainMapView setRegion:region];
}

- (void)regionDidEnterOrExit:(NSNotification *)notification {
	CLRegion *region = [[notification userInfo] objectForKey:BSKLocationManagerRegionUserInfoKey];
	
	[self.mainMapView setCenterCoordinate:region.center animated:YES];
	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[notification name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self playSound];
	} else {
		UILocalNotification *lc = [[UILocalNotification alloc] init];
		lc.soundName = UILocalNotificationDefaultSoundName;
		lc.alertBody = [notification name];
		[[UIApplication sharedApplication] presentLocalNotificationNow:lc];
	}
}

- (void)authorizationChanged:(NSNotification *)notification {
	UIBarButtonItem *add = self.navigationItem.rightBarButtonItem;
	add.enabled = YES;
}

@end
