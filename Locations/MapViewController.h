//
//  MapViewController.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate>

@property(assign, nonatomic) IBOutlet MKMapView *mainMapView;

@end
