//
//  HWRxTableDataSource.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWRxTableDataSource.h"
#import "NSArray+FunctionalType.h"
#import "HWMacro.h"
#import <objc/runtime.h>

@interface HWRxTableDataSource ()

@property (nonatomic, strong) NSMutableArray<NSArray *> *content;
@property (nonatomic, copy) NSString *dequeueReusableIdentifier;

@property (nonatomic, copy) CellForRowCallBack cellForRowBlock;
@property (nonatomic, copy) ConfigureCellCallBack configureCellBlock;

@property (nonatomic, copy) void(^cellSelectedBlock)(NSIndexPath *);
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

- (HWRxTableDataSource *(^)(void (^)(NSIndexPath *)))cellSelected {
    return ^(void (^callBack)(NSIndexPath *)) {
        self.cellSelectedBlock = callBack;
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
    if (self.content.count == 0 || ![self.content.firstObject isKindOfClass:[NSArray class]]) {
        return 0;
    }
    return self.content.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= self.content.count || ![self.content[section] isKindOfClass:[NSArray class]]) {
        return 0;
    }
    return self.content[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.content.count || indexPath.row >= self.content[indexPath.section].count) {
        return [UITableViewCell new];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.dequeueReusableIdentifier];
    if (!cell) {
        cell = self.configureCellBlock();
    }
    SafeBlock(self.cellForRowBlock, cell, self.content[indexPath.section][indexPath.row], indexPath);
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SafeBlock(self.cellSelectedBlock, indexPath);
}

@end


@implementation UITableView (HWRxTableDataSource)

- (HWRxTableDataSource *(^)())RxDataSource {
    return ^{
        return [HWRxTableDataSource new].then(HW_BLOCK(HWRxTableDataSource *) {
            $0.tableView = self;
            self.dataSource = $0;
            self.delegate = $0;
            [self setRx_dataSource:$0];
        });
    };
}

- (void)setRx_dataSource:(HWRxTableDataSource *)rx_dataSource {
    objc_setAssociatedObject(self, @selector(rx_dataSource), rx_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HWRxTableDataSource *)rx_dataSource {
    return objc_getAssociatedObject(self, @selector(rx_dataSource));
}

@end
