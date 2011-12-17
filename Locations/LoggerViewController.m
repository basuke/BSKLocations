//
//  LoggerViewController.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoggerViewController.h"
#import "BSKLocationManager.h"
#import "LocationEvent.h"

@interface LoggerViewController()

@property(retain, nonatomic) NSMutableArray *events;

@end

@implementation LoggerViewController

@synthesize loggerView=_loggerView;
@synthesize events=_events;

- (void)awakeFromNib {
	self.events = [NSMutableArray arrayWithCapacity:100];
	
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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    self.events = nil;
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	[self.events removeAllObjects];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"LoggerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	
	LocationEvent *event = [_events objectAtIndex:indexPath.row];
	
	NSString *title = [NSString stringWithFormat:@"%@ : %@ %@", [NSDateFormatter localizedStringFromDate:event.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle], event.title, (event.inBackground ? @"( BG)" : @"")];
	
	cell.textLabel.text = title;
	cell.detailTextLabel.text = [event description];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Notifications

- (void)pushEvent:(LocationEvent *)event {
	dispatch_async(dispatch_get_main_queue(), ^{
		[_events insertObject:event atIndex:0];
		
		CGPoint offset = _loggerView.contentOffset;
		[_loggerView reloadData];
		if (offset.y > 0) {
			offset.y += _loggerView.rowHeight;
			_loggerView.contentOffset = offset;
		}
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
