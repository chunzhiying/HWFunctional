//
//  UICollectionView+RxDataSource.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/8.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "UICollectionView+RxDataSource.h"
#import "NSArray+FunctionalType.h"
#import "HWMacro.h"
#import <objc/runtime.h>

#define HWError(error) [NSString stringWithFormat:@"HWRxDataSource Error: %@ ", error]
#define ErrorCallBack SafeBlock(self.warningBlock, HWError(([NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__])));

@interface HWRxCollectionDataSource ()

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<NSArray *> *content;
@property (nonatomic, strong) NSArray<NSString *> *dequeueReusableIds;

@property (nonatomic, copy) CollectionCellForRowCallBack cellForRowBlock;
@property (nonatomic, copy) void(^warningBlock)(NSString *);

@end

@implementation HWRxCollectionDataSource

- (void)dealloc {
    
}

#pragma mark - Private
- (void)reloadData:(HWVariableSequence *)sequence effectSection:(NSUInteger)section {
    _content[section] = sequence.content;
    [self.collectionView reloadData];
}

#pragma mark - Public
- (HWRxCollectionDataSource *(^)(void (^)(NSString *)))warnings {
    return ^(void (^callBack)(NSString *)) {
        self.warningBlock = callBack;
        return self;
    };
}

- (HWRxCollectionDataSource *(^)(NSArray<HWRxVariable *> *))bindTo {
    return ^(NSArray<HWRxVariable *> *variable) { Weakify(self)
        NSAssert(variable.count == self.dequeueReusableIds.count, HWError(@"dataSource.count not equal to cell reusableIDs.count"));
        
        self.content = variable.map(HW_BLOCK(HWRxVariable *) {
            return [$0 content];
        }).mutate();
        
        variable.forEachWithIndex(HW_BLOCK(HWRxVariable *, NSUInteger) {
            $0.observer.subscribe(^(HWVariableSequence *sequence) { Strongify(self)
                [self reloadData:sequence effectSection:$1];
            });
        });
        [self.collectionView reloadData];
        return self;
    };
}

- (HWRxCollectionDataSource *(^)(CollectionCellForRowCallBack))cellForItem {
    return ^(CollectionCellForRowCallBack callBack) {
        self.cellForRowBlock = callBack;
        return self;
    };
}

- (HWRxCollectionDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull))registerClass {
    return ^(NSArray<NSString *> *reusableIds) {
        self.dequeueReusableIds = reusableIds;
        for (NSString *reusableId in reusableIds) {
            [self.collectionView registerClass:NSClassFromString(reusableId) forCellWithReuseIdentifier:reusableId];
        }
        return self;
    };
}

- (HWRxCollectionDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull))registerNibDefault {
    return ^(NSArray<NSString *> *reusableIds) {
        self.dequeueReusableIds = reusableIds;
        for (NSString *reusableId in reusableIds) {
            [self.collectionView registerNib:[UINib nibWithNibName:reusableId bundle:nil] forCellWithReuseIdentifier:reusableId];
        }
        return self;
    };
}

- (HWRxCollectionDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull, NSArray<UINib *> * _Nonnull))registerNib {
    return ^(NSArray<NSString *> *reusableIds,  NSArray<UINib *> *nibs) {
        NSAssert(reusableIds.count == nibs.count, HWError(@"reusableIds.count not equal to nibs.count"));
        
        self.dequeueReusableIds = reusableIds;
        for (NSInteger i = 0; i < reusableIds.count; i++) {
            [self.collectionView registerNib:nibs[i] forCellWithReuseIdentifier:reusableIds[i]];
        }
        return self;
    };
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.content.count == 0 || ![self.content.firstObject isKindOfClass:[NSArray class]]) { ErrorCallBack
        return 0;
    }
    return self.content.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section >= self.content.count || ![self.content[section] isKindOfClass:[NSArray class]]) { ErrorCallBack
        return 0;
    }
    return self.content[section].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.content.count
        || indexPath.item >= self.content[indexPath.section].count) { ErrorCallBack
        return [UICollectionViewCell new];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.dequeueReusableIds[indexPath.section] forIndexPath:indexPath];
    SafeBlock(self.cellForRowBlock, cell, self.content[indexPath.section][indexPath.item], indexPath);
    return cell;
}

@end



@implementation UICollectionView (HWRxCollectionDataSource)

- (HWRxCollectionDataSource *(^)())RxDataSource {
    return ^{
        HWRxCollectionDataSource *dataSource = [self rx_dataSource];
        if (!dataSource) {
            dataSource = [HWRxCollectionDataSource new].then(HW_BLOCK(HWRxCollectionDataSource *) {
                $0.collectionView = self;
                self.dataSource = $0;
                [self setRx_dataSource:$0];
            });
        }
        return dataSource;
    };
}

#pragma mark -
- (void)setRx_dataSource:(HWRxCollectionDataSource *)rx_dataSource {
    objc_setAssociatedObject(self, @selector(rx_dataSource), rx_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HWRxCollectionDataSource *)rx_dataSource {
    return objc_getAssociatedObject(self, @selector(rx_dataSource));
}

@end


