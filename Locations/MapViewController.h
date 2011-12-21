//
//  MapViewController.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property(assign, nonatomic) IBOutlet MKMapView *mainMapView;
@property(assign, nonatomic) IBOutlet UITableView *loggerView;

- (IBAction)currentLocation:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)toggleLogger:(id)sender;

@end
