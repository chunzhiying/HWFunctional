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

#define ErrorCallBack SafeBlock(self.errorBlock, [NSString stringWithFormat:@"%s error", __PRETTY_FUNCTION__]);

@interface HWRxTableDataSource ()

@property (nonatomic, strong) NSMutableArray<NSArray *> *content;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *dequeueReusableIdentifier;

@property (nonatomic, copy) CellForRowCallBack cellForRowBlock;
@property (nonatomic, copy) ConfigureCellCallBack configureCellBlock;

@property (nonatomic, copy) void(^errorBlock)(NSString *);

@end

@implementation HWRxTableDataSource

- (void)dealloc {
    
}

#pragma mark - Private
- (void)reloadData:(HWVariableSequence *)sequence effectSection:(NSUInteger)section {
    self.content[section] = sequence.content;
    switch (sequence.type) {
        case HWVariableChangeType_Add:
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sequence.location inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
            break;
        case HWVariableChangeType_Remove:
            [_tableView beginUpdates];
            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sequence.location inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
            break;
        case HWVariableChangeType_Reload:
            [self.tableView reloadData];
            break;
    }
}

#pragma mark - Public
- (HWRxTableDataSource *(^)(NSArray<HWRxVariable *> *))bindTo {
    return ^(NSArray<HWRxVariable *> *variable) { Weakify(self)
        
        self.content = variable.map(HW_BLOCK(HWRxVariable *) {
            return [$0 convert];
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

- (HWRxTableDataSource *(^)(CellForRowCallBack))cellForItem {
    return ^(CellForRowCallBack callBack) {
        self.cellForRowBlock = callBack;
        return self;
    };
}

- (HWRxTableDataSource *(^)(NSString *, ConfigureCellCallBack))configureCell {
    return ^(NSString *reusableId, ConfigureCellCallBack callBack) {
        self.dequeueReusableIdentifier = reusableId;
        self.configureCellBlock = callBack;
        return self;
    };
}

- (HWRxTableDataSource *(^)(void (^)(NSString *)))error {
    return ^(void (^callBack)(NSString *)) {
        self.errorBlock = callBack;
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
    if (indexPath.section >= self.content.count || indexPath.row >= self.content[indexPath.section].count) { ErrorCallBack
        return [UITableViewCell new];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.dequeueReusableIdentifier];
    if (!cell) {
        cell = SafeBlockDefault([UITableViewCell new], self.configureCellBlock);
    }
    SafeBlock(self.cellForRowBlock, cell, self.content[indexPath.section][indexPath.row], indexPath);
    return cell;
}

@end



@interface HWRxTableDelegate ()

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, copy) void(^cellSelectedBlock)(NSIndexPath *);
@property (nonatomic, copy) float(^heightForRowBlock)(NSIndexPath *);

@property (nonatomic, copy) UIView *(^viewForHeaderBlock)(NSUInteger);
@property (nonatomic, copy) UIView *(^viewForFooterBlock)(NSUInteger);

@end

@implementation HWRxTableDelegate

#pragma mark - Public
- (HWRxTableDelegate *(^)(void (^)(NSIndexPath *)))cellSelected {
    return ^(void (^callBack)(NSIndexPath *)) {
        self.cellSelectedBlock = callBack;
        return self;
    };
}

- (HWRxTableDelegate *(^)(float (^)(NSIndexPath *)))heightForRow {
    return ^(float (^callBack)(NSIndexPath *)) {
        self.heightForRowBlock = callBack;
        return self;
    };
}

- (HWRxTableDelegate *(^)(UIView *(^)(NSUInteger)))viewForHeader {
    return ^(UIView *(^callBack)(NSUInteger)) {
        self.viewForHeaderBlock = callBack;
        return self;
    };
}

- (HWRxTableDelegate *(^)(UIView *(^)(NSUInteger)))viewForFooter {
    return ^(UIView *(^callBack)(NSUInteger)) {
        self.viewForFooterBlock = callBack;
        return self;
    };
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SafeBlock(self.cellSelectedBlock, indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SafeBlockDefault(50.f, self.heightForRowBlock, indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *header = SafeBlockDefault([UIView new], self.viewForHeaderBlock, section);
    return header.bounds.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    UIView *header = SafeBlockDefault([UIView new], self.viewForFooterBlock, section);
    return header.bounds.size.height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return SafeBlockDefault([UIView new], self.viewForHeaderBlock, section);
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return SafeBlockDefault([UIView new], self.viewForFooterBlock, section);
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
