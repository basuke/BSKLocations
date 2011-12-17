//
//  TargetArea.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface TargetArea : NSObject<MKAnnotation>

- (id)initWithRegion:(CLRegion *)region title:(NSString *)title;

@property(retain, nonatomic) CLRegion *region;
@property(retain, nonatomic) MKCircle *overlay;

@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *subtitle;

@end
