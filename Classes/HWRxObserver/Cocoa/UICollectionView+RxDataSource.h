//
//  UICollectionView+RxDataSource.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/8.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWRxVariable.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CollectionCellForRowCallBack)(id cell, id data, NSIndexPath *);

@interface HWRxCollectionDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong, readonly) NSArray<NSArray *> *content;

@property (nonatomic, readonly) HWRxCollectionDataSource *(^cellForItem)(CollectionCellForRowCallBack);

//use when cell created by tableView in storyboard (no need to register)
@property (nonatomic, readonly) HWRxCollectionDataSource *(^setReusableIds)(NSArray<NSString *>*reusableIds);

// class name equal to reusableId
// nib name equal to reusableId、main bundle
@property (nonatomic, readonly) HWRxCollectionDataSource *(^registerClass)(NSArray<NSString *>*reusableIds);
@property (nonatomic, readonly) HWRxCollectionDataSource *(^registerNib)(NSArray<NSString *>*reusableIds, NSArray<UINib *> *nibs);
@property (nonatomic, readonly) HWRxCollectionDataSource *(^registerNibDefault)(NSArray<NSString *>*reusableIds);

// the last step should be bind
@property (nonatomic, readonly) HWRxCollectionDataSource *(^bindTo)(NSArray<HWRxVariable *> *);
@property (nonatomic, readonly) HWRxCollectionDataSource *(^warnings)(void(^)(NSString *));

@end


@interface UICollectionView (HWRxCollectionDataSource)

@property (nonatomic, readonly) HWRxCollectionDataSource *(^RxDataSource)();

@end

NS_ASSUME_NONNULL_END
