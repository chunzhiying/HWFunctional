//
//  HWAnimation.m
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAnimation.h"
#import "NSArray+FunctionalType.h"
#import "CALayer+HWAnimation.h"

#define SeparateSymbol @"_"

@interface HWAnimation () <CAAnimationDelegate>
{
    BOOL _autoRemoved;
    HWAnimationType _type;
    HWFillMode _fillMode;
    HWTimingFunctionType _timingFunction;
    CABasicAnimation *_basicAnimation;
    CAKeyframeAnimation *_keyFrameAnimation;
    CAAnimationGroup *_animationGroup;
}

@property (nonatomic, copy) FinishedBlock finishedblock;
@property (nonatomic, copy) StopBlock stopBlock;

@end

@implementation HWAnimation

- (instancetype)init {
    self = [super init];
    if (self) {
        _keyPath = @"instance";
        _autoRemoved = YES;
    }
    return self;
}

- (void)dealloc {

}

- (NSString *)keyPath {
    return  [NSString stringWithFormat:@"HWAnimation_%@", _keyPath];
}

- (CAAnimation *)animation {
    switch (_type) {
        case HW_Animation_Basic: return _basicAnimation;
        case HW_Animation_KeyFrame: return _keyFrameAnimation;
        case HW_Animation_Group: return _animationGroup;
    }
}

- (HWAnimation *(^)())run {
    return ^{
        [_layer addAnimation:self.animation forKey:self.keyPath];
        return self;
    };
}

- (HWAnimation *(^)())cancel {
    return ^{
        [_layer removeAnimationForKey:self.keyPath];
        return self;
    };
}

- (HWAnimation *(^)())dispose {
    return ^{
        self.animation.delegate = nil;
        return self;
    };
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    SafeBlock(_finishedblock, flag);
    SafeBlock(_stopBlock);
    if (_autoRemoved) {
        self.animation.delegate = nil;
        [_layer removeHWAnimation:self];
    }
}

@end

@implementation HWAnimation (Base)

- (HWAnimation *(^)(HWAnimationType, NSString *))animate {
    return ^(HWAnimationType type, NSString *keyPath) {
        _type = type;
        self.keyPath = keyPath;
        switch (_type) {
            case HW_Animation_Basic:
                _basicAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
                break;
            case HW_Animation_KeyFrame:
                _keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
                break;
            case HW_Animation_Group:
                self.animateGroup();
                break;
        }
        self.animation.delegate = self;
        return self;
    };
}

- (HWAnimation *(^)(FinishedBlock))finish {
    return  ^(FinishedBlock block) {
        self.finishedblock = block;
        return self;
    };
}

- (HWAnimation *(^)(StopBlock))stop {
    return  ^(StopBlock block) {
        self.stopBlock = block;
        return self;
    };
}

- (HWAnimation *(^)(CALayer *))addTo {
    return ^(CALayer *layer) {
        self.layer = layer;
        [self shouldAutoSet];
        if (_autoRemoved) {
            [layer addHWAnimation:self];
        }
        return self;
    };
}

- (HWAnimation *(^)(BOOL))autoRemoved {
    return ^(BOOL autoRemoved) {
        _autoRemoved = autoRemoved;
        return self;
    };
}

- (HWAnimation *(^)(BOOL))autoreverses {
    return ^(BOOL autoreverses) {
        self.animation.autoreverses = autoreverses;
        return self;
    };
}

#pragma mark - Auto Set
- (void)shouldAutoSet {
    switch (_type) {
        case HW_Animation_Basic:
            [self handleBasicAnimation:_basicAnimation keyPath:_keyPath];
            return;
        case HW_Animation_Group:
            [self handleAnimationGroup:_animationGroup];
            return;
        default:
            return;
    }
}

- (void)handleBasicAnimation:(CABasicAnimation *)basicAnimation keyPath:(NSString *)keyPath {
    if (!basicAnimation.fromValue) {
        [basicAnimation setFromValue:[_layer valueForKeyPath:keyPath]];
    }
    if (basicAnimation.toValue && _fillMode == HW_FillMode_Retain) {
        [_layer setValue:basicAnimation.toValue forKeyPath:keyPath];
    }
}

- (void)handleAnimationGroup:(CAAnimationGroup *)animationGroup {
    NSArray *animations = [self flatmapAnimationGroup:animationGroup];
    NSArray *keyPaths = [_keyPath componentsSeparatedByString:SeparateSymbol];
    keyPaths.filter(^(NSString *keyPath) {
        return (BOOL)![keyPath isEqualToString:@"group"];
    }).forEachWithIndex(^(NSString *keyPath, NSUInteger index)
    {
        CAAnimation *anim = [animations objectAtIndex:index];
        if ([anim isKindOfClass:[CABasicAnimation class]]) {
            [self handleBasicAnimation:(CABasicAnimation *)anim keyPath:keyPath];
        } else if([anim isKindOfClass:[CAAnimationGroup class]]) {
            [self handleAnimationGroup:(CAAnimationGroup *)anim];
        }
    });
}

- (NSArray<CAAnimation *> *)flatmapAnimationGroup:(CAAnimationGroup *)group {
    NSMutableArray *result = [NSMutableArray new];
    group.animations.forEach(^(CAAnimation *anim) {
        if ([anim isKindOfClass:[CAAnimationGroup class]]) {
            [result addObjectsFromArray:[self flatmapAnimationGroup:(CAAnimationGroup *)anim]];
        } else {
            [result addObject:anim];
        }
    });
    return result;
}

#pragma mark -
- (HWAnimation *(^)(CFTimeInterval))duration {
    return ^(CFTimeInterval duration){
        self.animation.duration = duration;
        return self;
    };
}

- (HWAnimation *(^)(CFTimeInterval))beginTime {
    return ^(CFTimeInterval beginTime){
        self.animation.beginTime = beginTime;
        return self;
    };
}

- (HWAnimation *(^)(float))repeatCount {
    return ^(float repeatCount){
        self.animation.repeatCount = repeatCount;
        return self;
    };
}

#pragma mark -
- (HWAnimation *(^)(HWTimingFunctionType))timingFunction {
    return ^(HWTimingFunctionType timingFunction){
        _timingFunction = timingFunction;
        self.animation.timingFunction = [CAMediaTimingFunction functionWithName:
                                         [self transFromTimingFunction:timingFunction]];
        return self;
    };
}

- (HWAnimation *(^)(HWFillMode))fillMode {
    return ^(HWFillMode fillmode){
        _fillMode = fillmode;
        NSString *mode = kCAFillModeForwards;
        switch (fillmode) {
            case HW_FillMode_Both:
                mode = kCAFillModeBoth;
                break;
            case HW_FillMode_Forwards:
            case HW_FillMode_Retain:
                mode = kCAFillModeForwards;
                break;
            case HW_FillMode_Backwards:
                mode = kCAFillModeBackwards;
                break;
            case HW_FillMode_Removed:
                mode = kCAFillModeRemoved;
                break;
        }
        self.animation.removedOnCompletion = NO;
        self.animation.fillMode = mode;
        return self;
    };
}

- (NSString *)transFromTimingFunction:(HWTimingFunctionType)timingFunction {
    NSString *function = kCAMediaTimingFunctionDefault;
    switch (timingFunction) {
        case HW_TimingFunction_EaseIn:
            function = kCAMediaTimingFunctionEaseIn;
            break;
        case HW_TimingFunction_EaseOut:
            function = kCAMediaTimingFunctionEaseOut;
            break;
        case HW_TimingFunction_EaseInEaseOut:
            function = kCAMediaTimingFunctionEaseInEaseOut;
            break;
        case HW_TimingFunction_Linear:
            function = kCAMediaTimingFunctionLinear;
            break;
    }
    return function;
}

@end


@implementation HWAnimation (Basic_Extension)

- (HWAnimation *(^)(id))from {
    return ^(id value){
        _basicAnimation.fromValue = value;
        return self;
    };
}

- (HWAnimation *(^)(id))to {
    return ^(id value){
        _basicAnimation.toValue = value;
        return self;
    };
}

- (HWAnimation *(^)(id))by {
    return ^(id value){
        if ([value isKindOfClass:[NSNumber class]]) {
            _basicAnimation.toValue = @([(NSNumber *)value floatValue] + [(NSNumber *)_basicAnimation.fromValue floatValue]);
        } else {
            _basicAnimation.byValue = value;
        }
        return self;
    };
}

@end


@implementation HWAnimation (KeyFrame_Extension)

- (HWAnimation *(^)(NSArray *))values {
    return ^(NSArray *values){
        _keyFrameAnimation.values = values;
        return self;
    };
}

- (HWAnimation *(^)(NSArray<NSNumber *> *))keyTimes {
    return ^(NSArray<NSNumber *> *keyTimes){
        _keyFrameAnimation.keyTimes = keyTimes;
        return self;
    };
}

- (HWAnimation *(^)(CGPathRef))path {
    return ^(CGPathRef path) {
        _keyFrameAnimation.path = path;
        return self;
    };
}

- (HWAnimation *(^)(NSArray<NSNumber *> *))timingFunctions {
    return ^(NSArray<NSNumber *> *timingFunctions){
        _keyFrameAnimation.timingFunctions = timingFunctions.map(^(NSNumber *timingFunctionValue) {
            return  [CAMediaTimingFunction functionWithName:
                     [self transFromTimingFunction:[timingFunctionValue integerValue]]];
        });
        return self;
    };
}

@end


@implementation HWAnimation (AnimationGroup_Extension)

- (HWAnimation *(^)())animateGroup {
    return ^{
        _type = HW_Animation_Group;
        _animationGroup = [CAAnimationGroup animation];
        self.keyPath = @"group";
        self.animation.delegate = self;
        return self;
    };
}

- (HWAnimation *(^)(NSArray<HWAnimation *> *))animations {
    return ^(NSArray<HWAnimation *> *animations){
        [(CAAnimationGroup *)self.animation setAnimations:animations
         .map(^(HWAnimation *animation) {
            _keyPath = [NSString stringWithFormat:@"%@%@%@", _keyPath, SeparateSymbol, animation->_keyPath];
            return animation.animation;
        })];
        return self;
    };
}

@end


@implementation NSArray (HWAnimation_Extension)

- (HWAnimation *)animationGroup {
    return [HWAnimation new]
    .animateGroup()
    .animations(self.filter(^(NSObject *object) {
        return [object isKindOfClass:[HWAnimation class]];
    }));
}

@end
