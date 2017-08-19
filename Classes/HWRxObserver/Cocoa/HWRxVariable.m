//
//  HWRxVariable.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWRxVariable.h"
#import "HWMacro.h"
#import "NSArray+FunctionalType.h"

static  HWVariableSequence * HWVariableSquenceInit(NSArray *array, NSUInteger index, HWVariableChangeType type) {
    return [HWVariableSequence new].then(HW_BLOCK(HWVariableSequence *) {
        $0.content = array;
        $0.location = index;
        $0.type = type;
    });
}

@interface HWRxVariable ()

@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) HWRxObserver *observer;

@end

@implementation HWRxVariable

+ (instancetype)variable:(NSArray *)array {
    HWRxVariable *variable = [HWRxVariable new];
    [variable reloadObject:array];
    return variable;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _content = @[].mutableCopy;
        _observer = HWRxInstance.create(NSStringFromClass([self class]));
    }
    return self;
}

- (NSArray *)convert {
    return _content;
}


#pragma mark - Private
- (void)postNextWithLocation:(NSUInteger)location type:(HWVariableChangeType)type {
    _observer.next(HWVariableSquenceInit(self.content, location, type));
}

#pragma mark - Public
- (id)objectAtIndex:(NSUInteger)index {
    if (index < _content.count) {
        return [_content objectAtIndex:index];
    }
    return nil;
}

- (NSUInteger)count {
    return _content.count;
}

- (void)addObject:(id)object {
    if (!object) {
        return;
    }
    [_content addObject:object];
    [self postNextWithLocation:(self.content.count - 1) type:HWVariableChangeType_Add];
}

- (void)removeObject:(id)object {
    if (!object || ![_content containsObject:object]) {
        return;
    }
    NSUInteger index = [_content indexOfObject:object];
    [_content removeObject:object];
    [self postNextWithLocation:index type:HWVariableChangeType_Remove];
}

- (void)reloadObject:(NSArray *)objects {
    if (!objects) {
        objects = @[];
    }
    _content = objects.mutableCopy;
    [self postNextWithLocation:NSUIntegerMax type:HWVariableChangeType_Reload];
}

- (void)replaceByObject:(id)object select:(refreshCallBack)callBack {
    NSMutableArray *newContent = _content.mutableCopy;
    _content.forEachWithIndex(HW_BLOCK(id, NSUInteger) {
        if (callBack($0, $1)) {
            [newContent removeObjectAtIndex:$1];
            [newContent insertObject:object atIndex:$1];
        }
    });
    [self reloadObject:newContent];
}

#pragma mark - 
- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    if (!object) {
        return;
    }
    index = MAX(0, MIN(index, _content.count));
    [_content insertObject:object atIndex:index];
    [self postNextWithLocation:index type:HWVariableChangeType_Add];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (_content.count <= index) {
        return;
    }
    [_content removeObjectAtIndex:index];
    [self postNextWithLocation:index type:HWVariableChangeType_Remove];
}

@end

@implementation HWVariableSequence

@end
