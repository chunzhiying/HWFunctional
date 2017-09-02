//
//  HWWeakTimer.m
//  TimerTest
//
//  Created by 陈智颖 on 15/9/9.
//  Copyright (c) 2015年 YY. All rights reserved.
//

#import "HWWeakTimer.h"
#import "HWMacro.h"

@interface HWWeakTimerTarget : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) TimerBlock block;
@property (nonatomic, copy) NSString *runloopMode;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation HWWeakTimerTarget

- (void)fire:(NSTimer *)timer {
    
    if (!_target) {
        [_timer invalidate];
        HWLog([HWWeakTimerTarget class], @"invalidate");
        return;
    }
    
    if (_selector) {
        [_target performSelectorOnMainThread:_selector
                                  withObject:timer.userInfo waitUntilDone:false modes:@[_runloopMode]];
        return;
    }
    
    if (_block) {
        _block(timer.userInfo);
        return;
    }
}

@end

@implementation HWWeakTimer

#pragma mark - Private
+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats callBack:(TimerBlock)block {
    
    HWWeakTimerTarget *timerTarget = [[HWWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.block = block;
    timerTarget.runloopMode = NSDefaultRunLoopMode;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:timerTarget
                                                       selector:@selector(fire:)
                                                       userInfo:userInfo
                                                        repeats:repeats];
    
    return timerTarget.timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo runloop:(NSRunLoop *)runloop mode:(NSString *)mode callBack:(TimerBlock)block {
    
    HWWeakTimerTarget *timerTarget = [[HWWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.block = block;
    timerTarget.runloopMode = mode;
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:timerTarget
                                           selector:@selector(fire:)
                                           userInfo:userInfo
                                            repeats:yesOrNo];
    
    [runloop addTimer:timer forMode:mode];
    
    timerTarget.timer = timer;
    return timerTarget.timer;
}

#pragma mark - Public
+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval target:aTarget
                                       selector:aSelector userInfo:userInfo repeats:repeats callBack:nil];
}

+ (nonnull NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                                    target:(nonnull id)aTarget
                                  selector:(nonnull SEL)aSelector
                                  userInfo:(nullable id)userInfo
                                   repeats:(BOOL)yesOrNo
                                   runloop:(nonnull NSRunLoop *)runloop
                                      mode:(nonnull NSString *)mode
{
    return [self timerWithTimeInterval:ti target:aTarget
                              selector:aSelector userInfo:userInfo repeats:yesOrNo runloop:runloop mode:mode callBack:nil];
}

+ (nonnull NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                              target:(nonnull id)aTarget
                                            userInfo:(nullable id)userInfo
                                             repeats:(BOOL)repeats
                                            callBack:(nonnull TimerBlock)block
{
    return [self scheduledTimerWithTimeInterval:interval target:aTarget
                                       selector:nil userInfo:userInfo repeats:repeats callBack:block];
}

+ (nonnull NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                                    target:(nonnull id)aTarget
                                  userInfo:(nullable id)userInfo
                                   repeats:(BOOL)yesOrNo
                                   runloop:(nonnull NSRunLoop *)runloop
                                      mode:(nonnull NSString *)mode
                                  callBack:(nonnull TimerBlock)block
{
    return [self timerWithTimeInterval:ti target:aTarget
                              selector:nil userInfo:userInfo repeats:yesOrNo runloop:runloop mode:mode callBack:block];
}

@end
