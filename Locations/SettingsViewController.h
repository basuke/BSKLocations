//
//  SettingsViewController.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property(assign, nonatomic) IBOutlet UISwitch *locationEnabled;
@property(assign, nonatomic) IBOutlet UISwitch *workInBackground;
@property(assign, nonatomic) IBOutlet UISlider *distanceFilter;
@property(assign, nonatomic) IBOutlet UILabel *distanceFilterLabel;
@property(assign, nonatomic) IBOutlet UISlider *desiredAccuracy;
@property(assign, nonatomic) IBOutlet UILabel *desiredAccuracyLabel;

@property(assign, nonatomic) IBOutlet UILabel *buildInfoLabel;

- (IBAction)locationEnabledChanged:(id)sender;
- (IBAction)workInBackgroundChanged:(id)sender;
- (IBAction)distanceFilterChanged:(id)sender;
- (IBAction)desiredAccuracyChanged:(id)sender;

@end
