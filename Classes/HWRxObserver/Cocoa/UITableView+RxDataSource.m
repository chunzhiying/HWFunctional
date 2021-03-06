//
//  UITableView+RxDataSource.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/4.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "UITableView+RxDataSource.h"
#import "NSArray+FunctionalType.h"
#import "HWMacro.h"
#import <objc/runtime.h>

#define Error(error) [NSString stringWithFormat:@"HWRxDataSource Error: %@ ", error]
#define ErrorCallBack SafeBlock(self.warningBlock, Error(([NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__])));

@interface HWRxTableDataSource ()
{
    UITableViewRowAnimation _insertAni;
    UITableViewRowAnimation _deleteAni;
    UITableViewRowAnimation _reloadAni;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSArray *> *content;
@property (nonatomic, strong) NSArray<NSString *> *dequeueReusableIds;

@property (nonatomic, copy) TableCellForRowCallBack cellForRowBlock;
@property (nonatomic, copy) void(^warningBlock)(NSString *);

@end

@implementation HWRxTableDataSource

- (instancetype)init {
    if (self = [super init]) {
        _insertAni = UITableViewRowAnimationFade;
        _deleteAni = UITableViewRowAnimationFade;
        _reloadAni = UITableViewRowAnimationFade;
    }
    return self;
}

- (void)dealloc {
    _tableView.dataSource = nil;
}

#pragma mark - Private
- (void)reloadData:(HWVariableSequence *)sequence effectSection:(NSUInteger)section {
    _content[section] = sequence.content;
    
    [_tableView beginUpdates];
    switch (sequence.type) {
        case HWVariableChangeType_Add:
            [_tableView insertRowsAtIndexPaths:sequence.locations.map(HW_BLOCK(HWUIntegerNumber *) {
                return [NSIndexPath indexPathForRow:$0.unsignedIntegerValue inSection:section];
            }) withRowAnimation:_insertAni];
            break;
            
        case HWVariableChangeType_Remove:
            [_tableView deleteRowsAtIndexPaths:sequence.locations.map(HW_BLOCK(HWUIntegerNumber *) {
                return [NSIndexPath indexPathForRow:$0.unsignedIntegerValue inSection:section];
            }) withRowAnimation:_deleteAni];
            break;
            
        case HWVariableChangeType_Reload:
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                      withRowAnimation:_reloadAni];
            break;
    }
    [_tableView endUpdates];
}

#pragma mark - Public
- (HWRxTableDataSource * _Nonnull (^)(UITableViewRowAnimation))insertAnimation {
    return ^(UITableViewRowAnimation animation) {
        _insertAni = animation;
        return self;
    };
}

- (HWRxTableDataSource * _Nonnull (^)(UITableViewRowAnimation))deleteAnimation {
    return ^(UITableViewRowAnimation animation) {
        _deleteAni = animation;
        return self;
    };
}

- (HWRxTableDataSource * _Nonnull (^)(UITableViewRowAnimation))reloadAnimation {
    return ^(UITableViewRowAnimation animation) {
        _reloadAni = animation;
        return self;
    };
}

- (HWRxTableDataSource *(^)(void (^)(NSString *)))warnings {
    return ^(void (^callBack)(NSString *)) {
        self.warningBlock = callBack;
        return self;
    };
}

- (HWRxTableDataSource *(^)(NSArray<HWRxVariable *> *))bindTo {
    return ^(NSArray<HWRxVariable *> *variable) { Weakify(self)
        
        self.content = variable.map(HW_BLOCK(HWRxVariable *) {
            return [$0 content];
        }).mutate();
        
        variable.forEachWithIndex(HW_BLOCK(HWRxVariable *, NSUInteger) {
            $0.observer.subscribe(^(HWVariableSequence *sequence) { Strongify(self)
                [self reloadData:sequence effectSection:$1];
            });
        });
        [self.tableView reloadData];
        return self;
    };
}

- (HWRxTableDataSource *(^)(TableCellForRowCallBack))cellForItem {
    return ^(TableCellForRowCallBack callBack) {
        self.cellForRowBlock = callBack;
        return self;
    };
}

- (HWRxTableDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull))setReusableIds {
    return ^(NSArray<NSString *> *reusableIds) {
        self.dequeueReusableIds = reusableIds;
        return self;
    };
}

- (HWRxTableDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull))registerClass {
    return ^(NSArray<NSString *> *reusableIds) {
        self.dequeueReusableIds = reusableIds;
        for (NSString *reusableId in reusableIds) {
            [_tableView registerClass:NSClassFromString(reusableId)
               forCellReuseIdentifier:reusableId];
        }
        return self;
    };
}

- (HWRxTableDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull))registerNibDefault {
    return ^(NSArray<NSString *> *reusableIds) {
        self.dequeueReusableIds = reusableIds;
        for (NSString *reusableId in reusableIds) {
            [_tableView registerNib:[UINib nibWithNibName:reusableId bundle:nil]
             forCellReuseIdentifier:reusableId];
        }
        return self;
    };
}

- (HWRxTableDataSource * _Nonnull (^)(NSArray<NSString *> * _Nonnull, NSArray<UINib *> * _Nonnull))registerNib {
    return ^(NSArray<NSString *> *reusableIds,  NSArray<UINib *> *nibs) {
        NSAssert(reusableIds.count == nibs.count,
                 Error(@"reusableIds.count not equal to nibs.count"));
        
        self.dequeueReusableIds = reusableIds;
        for (NSInteger i = 0; i < reusableIds.count; i++) {
            [_tableView registerNib:nibs[i]
             forCellReuseIdentifier:reusableIds[i]];
        }
        return self;
    };
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.content.count == 0 || ![self.content.firstObject isKindOfClass:[NSArray class]]) { ErrorCallBack
        return 0;
    }
    return self.content.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= self.content.count || ![self.content[section] isKindOfClass:[NSArray class]]) { ErrorCallBack
        return 0;
    }
    return self.content[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.content.count
        || indexPath.row >= self.content[indexPath.section].count
        || 0 == self.dequeueReusableIds.count ) { ErrorCallBack
        return [UITableViewCell new];
    }

    NSUInteger index = MIN(indexPath.section, self.dequeueReusableIds.count - 1);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.dequeueReusableIds[index]
                                                            forIndexPath:indexPath];
    SafeBlock(self.cellForRowBlock, cell, self.content[indexPath.section][indexPath.row], indexPath);
    return cell;
}

@end



@interface HWRxTableDelegate ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<UITableViewDelegate> bridge;

@property (nonatomic, copy) void(^cellSelectedBlock)(id, NSIndexPath *);
@property (nonatomic, copy) float(^heightForRowBlock)(id, NSIndexPath *);

@end

@implementation HWRxTableDelegate

- (void)dealloc {
    _tableView.delegate = nil;
}

#pragma mark - Public
- (HWRxTableDelegate *(^)(void (^)(id, NSIndexPath *)))cellSelected {
    return ^(void (^callBack)(id, NSIndexPath *)) {
        self.cellSelectedBlock = callBack;
        return self;
    };
}

- (HWRxTableDelegate *(^)(float (^)(id, NSIndexPath *)))heightForRow {
    return ^(float (^callBack)(id, NSIndexPath *)) {
        self.heightForRowBlock = callBack;
        return self;
    };
}

//- (HWRxTableDelegate * _Nonnull (^)(id<UITableViewDelegate> _Nonnull))bridgeTo {
//    return ^(id<UITableViewDelegate> bridge) {
//        [self handleBridge:bridge];
//        return self;
//    };
//}

#pragma mark - Helper
static id getRowDataFor(UITableView *tableView, NSIndexPath *indexPath) {
    NSArray<NSArray *> *array = tableView.RxDataSource().content;
    if (array.count > indexPath.section && array[indexPath.section].count > indexPath.row) {
        return array[indexPath.section][indexPath.row];
    }
    return nil;
}

//- (void)handleBridge:(id<UITableViewDelegate>)bridge {
//    if (!bridge) {
//        return;
//    }
//    self.bridge = bridge;
//    self.tableView.delegate = bridge;
//
//    if (![bridge respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]
//        && self.cellSelectedBlock) {
//        [self bridgeAddMethod:@selector(tableView:didSelectRowAtIndexPath:)];
//    }
//
//    if (![bridge respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]
//        && self.heightForRowBlock) {
//        [self bridgeAddMethod:@selector(tableView:heightForRowAtIndexPath:)];
//    }
//}
//
//- (void)bridgeAddMethod:(SEL)sel {
//    Method method = class_getInstanceMethod([self class], sel);
//    class_addMethod([_bridge class],
//                    sel,
//                    method_getImplementation(method),
//                    method_getTypeEncoding(method));
//}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SafeBlock(tableView.RxDelegate().cellSelectedBlock,
              getRowDataFor(tableView, indexPath),
              indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SafeBlockDefault(50.f,
                            tableView.RxDelegate().heightForRowBlock,
                            getRowDataFor(tableView, indexPath),
                            indexPath);
}

@end



@implementation UITableView (HWRxTableDataSource)

- (HWRxTableDataSource *(^)())RxDataSource {
    return ^{
        HWRxTableDataSource *dataSource = [self rx_dataSource];
        if (!dataSource) {
            dataSource = [HWRxTableDataSource new].then(HW_BLOCK(HWRxTableDataSource *) {
                $0.tableView = self;
                self.dataSource = $0;
                [self setRx_dataSource:$0];
            });
        }
        return dataSource;
    };
}

- (HWRxTableDelegate *(^)())RxDelegate {
    return ^{
        HWRxTableDelegate *delegate = [self rx_delegate];
        if (!delegate) {
            delegate = [HWRxTableDelegate new].then(HW_BLOCK(HWRxTableDelegate *) {
                $0.tableView = self;
                self.delegate = $0;
                [self setRx_delegate:$0];
            });
        }
        return delegate;
    };
}

#pragma mark -
- (void)setRx_dataSource:(HWRxTableDataSource *)rx_dataSource {
    objc_setAssociatedObject(self, @selector(rx_dataSource), rx_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HWRxTableDataSource *)rx_dataSource {
    return objc_getAssociatedObject(self, @selector(rx_dataSource));
}

- (void)setRx_delegate:(HWRxTableDelegate *)rx_delegate {
    objc_setAssociatedObject(self, @selector(rx_delegate), rx_delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HWRxTableDelegate *)rx_delegate {
    return objc_getAssociatedObject(self, @selector(rx_delegate));
}

@end

