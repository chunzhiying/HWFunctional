//
//  UITableView+RxDataSource.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/4.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWRxVariable.h"

typedef UITableViewCell *(^ConfigureCellCallBack)();
typedef void (^CellForRowCallBack)(id cell, id data, NSIndexPath *);


@interface HWRxTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, readonly) HWRxTableDataSource *(^bindTo)(NSArray<HWRxVariable *> *);
@property (nonatomic, readonly) HWRxTableDataSource *(^configureCell)(NSString *reusableId, ConfigureCellCallBack);
@property (nonatomic, readonly) HWRxTableDataSource *(^cellForItem)(CellForRowCallBack);

@property (nonatomic, readonly) HWRxTableDataSource *(^error)(void(^)(NSString *));

@end


@interface HWRxTableDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, readonly) HWRxTableDelegate *(^heightForRow)(float(^)(NSIndexPath *));
@property (nonatomic, readonly) HWRxTableDelegate *(^viewForHeader)(UIView *(^)(NSUInteger)); //frame.height for heightForHeader
@property (nonatomic, readonly) HWRxTableDelegate *(^viewForFooter)(UIView *(^)(NSUInteger)); //frame.height for heightForFooter
@property (nonatomic, readonly) HWRxTableDelegate *(^cellSelected)(void(^)(NSIndexPath *));

@end


@interface UITableView (HWRxTableDataSource)

@property (nonatomic, readonly) HWRxTableDataSource *(^RxDataSource)();
@property (nonatomic, readonly) HWRxTableDelegate *(^RxDelegate)();

@end
