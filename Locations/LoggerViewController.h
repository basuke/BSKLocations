//
//  LoggerViewController.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoggerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(assign, nonatomic) IBOutlet UITableView *loggerView;

@end