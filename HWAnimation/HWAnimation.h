//
//  HWAnimation.h
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CALayer+HWAnimation.h"

#define HWAnimInstance [HWAnimation new]

typedef void(^FinishedBlock)(BOOL);
typedef void(^StopBlock)();

typedef NS_ENUM(NSUInteger, HWAnimationType) {
    HW_Animation_Basic,
    HW_Animation_KeyFrame,
    HW_Animation_Group
};

typedef NS_ENUM(NSUInteger, HWFillMode) {
    HW_FillMode_Removed, //remove animation when finished
    HW_FillMode_Retain, //stay end with toValue
    HW_FillMode_Forwards, //stay end with fromValue
    HW_FillMode_Backwards, //change to fromValue when addTo
    HW_FillMode_Both //Forwards & Backwards
};

typedef NS_ENUM(NSUInteger, HWTimingFunctionType) {
    HW_TimingFunction_EaseInEaseOut,
    HW_TimingFunction_Linear,
    HW_TimingFunction_EaseIn,
    HW_TimingFunction_EaseOut,
};

@interface HWAnimation : NSObject

@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, readonly) CAAnimation *animation;

@property (nonatomic, readonly) HWAnimation *(^run)();
@property (nonatomic, readonly) HWAnimation *(^cancel)();
@property (nonatomic, readonly) HWAnimation *(^dispose)(); //when autoRemoved(NO), should call

@end


@interface HWAnimation (Base)

@property (nonatomic, readonly) HWAnimation *(^animate)(HWAnimationType, NSString *);
@property (nonatomic, readonly) HWAnimation *(^addTo)(CALayer *);

@property (nonatomic, readonly) HWAnimation *(^finish)(FinishedBlock);
@property (nonatomic, readonly) HWAnimation *(^stop)(StopBlock);

@property (nonatomic, readonly) HWAnimation *(^duration)(CFTimeInterval);
@property (nonatomic, readonly) HWAnimation *(^beginTime)(CFTimeInterval); //had add CACurrentMediaTime() 
@property (nonatomic, readonly) HWAnimation *(^repeatCount)(float);

@property (nonatomic, readonly) HWAnimation *(^autoRemoved)(BOOL); //default: YES
@property (nonatomic, readonly) HWAnimation *(^timingFunction)(HWTimingFunctionType);
@property (nonatomic, readonly) HWAnimation *(^fillMode)(HWFillMode);

@end


@interface HWAnimation (Basic_Extension)

@property (nonatomic, readonly) HWAnimation *(^from)(id);
@property (nonatomic, readonly) HWAnimation *(^to)(id);
@property (nonatomic, readonly) HWAnimation *(^by)(id);

@end


@interface HWAnimation (KeyFrame_Extension)

@property (nonatomic, readonly) HWAnimation *(^values)(NSArray *);
@property (nonatomic, readonly) HWAnimation *(^path)(CGPathRef); //anchorPoint & position
@property (nonatomic, readonly) HWAnimation *(^keyTimes)(NSArray<NSNumber *> *); //[0, 1]
@property (nonatomic, readonly) HWAnimation *(^timingFunctions)(NSArray<NSNumber *> *); //HWTimingFunctionType

@end


@interface HWAnimation (AnimationGroup_Extension)

@property (nonatomic, readonly) HWAnimation *(^animateGroup)();
@property (nonatomic, readonly) HWAnimation *(^animations)(NSArray<HWAnimation *> *);

@end


@interface NSArray (HWAnimation_Extension)

@property (nonatomic, readonly) HWAnimation *animationGroup;

@end

