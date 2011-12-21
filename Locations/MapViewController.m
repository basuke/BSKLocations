//
//  MapViewController.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "BSKLocationManager.h"
#import "BSKLocationClient.h"
#import "TargetArea.h"
#import "LocationLogger.h"
#import "LocationEvent.h"
#import "SettingsViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface MapViewController()<LocationLoggerDelegate, ModalViewControllerDelegate> {
	LocationLogger *logger;
}

- (void)addRegion:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)playSound;

@end

@implementation MapViewController

@synthesize mainMapView=_mainMapView;
@synthesize loggerView=_loggerView;

- (void)awakeFromNib {
	logger = [[LocationLogger alloc] init];
	logger.delegate = self;
}

- (void)dealloc {
    [logger release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	[logger removeAllEvents];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CAGradientLayer *shade = [CAGradientLayer layer];
	CGRect r = self.loggerView.frame;
	CGFloat px = 1.0 / r.size.height;
	shade.frame = r;
	shade.locations = [NSArray arrayWithObjects:
					   [NSNumber numberWithFloat:0.0], 
					   [NSNumber numberWithFloat:0.5 * px], 
					   [NSNumber numberWithFloat:1.0 * px], 
					   [NSNumber numberWithFloat:10.0 * px], 
					   [NSNumber numberWithFloat:(r.size.height - 10.0) * px], 
					   [NSNumber numberWithFloat:1.0], 
					   nil];
	shade.colors = [NSArray arrayWithObjects:
					(id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor, 
					(id)[UIColor colorWithWhite:0.0 alpha:0.7].CGColor, 
					(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, 
					(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor, 
					(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor, 
					(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, 
					nil];
	[self.view.layer addSublayer:shade];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionDidEnterOrExit:) name:BSKLocationManagerDidEnterRegionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionDidEnterOrExit:) name:BSKLocationManagerDidExitRegionNotification object:nil];
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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

- (IBAction)currentLocation:(id)sender {
	BSKLocationClient *client = [[BSKLocationClient client] retain];
	client.enabled = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:BSKLocationManagerDidUpdateToLocationNotification object:nil];
	
	double delayInSeconds = 3.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:BSKLocationManagerDidUpdateToLocationNotification object:nil];
		
		[client release];
	});
}

- (IBAction)add:(id)sender {
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

- (IBAction)openSettings:(id)sender {
	SettingsViewController *controller = [[SettingsViewController alloc] init];
	controller.delegate = self;
	
	UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
	
	[self presentModalViewController:navi animated:YES];
	
	[navi release];
	[controller release];
}

- (IBAction)toggleLogger:(id)sender {
	
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
		lc.soundName = @"Purr.aiff";
		lc.alertBody = [notification name];
		[[UIApplication sharedApplication] presentLocalNotificationNow:lc];
		[lc release];
	}
}

- (void)authorizationChanged:(NSNotification *)notification {
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [logger count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"LoggerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	
	LocationEvent *event = [logger eventAtIndex:indexPath.row];
	
	NSString *title = [NSString stringWithFormat:@"%@ : %@ %@", [NSDateFormatter localizedStringFromDate:event.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle], event.title, (event.inBackground ? @"( BG)" : @"")];
	
	cell.textLabel.text = title;
	cell.detailTextLabel.text = [event description];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - LocationLoggerDelegate

- (void)locationLogger:(LocationLogger *)logger eventDidAdd:(LocationEvent *)event atIndexes:(NSIndexSet *)indexes {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_loggerView) {
			CGPoint offset = _loggerView.contentOffset;
			
			[_loggerView reloadData];
			
			if (offset.y > 0) {
				offset.y += _loggerView.rowHeight;
				_loggerView.contentOffset = offset;
			}
		}
	});
}

#pragma mark - ModalViewControllerDelegate

- (void)viewControllerDidFinish:(UIViewController *)viewController {
	[self dismissModalViewControllerAnimated:YES];
}

@end
