//
//  CALayer+HWAnimation.m
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAnimation.h"
#import "CALayer+HWAnimation.h"

#define HWAnimationsKey @"HWAnimations"

@implementation CALayer (HWAnimation)

- (void)addHWAnimation:(HWAnimation *)anim {
    anim.layer = self;
    NSMutableArray *animations = [[NSMutableArray alloc] initWithArray:[self valueForKey:HWAnimationsKey]];
    [animations addObject:anim];
    [self setValue:animations forKey:HWAnimationsKey];
}

- (void)removeHWAnimation:(HWAnimation *)anim {
    anim.cancel();
    NSMutableArray *animations = [[NSMutableArray alloc] initWithArray:[self valueForKey:HWAnimationsKey]];
    [animations removeObject:anim];
    [self setValue:animations forKey:HWAnimationsKey];
}

- (void)removeAllHWAnimations {
    NSArray *animations = [self valueForKey:HWAnimationsKey];
    if ([animations isKindOfClass:[NSArray class]] && animations.count > 0) {
        animations.forEach(^(HWAnimation *anim) {
            anim.cancel();
        });
    }
    [self setValue:[NSArray new] forKey:HWAnimationsKey];
}

@end


