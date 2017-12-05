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

typedef void (^TableCellForRowCallBack)(id cell, id data, NSIndexPath *);

@interface HWRxTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) NSArray<NSArray *> *content;

@property (nonatomic, readonly) HWRxTableDataSource *(^cellForItem)(TableCellForRowCallBack);

// class name equal to reusableId
// nib name equal to reusableId、main bundle
@property (nonatomic, readonly) HWRxTableDataSource *(^registerClass)(NSArray<NSString *>*reusableIds);
@property (nonatomic, readonly) HWRxTableDataSource *(^registerNibDefault)(NSArray<NSString *>*reusableIds);
@property (nonatomic, readonly) HWRxTableDataSource *(^registerNib)(NSArray<NSString *>*reusableIds, NSArray<UINib *> *nibs);

// Default: UITableViewRowAnimationFade
@property (nonatomic, readonly) HWRxTableDataSource *(^insertAnimation)(UITableViewRowAnimation);
@property (nonatomic, readonly) HWRxTableDataSource *(^deleteAnimation)(UITableViewRowAnimation);
@property (nonatomic, readonly) HWRxTableDataSource *(^reloadAnimation)(UITableViewRowAnimation);

// Bind at last
@property (nonatomic, readonly) HWRxTableDataSource *(^bindTo)(NSArray<HWRxVariable *> *);
@property (nonatomic, readonly) HWRxTableDataSource *(^warnings)(void(^)(NSString *));

@end


@interface HWRxTableDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, readonly) HWRxTableDelegate *(^cellSelected)(void(^)(id data, NSIndexPath *));
@property (nonatomic, readonly) HWRxTableDelegate *(^heightForRow)(float(^)(id data, NSIndexPath *));

@property (nonatomic, readonly) HWRxTableDelegate *(^bridgeTo)(id<UITableViewDelegate>);

@end


@interface UITableView (HWRxTableDataSource)

@property (nonatomic, readonly) HWRxTableDataSource *(^RxDataSource)();
@property (nonatomic, readonly) HWRxTableDelegate *(^RxDelegate)();

@end

NS_ASSUME_NONNULL_END
