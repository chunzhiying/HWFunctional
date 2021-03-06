//
//  CALayer+HWAnimation.h
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSArray+FunctionalType.h"

NS_ASSUME_NONNULL_BEGIN

@class HWAnimation;

@interface CALayer (HWAnimation)

- (void)addHWAnimation:(HWAnimation *)anim;
- (void)removeHWAnimation:(HWAnimation *)anim;
- (void)removeAllHWAnimations;

@end

NS_ASSUME_NONNULL_END
