//
//  UITableView+RxDataSource.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/4.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWRxVariable.h"

NS_ASSUME_NONNULL_BEGIN

typedef UITableViewCell * _Nonnull (^ConfigureCellCallBack)(NSUInteger section);
typedef void (^CellForRowCallBack)(id cell, id data, NSIndexPath *);

@interface HWRxTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) NSArray<NSArray *> *content;

@property (nonatomic, readonly) HWRxTableDataSource *(^bindTo)(NSArray<HWRxVariable *> *); // the last step should be bind
@property (nonatomic, readonly) HWRxTableDataSource *(^configureCell)(NSArray<NSString *> *reusableIds, ConfigureCellCallBack);
@property (nonatomic, readonly) HWRxTableDataSource *(^cellForItem)(CellForRowCallBack);

@property (nonatomic, readonly) HWRxTableDataSource *(^warnings)(void(^)(NSString *));

@end


@interface HWRxTableDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, readonly) HWRxTableDelegate *(^cellSelected)(void(^)(id data, NSIndexPath *));
@property (nonatomic, readonly) HWRxTableDelegate *(^heightForRow)(float(^)(id data, NSIndexPath *));
@property (nonatomic, readonly) HWRxTableDelegate *(^viewForHeader)(UIView *(^)(NSUInteger)); //frame.height for heightForHeader
@property (nonatomic, readonly) HWRxTableDelegate *(^viewForFooter)(UIView *(^)(NSUInteger)); //frame.height for heightForFooter

@end


@interface UITableView (HWRxTableDataSource)

@property (nonatomic, readonly) HWRxTableDataSource *(^RxDataSource)();
@property (nonatomic, readonly) HWRxTableDelegate *(^RxDelegate)();

@end

NS_ASSUME_NONNULL_END
