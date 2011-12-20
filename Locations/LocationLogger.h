//
//  LocationLogger.h
//  Locations
//
//  Created by 鈴木 陽介 on 11/12/20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationLogger, LocationEvent;

@protocol LocationLoggerDelegate <NSObject>

- (void)locationLogger:(LocationLogger *)logger eventDidAdd:(LocationEvent *)event atIndexes:(NSIndexSet *)indexes;

@end

@interface LocationLogger : NSObject

@property(nonatomic, assign) id<LocationLoggerDelegate> delegate;

- (NSInteger)count;
- (LocationEvent *)eventAtIndex:(NSInteger)index;
- (void)removeAllEvents;

@end
