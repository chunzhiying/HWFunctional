//
//  HWRxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWRxObserver.h"
#import "HWWeakTimer.h"
#import <objc/runtime.h>
#import "NSArray+FunctionalType.h"
#import "NSObject+RxObserver.h"

WeakReference MakeWeakReference(id obj) {
    __weak id weakObj = obj;
    return ^{
        return weakObj;
    };
}

typedef NS_ENUM(NSUInteger, HWRxObserverType) {
    HWRxObserverType_UnOwned, // Default. created during Operating. AotuReleased when block over.
    HWRxObserverType_KVO,
    HWRxObserverType_Notification,
    HWRxObserverType_UserDefined,
    HWRxObserverType_Schedule,
    HWRxObserverType_Special, //RxObserver_dealloc、RxObserver_tap
    HWRxObserverType_UnKnown, // no such property, observe failed
};

@interface HWRxObserver ()
{
    HWRxObserverType _type;
    
    NSTimer *_timer;
    NSUInteger _timerValue;
    
    NSMutableArray *_startWithDataAry;
    NSMutableArray<nextType> *_nextBlockAry;
    NSMutableArray<nextBlankType> *_nextBlankBlockAry;
    
    BOOL _connect;
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
        self.tapAction = @selector(onTap:);
        _debounceEnable = YES;
        _throttleEnable = YES;
        _connect        = YES;
        _timerValue     = 0;
        _debounceValue  = 0;
        _throttleValue  = 0;
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
        case HWRxObserverType_Schedule:
            key = @"Schedule"; break;
        case HWRxObserverType_UnOwned:
            key = @"UnOwned"; break;
        case HWRxObserverType_UnKnown:
            key = [NSString stringWithFormat:@"UnKnown Error [key : %@]", _keyPath]; break;
    }
    HWLog([HWRxObserver class], @"dealloc, [key : %@]", key);
}

- (void)setTarget:(NSObject *)target {
    _target = target;
    self.targetDesc = NSStringFromClass([target class]);
}

- (void)setKeyPath:(NSString *)keyPath {
    _keyPath = keyPath;
    if (_target && class_getProperty([_target class], [keyPath cStringUsingEncoding:NSASCIIStringEncoding])) {
        _rxObj = [_target valueForKey:keyPath];
    }
}

- (void)setRxObj:(NSObject *)rxObj {
    
    if ([_rxObj isKindOfClass:[HWRxObserver class]]) {
        ((HWRxObserver *)_rxObj).disconnect();
    }
    
    // HWRxObserverType_Special rxObj = self.target
    if (_type != HWRxObserverType_Special) {
        _rxObj = rxObj;
    }
    
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
                           [self postAllWith:_rxObj];
                       });
        return;
    }
    
    [self postAllWith:rxObj];
}

#pragma mark - Post
#define PostToQueue(...) \
if (_queue && ![NSThread isMainThread]) {               \
    dispatch_async(_queue, ^{SafeBlock(__VA_ARGS__)});  \
} else {                                                \
    SafeBlock(__VA_ARGS__)                              \
}                                                       \

- (void)postTo:(nextType)block with:(NSObject *)data {
    if (_type == HWRxObserverType_Special) {
        // RxObserver_dealloc, _target = nil
        data = _target;
    }
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
    
    if (_type == HWRxObserverType_UserDefined
        || _type == HWRxObserverType_Schedule) {
        return;
    }
    
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
    
    _type = HWRxObserverType_UnKnown;
}

#pragma mark - Notification
- (void)onNofication:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo ? notification.userInfo : [NSDictionary new];
    self.rxObj = userInfo;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:_keyPath]) {
        return;
    }
    self.rxObj = change[@"new"];
}

#pragma mark - Tap
- (void)onTap:(id)obj {
    if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
        self.rxObj = @"RxObserver_tap";
    }
    
    if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)obj;
        if (press.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(press.view.bounds, [press locationInView:press.view])) {
                self.rxObj = @"RxObserver_tap";
            }
        }
    }
    
    if ([obj isKindOfClass:[UIButton class]]) {
        self.rxObj = @"RxObserver_tap";
    }
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

@implementation HWRxObserver (Schedule_Extension)

- (HWRxObserver *(^)(NSUInteger, BOOL))schedule {
    return ^(NSUInteger interval, BOOL repeat) {
        if (!(_type == HWRxObserverType_UnOwned || _type == HWRxObserverType_Schedule)) {
            HWError([HWRxObserver class], @"type error! cannot 'schedule'");
            return self;
        }
        _timerValue = 0;
        _type = HWRxObserverType_Schedule;
        [self runTimer:interval repeat:repeat];
        return self;
    };
}

- (HWRxObserver * _Nonnull (^)())stop {
    return ^{
        if (_type != HWRxObserverType_Schedule) {
            HWError([HWRxObserver class], @"type error! cannot 'stop'");
            return self;
        }
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        return self;
    };
}

- (void)handleSchedule:(NSUInteger)interval repeat:(BOOL)repeat {
    self.next(@(++_timerValue));
    if (repeat) {
        [self runTimer:interval repeat:repeat];
    }
}

- (void)runTimer:(NSUInteger)interval repeat:(BOOL)repeat { Weakify(self)
    self.stop();
    _timer = [HWWeakTimer
              timerWithTimeInterval:interval target:self
              userInfo:nil repeats:NO runloop:[NSRunLoop mainRunLoop] mode:NSRunLoopCommonModes
              callBack:HW_BLOCK(id){ Strongify(self)
                  [self handleSchedule:interval repeat:repeat];
              }];
}

@end

@implementation HWRxObserver (Base_Extension)

- (HWRxObserver * _Nonnull (^)(thenType _Nonnull))then {
    return ^(thenType block) {
        block(self);
        return self;
    };
}

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
        
        if (_type == HWRxObserverType_UserDefined ||
            _type == HWRxObserverType_Schedule) {
            [obj addRxObserver:self];
            return self;
        }
        
        if (!obj.rx_delegateTo_disposers) {
            obj.rx_delegateTo_disposers = @[].mutableCopy;
        }
        
        BOOL isNewDisposer = YES;
        for (WeakReference reference in obj.rx_delegateTo_disposers) {
            if ([reference() isEqual:_target]) {
                isNewDisposer = NO;
                break;
            }
        }
        
        if (isNewDisposer) {
            [obj.rx_delegateTo_disposers addObject:MakeWeakReference(_target)];
        }
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
            !_rxObj ?: [self postAllWith:_rxObj];
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

- (HWRxObserver * _Nonnull (^)())switchLatest {
    return ^{
        HWRxObserver *observer = HWRxInstance.create(@"creat by [switchLatest]");
        self.subscribe(HW_BLOCK(HWRxObserver *) {
            if (![$0 isKindOfClass:[HWRxObserver class]]) {
                HWError([HWRxObserver class], @"switchLatest require HWRxObserver signal");
                return;
            }
            Weakify(observer)
            $0.subscribe(HW_BLOCK(id) {
                StrongifyEnsure(observer)
                observer.next($0);
            });
        });
        return observer;
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
            if (block(obj)) {
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

- (HWRxObserver * _Nonnull (^)(compareType _Nonnull))distinct {
    return ^(compareType block) {
        HWRxObserver *observer = [HWRxObserver new];
        __block id lastObj = nil;
        self.subscribe(^(id obj) {
            if (block(lastObj, obj)) {
                lastObj = obj;
                observer.rxObj = obj;
            }
        });
        return observer;
    };
}

- (HWRxObserver *(^)())distinctUntilChanged {
    return ^() {
        return self.distinct(^(id last, id new) {
            BOOL distinct =
            ![new isKindOfClass:[last class]]
            ||([new isKindOfClass:[NSValue class]] && ![new isEqualToValue:last])
            ||([new isKindOfClass:[NSString class]] && ![new isEqualToString:last]);
            return distinct;
        });
    };
}

@end

@implementation NSArray (RxObserver_Extension)

- (HWRxObserver *)merge {
    HWRxObserver *observer = [HWRxObserver new];
    self.filter(^(id obj) {
        return [obj isKindOfClass:[HWRxObserver class]];
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
        return [obj isKindOfClass:[HWRxObserver class]];
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
                return (BOOL)([result isKindOfClass:[NSString class]] && [result isEqualToString:@"combineLatest"]);
            });
            
            if (filtered.count == 0) {
                observer.rxObj = results;
            }
        });
    });
    
    return observer;
}

@end

