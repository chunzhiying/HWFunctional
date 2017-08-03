//
//  HWRxTableDataSource.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWRxVariable.h"

typedef UITableViewCell *(^ConfigureCellCallBack)();
typedef void (^CellForRowCallBack)(id cell, id data, NSIndexPath *);


@interface HWRxTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, readonly) HWRxTableDataSource *(^bindTo)(NSArray<HWRxVariable *> *);

@property (nonatomic, readonly) HWRxTableDataSource *(^configureCell)(NSString *reusableId, ConfigureCellCallBack);
@property (nonatomic, readonly) HWRxTableDataSource *(^cellForItem)(CellForRowCallBack);
@property (nonatomic, readonly) HWRxTableDataSource *(^cellSelected)(void(^)(NSIndexPath *));

@property (nonatomic, readonly) HWRxTableDataSource *(^error)(void(^)(NSString *));

@end


@interface UITableView (HWRxTableDataSource)

@property (nonatomic, readonly) HWRxTableDataSource *(^RxDataSource)();

@end
