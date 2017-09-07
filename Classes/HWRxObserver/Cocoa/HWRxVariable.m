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

@property (nonatomic, strong) NSArray *cacheData;
@property (nonatomic, strong) NSMutableArray *data;
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
        _data = @[].mutableCopy;
        _observer = HWRxInstance.create(NSStringFromClass([self class])).observeOn(HWMainQueue);
    }
    return self;
}

- (NSArray *)content {
    return _cacheData;
}

#pragma mark - Private
- (void)postNextWithLocation:(NSUInteger)location type:(HWVariableChangeType)type {
    _cacheData = _data.copy;
    _observer.next(HWVariableSquenceInit(self.data, location, type));
}

#pragma mark - Public
- (id)objectAtIndex:(NSUInteger)index {
    if (index < _data.count) {
        return [_data objectAtIndex:index];
    }
    return nil;
}

- (NSUInteger)count {
    return _data.count;
}

- (void)addObject:(id)object {
    if (!object) {
        return;
    }
    [_data addObject:object];
    [self postNextWithLocation:(self.data.count - 1) type:HWVariableChangeType_Add];
}

- (void)removeObject:(id)object {
    if (!object || ![_data containsObject:object]) {
        return;
    }
    NSUInteger index = [_data indexOfObject:object];
    [_data removeObject:object];
    [self postNextWithLocation:index type:HWVariableChangeType_Remove];
}

- (void)reloadObject:(NSArray *)objects {
    if (!objects) {
        objects = @[];
    }
    _data = objects.mutableCopy;
    [self postNextWithLocation:NSUIntegerMax type:HWVariableChangeType_Reload];
}

- (void)replaceByObject:(id)object select:(refreshCallBack)callBack {
    NSMutableArray *newContent = _data.mutableCopy;
    _data.forEachWithIndex(HW_BLOCK(id, NSUInteger) {
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
    index = MAX(0, MIN(index, _data.count));
    [_data insertObject:object atIndex:index];
    [self postNextWithLocation:index type:HWVariableChangeType_Add];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (_data.count <= index) {
        return;
    }
    [_data removeObjectAtIndex:index];
    [self postNextWithLocation:index type:HWVariableChangeType_Remove];
}

@end

@implementation HWVariableSequence

@end
