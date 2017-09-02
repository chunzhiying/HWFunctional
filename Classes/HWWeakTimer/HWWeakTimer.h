//
//  HWWeakTimer.h
//  TimerTest
//
//  Created by 陈智颖 on 15/9/9.
//  Copyright (c) 2015年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimerBlock)(NSDictionary * _Nullable userInfo);

@interface HWWeakTimer : NSObject

// NSString * const NSDefaultRunLoopMode;
// NSString * const NSRunLoopCommonModes NS_AVAILABLE(10_5, 2_0);

#pragma mark - Selector
+ (nonnull NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(nonnull id)aTarget
                                    selector:(nonnull SEL)aSelector
                                    userInfo:(nullable id)userInfo
                                     repeats:(BOOL)repeats;

+ (nonnull NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                            target:(nonnull id)aTarget
                          selector:(nonnull SEL)aSelector
                          userInfo:(nullable id)userInfo
                           repeats:(BOOL)yesOrNo
                           runloop:(nonnull NSRunLoop *)runloop
                              mode:(nonnull NSString *)mode;


#pragma mark - Block
+ (nonnull NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                              target:(nonnull id)aTarget
                                            userInfo:(nullable id)userInfo
                                             repeats:(BOOL)repeats
                                            callBack:(nonnull TimerBlock)block;

+ (nonnull NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                                    target:(nonnull id)aTarget
                                  userInfo:(nullable id)userInfo
                                   repeats:(BOOL)yesOrNo
                                   runloop:(nonnull NSRunLoop *)runloop
                                      mode:(nonnull NSString *)mode
                                  callBack:(nonnull TimerBlock)block;

@end
