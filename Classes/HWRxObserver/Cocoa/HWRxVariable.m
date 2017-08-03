//
//  HWRxVariable.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWRxVariable.h"
#import "HWMacro.h"

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
        _observer = HWRxInstance.asObservable();
    }
    return self;
}

- (NSArray *)convert {
    return _content;
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

- (void)addObject:(id)object { Weakify(self)
    if (!object) {
        return;
    }
    [_content addObject:object];
    _observer.next(^{ Strongify(self)
         return HWVariableSquenceInit(self.content, (self.content.count - 1), HWVariableChangeType_Add);
    });
}

- (void)removeObject:(id)object { Weakify(self)
    if (!object || ![_content containsObject:object]) {
        return;
    }
    NSUInteger index = [_content indexOfObject:object];
    [_content removeObject:object];
    _observer.next(^{ Strongify(self)
        return HWVariableSquenceInit(self.content, index, HWVariableChangeType_Remove);
    });
}

- (void)reloadObject:(NSArray *)objects { Weakify(self)
    if (!objects) {
        objects = @[];
    }
    _content = objects.mutableCopy;
    _observer.next(^{ Strongify(self)
        return HWVariableSquenceInit(self.content, NSUIntegerMax, HWVariableChangeType_Reload);
    });
}

#pragma mark - 
- (void)insertObject:(id)object atIndex:(NSUInteger)index { Weakify(self)
    if (!object) {
        return;
    }
    index = MAX(0, MIN(index, _content.count));
    [_content insertObject:object atIndex:index];
    _observer.next(^{ Strongify(self)
        return HWVariableSquenceInit(self.content, index, HWVariableChangeType_Add);
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index { Weakify(self)
    if (_content.count <= index) {
        return;
    }
    [_content removeObjectAtIndex:index];
    _observer.next(^{ Strongify(self)
        return HWVariableSquenceInit(self.content, index, HWVariableChangeType_Remove);
    });
    
}

@end

@implementation HWVariableSequence

@end
