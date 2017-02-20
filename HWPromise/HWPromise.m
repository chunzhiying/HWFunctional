//
//  HWPromise.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/9/23.
//  Copyright © 2016年 YY. All rights reserved.
//



#import "HWPromise.h"
#import "NSArray+FunctionalType.h"

@implementation HWPromiseResult

+ (instancetype)allocWithStatus:(BOOL)status Object:(id)object {
    HWPromiseResult *result = [HWPromiseResult new];
    result.status = status;
    result.object = object;
    return result;
}

@end

@interface HWPromise ()
{
    finishType _successBlock;
    finishType _failBlock;
    alwaysType _alwaysBlock;
    
    HWPromise *_nextPromise;
    completeType _completeBlock;
    nextFinishedType _nextBlock;
}

@property (nonatomic, strong) NSArray<HWPromiseResult *> *results;

@end

@implementation HWPromise

- (void)setSuccessObj:(id)successObj {
    _successObj = successObj;
    if (!successObj) {
        return;
    }

    HWPromiseResult *result = [HWPromiseResult allocWithStatus:YES
                                                        Object:successObj];
    SafeBlock(_successBlock, successObj)
    SafeBlock(_alwaysBlock, result)
    [self shouldPassNext:YES];
    
}

- (void)setFailObj:(id)failObj {
    _failObj = failObj;
    if (!failObj) {
        return;
    }
    
    HWPromiseResult *result = [HWPromiseResult allocWithStatus:NO
                                                        Object:failObj];
    SafeBlock(_failBlock, failObj)
    SafeBlock(_alwaysBlock, result)
    [self shouldPassNext:NO];
}

- (void)setResults:(NSArray<HWPromiseResult *> *)results {
    _results = results;
    SafeBlock(_completeBlock, results.flatMap(^(HWPromiseResult *result) {
        return [result isKindOfClass:[HWPromiseResult class]] ? result : nil;
    }))
}

- (HWPromise *)combine:(HWPromise *)another {
    HWPromise *promise = [HWPromise new];
    self.complete(^(NSArray<HWPromiseResult *> *result1s) {
        another.always(^(HWPromiseResult *result2) {
            promise.results = @[result1s, result2].flatMap(^(HWPromiseResult *result) {
                return result;
            });
        });
    });
    return promise;
}

- (void)shouldPassNext:(BOOL)shouldPass {
    if (!_nextBlock) {
        return;
    }
    
    if (shouldPass) {
        _nextBlock(_successObj)
        .always(^(HWPromiseResult *result) {
            result.status
            ? (_nextPromise.successObj = result.object)
            : (_nextPromise.failObj = result.object);
        });
    } else {
         _nextPromise.failObj = _failObj;
    }
}

@end


@implementation HWPromise (FunctionalType_Extension)

- (HWPromise *(^)(finishType))success {
    return ^(finishType block) {
        _successBlock = block;
        if (_successObj) {
            SafeBlock(block, _successObj)
        }
        return self;
    };
}

- (HWPromise *(^)(finishType))fail {
    return ^(finishType block) {
        _failBlock = block;
        if (_failObj) {
            SafeBlock(block, _failObj)
        }
        return self;
    };
}

- (HWPromise *(^)(alwaysType))always {
    return ^(alwaysType block) {
        _alwaysBlock = block;
        if (_failObj) {
            SafeBlock(_alwaysBlock, [HWPromiseResult allocWithStatus:NO Object:_failObj])
        }
        else if (_successObj) {
            SafeBlock(_alwaysBlock, [HWPromiseResult allocWithStatus:YES Object:_successObj])
        }
        return self;
    };
}

@end

@implementation HWPromise (CallBack_Hell_Extension)

- (HWPromise *(^)(completeType))complete {
    return ^(completeType block){
        _completeBlock = block;
        if (_results.count > 0) {
            self.results = _results;
        }
        return self;
    };
}

- (HWPromise *(^)(nextFinishedType))next {
    return ^(nextFinishedType block) {
        _nextBlock = block;
        _nextPromise = [HWPromise new];
        if (_failObj) {
            [self shouldPassNext:NO];
        }
        else if (_successObj) {
            [self shouldPassNext:YES];
        }
        return _nextPromise;
    };
}

@end


@implementation NSArray (Promise_Extension)

- (HWPromise *)promise {
    return self
    .filter(^(HWPromise *promise){
        return @([promise isKindOfClass:[HWPromise class]]);
    })
    .reduce([HWPromise new].then(^(HWPromise *promise) {promise.results = @[[NSNull null]];}),
            ^(HWPromise *promise1, HWPromise *promise2)
            {
                return [promise1 combine:promise2];
            });
}

@end
