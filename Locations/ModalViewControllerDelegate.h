//
//  ModalViewControllerDelegate.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModalViewControllerDelegate <NSObject>

@optional

- (void)viewControllerDidFinish:(UIViewController *)viewController;
- (void)viewControllerDidCancel:(UIViewController *)viewController;

@end
