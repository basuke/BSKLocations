//
//  LoggerViewController.m
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoggerViewController.h"
#import "BSKLocationManager.h"
#import "LocationLogger.h"
#import "LocationEvent.h"

@interface LoggerViewController()<LocationLoggerDelegate> {
	LocationLogger *logger;
}

@end

@implementation LoggerViewController

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

@end
