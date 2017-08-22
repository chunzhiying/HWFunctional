//
//  HWRxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWRxObserver.h"
#import <objc/runtime.h>
#import "NSArray+FunctionalType.h"
#import "NSObject+RxObserver.h"

typedef NS_ENUM(NSUInteger, HWRxObserverType) {
    HWRxObserverType_UnKnown, // no such property, observe failed
    HWRxObserverType_UnOwned, // created during Operating. AotuReleased when block over.
    HWRxObserverType_KVO,
    HWRxObserverType_Notification,
    HWRxObserverType_UserDefined,
    HWRxObserverType_Special, //RxObserver_dealloc、RxObserver_tap
};

@interface HWRxObserver ()
{
    HWRxObserverType _type;
    BOOL _connect;
    
    NSObject *_latestData;
    NSMutableArray *_startWithDataAry;
    
    NSMutableArray<nextType> *_nextBlockAry;
    NSMutableArray<nextBlankType> *_nextBlankBlockAry;
    
    BOOL _debounceEnable;
    BOOL _throttleEnable;
    CGFloat _debounceValue;
    CGFloat _throttleValue;
    
    __weak dispatch_queue_t _queue;
}

@property (nonatomic, strong) NSObject *rxObj;
@property (nonatomic, copy) NSString *targetDesc;

@end

@implementation HWRxObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tapAction = @selector(onTap);
        _debounceEnable = YES;
        _throttleEnable = YES;
        _connect        = YES;
        _debounceValue = 0;
        _throttleValue = 0;
        _nextBlockAry       = @[].mutableCopy;
        _nextBlankBlockAry  = @[].mutableCopy;
        _startWithDataAry   = @[].mutableCopy;
        _type = HWRxObserverType_UnOwned;
    }
    return self;
}


- (void)dealloc {
    NSString *key = @"";
    switch (_type) {
        case HWRxObserverType_KVO:
        case HWRxObserverType_Notification:
            key = [NSString stringWithFormat:@"%@.%@", _targetDesc, _keyPath]; break;
        case HWRxObserverType_Special:
        case HWRxObserverType_UserDefined:
            key = [NSString stringWithFormat:@"%@", _keyPath]; break;
        case HWRxObserverType_UnOwned:
            key = @"UnOwned"; break;
        case HWRxObserverType_UnKnown:
            key = [NSString stringWithFormat:@"UnKonwn Error [key : %@]", _keyPath]; break;
    }
    HWLog([HWRxObserver class], @"dealloc, [key : %@]", key);
}

- (void)onTap {
    self.rxObj = @"onTap";
}

- (void)setTarget:(NSObject *)target {
    _target = target;
    self.targetDesc = NSStringFromClass([target class]);
}

- (void)setKeyPath:(NSString *)keyPath {
    _keyPath = keyPath;
    if (_target && class_getProperty([_target class], [keyPath cStringUsingEncoding:NSASCIIStringEncoding])) {
        _latestData = [_target valueForKey:keyPath];
    }
}

- (void)setRxObj:(NSObject *)rxObj {
    
    if (!(_debounceEnable && _throttleEnable && _connect)) {
        return;
    }
    
    _debounceEnable = _debounceValue == 0;
    _throttleEnable = _throttleValue == 0;
    
    if (_debounceValue > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_debounceValue * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           _debounceEnable = YES;
                       });
    }
    
    if (_throttleValue > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_throttleValue * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           _throttleEnable = YES;
                           [self postAllWith:_latestData];
                       });
        return;
    }
    
    [self postAllWith:rxObj];
}

#pragma mark - Post
#define PostToQueue(...) if (_queue) { dispatch_async(_queue, ^{SafeBlock(__VA_ARGS__)}); } else { SafeBlock(__VA_ARGS__) }

- (void)postTo:(nextType)block with:(NSObject *)data {
    if (!data || [data isKindOfClass:[NSNull class]]) {
        data = nil;
    }
    BOOL isStartData = [_startWithDataAry containsObject:data];
    if (isStartData || _connect) {
        PostToQueue(block, data)
    }
}

- (void)postTo:(nextBlankType)block {
    if (!_connect) {
        return;
    }
    PostToQueue(block)
}

- (void)postAllWith:(NSObject *)data {
    _nextBlockAry.forEach(^(nextType block) {
        [self postTo:block with:data];
    });
    _nextBlankBlockAry.forEach(^(nextType block) {
        [self postTo:block];
    });
}

#pragma mark - Register
- (void)registeredToObserve:(NSObject *)object {
    
    _type = HWRxObserverType_UnKnown;
    
    if ([_keyPath isEqualToString:@"RxObserver_dealloc"]
        || [_keyPath isEqualToString:@"RxObserver_tap"])
    {
        _type = HWRxObserverType_Special;
        return;
    }
    
    if ([object isKindOfClass:[NSNotificationCenter class]]) {
        _type = HWRxObserverType_Notification;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNofication:)
                                                     name:self.keyPath object:nil];
        return;
    }
    
    if (class_getProperty([object class], [self.keyPath cStringUsingEncoding:NSASCIIStringEncoding])) {
        _type = HWRxObserverType_KVO;
        [object addObserver:self forKeyPath:self.keyPath
                    options:NSKeyValueObservingOptionNew context:NULL];
        return;
    }
}

#pragma mark - Notification
- (void)onNofication:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo ? notification.userInfo : [NSDictionary new];
    _latestData = userInfo;
    self.rxObj = userInfo;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:_keyPath]) {
        return;
    }
    _latestData = change[@"new"];
    self.rxObj = change[@"new"];
}

@end

@implementation HWRxObserver (Create_Extension)

- (HWRxObserver * _Nonnull (^)(NSString *))create {
    return ^(NSString *desc) {
        if (_type == HWRxObserverType_UnOwned) {
            _type = HWRxObserverType_UserDefined;
            _keyPath = desc;
        }
        return self;
    };
}

- (HWRxObserver * _Nonnull (^)(id))next {
    return ^(id nextObj) {
        if ([nextObj isKindOfClass:NSClassFromString(@"NSBlock")]) {
            NSAssert(NO, @"next obj can't be a block");
        }
        if (nextObj) {
            _latestData = nextObj;
            self.rxObj = nextObj;
        }
        return self;
    };
}

- (HWRxObserver * _Nonnull (^)(NSArray * _Nonnull))of {
    return ^(NSArray *signals) {
        return self
        .create(@"create by [of]")
        .startWith(signals);
    };
}

@end

@implementation HWRxObserver (Base_Extension)

- (HWRxObserver * _Nonnull (^)(dispatch_queue_t _Nonnull))observeOn {
    return ^(dispatch_queue_t queue) {
        _queue = queue;
        return self;
    };
}

- (HWRxObserver *(^)(nextType))subscribe {
    return ^(nextType block) {
        [_nextBlockAry addObject:block];
        _startWithDataAry.forEach(HW_BLOCK(id) {
            [self postTo:block with:$0];
        });
        return self;
    };
}

- (HWRxObserver *(^)(nextBlankType))response {
    return ^(nextBlankType block) {
        [_nextBlankBlockAry addObject:block];
        return self;
    };
}

- (HWRxObserver *(^)(CGFloat))debounce {
    return ^(CGFloat value) {
        _debounceValue = value;
        return self;
    };
}

- (HWRxObserver *(^)(CGFloat))throttle {
    return ^(CGFloat value) {
        _throttleValue = value;
        return self;
    };
}

- (HWRxObserver *(^)(id object, NSString *keyPath))bindTo {
    return ^(id object, NSString *keyPath) {
        Weakify(object)
        self.subscribe(^(id result) {
            Strongify(object)
            [object setValue:result forKey:keyPath];
        });
        return self;
    };
}

- (HWRxObserver *(^)(NSObject *))disposeBy {
    return ^(NSObject *obj) {
        self.disposer = [NSString stringWithFormat:@"%p", obj];
        
        if (!obj.rx_delegateTo_disposers) {
            obj.rx_delegateTo_disposers = [NSMutableArray new];
        }
        [obj.rx_delegateTo_disposers addObject:_target];
        return self;
    };
}

- (HWRxObserver *(^)(NSArray *))startWith {
    return ^(NSArray *data) {
        _startWithDataAry = [[NSMutableArray alloc] initWithArray:data];
        return self;
    };
}

- (HWRxObserver *(^)())behavior {
    return ^() {
        _connect = NO;
        return self;
    };
}

- (HWRxObserver *(^)())connect {
    return ^() {
        if (!_connect) {
            _connect = YES;
            !_latestData ?: [self postAllWith:_latestData];
        }
        _connect = YES;
        return self;
    };
}

- (HWRxObserver *(^)())disconnect {
    return ^() {
        _connect = NO;
        return self;
    };
}

- (HWRxObserver *(^)(HWRxObserver *))takeUntil {
    return ^(HWRxObserver *another) {
        Weakify(self)
        another.subscribe(^(id data) {
            Strongify(self)
            self.disconnect();
        });
        return self;
    };
}

@end

@implementation HWRxObserver (Functional_Extension)

- (HWRxObserver *(^)(mapType))map {
    return ^(mapType block) {
        HWRxObserver *observer = [HWRxObserver new];
        self.subscribe(^(id obj) {
            id data = block(obj);
            if (data != nil) {
                observer.rxObj = data;
            }
        });
        return observer;
    };
}

- (HWRxObserver *(^)(filterType))filter {
    return ^(filterType block) {
        HWRxObserver *observer = [HWRxObserver new];
        self.subscribe(^(id obj) {
            if ([block(obj) boolValue]) {
                observer.rxObj = obj;
            }
        });
        return observer;
    };
}

- (HWRxObserver *(^)(id, reduceType))reduce {
    return ^(id original, reduceType block) {
        HWRxObserver *observer = [HWRxObserver new];
        __block id result = original;
        self.subscribe(^(id obj) {
            result = block(result, obj);
            observer.rxObj = result;
        });
        return observer;
    };
}

- (HWRxObserver *(^)())distinctUntilChanged {
    return ^() {
        HWRxObserver *observer = [HWRxObserver new];
        __block id lastObj = nil;
        self.subscribe(^(id obj) {
            if ((![obj isKindOfClass:[lastObj class]])
                ||([obj isKindOfClass:[NSValue class]] && ![obj isEqualToValue:lastObj])
                ||([obj isKindOfClass:[NSString class]] && ![obj isEqualToString:lastObj]))
            {
                lastObj = obj;
                observer.rxObj = obj;
                return;
            }
        });
        return observer;
    };
}

@end

@implementation NSArray (RxObserver_Extension)

- (HWRxObserver *)merge {
    HWRxObserver *observer = [HWRxObserver new];
    self.filter(^(id obj) {
        return @([obj isKindOfClass:[HWRxObserver class]]);
    }).forEach(^(HWRxObserver *observable) {
        observable.subscribe(^(id data) {
            observer.rxObj = data;
        });
    });
    return observer;
}

- (HWRxObserver *)combineLatest {
    HWRxObserver *observer = [HWRxObserver new];
    NSArray *observers = self.filter(^(id obj) {
        return @([obj isKindOfClass:[HWRxObserver class]]);
    });
    NSMutableArray *results = (NSMutableArray *)observers.map(^(id obj) {
        return @"combineLatest";
    });
    observers.forEachWithIndex(^(HWRxObserver *observable, NSUInteger index) {
        observable.subscribe(^(id obj) {
            
            if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
                [results replaceObjectAtIndex:index withObject:[NSNull null]];
            } else {
                [results replaceObjectAtIndex:index withObject:obj];
            }
            
            NSArray *filtered = results.filter(^(id result) {
                return @([result isKindOfClass:[NSString class]] && [result isEqualToString:@"combineLatest"]);
            });
            
            if (filtered.count == 0) {
                observer.rxObj = results;
            }
        });
    });
    
    return observer;
}

@end
