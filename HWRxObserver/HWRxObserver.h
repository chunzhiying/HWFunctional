//
//  HWRxObserver.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HWFunctionalType.h"

@class HWRxObserver;

typedef void(^nextBlankType)();
typedef void(^nextType)(id obj);


@interface HWRxObserver : NSObject <HWFunctionalType>

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, strong) NSString *disposer;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, assign) SEL tapAction;

- (void)registeredToObserve:(NSObject *)object;

@end


@interface HWRxObserver (Base_Extension)

@property (nonatomic, readonly) HWRxObserver *(^subscribe)(nextType);
@property (nonatomic, readonly) HWRxObserver *(^response)(nextBlankType); //not response to startWith

@property (nonatomic, readonly) HWRxObserver *(^bindTo)(id object, NSString *keyPath);
@property (nonatomic, readonly) HWRxObserver *(^disposeBy)(NSObject *);

@property (nonatomic, readonly) HWRxObserver *(^debounce)(CGFloat value); // received, then wait value seconds.
@property (nonatomic, readonly) HWRxObserver *(^throttle)(CGFloat value); // after value seconds, then received.
@property (nonatomic, readonly) HWRxObserver *(^startWith)(id object);

@property (nonatomic, readonly) HWRxObserver *(^behavior)(); // receive data when connect()
@property (nonatomic, readonly) HWRxObserver *(^connect)();
@property (nonatomic, readonly) HWRxObserver *(^disconnect)();

@property (nonatomic, readonly) HWRxObserver *(^takeUntil)(HWRxObserver *);

@end


@interface HWRxObserver (Functional_Extension) //return NEW observer

@property (nonatomic, readonly) HWRxObserver *(^map)(mapType);
@property (nonatomic, readonly) HWRxObserver *(^filter)(filterType);
@property (nonatomic, readonly) HWRxObserver *(^reduce)(id, reduceType);
@property (nonatomic, readonly) HWRxObserver *(^distinctUntilChanged)();

@end


@interface NSArray (RxObserver_Extension) //return NEW observer

@property (nonatomic, readonly) HWRxObserver *merge;
@property (nonatomic, readonly) HWRxObserver *combineLatest;

@end
