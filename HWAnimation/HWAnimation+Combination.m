//
//  HWAnimation+Combination.m
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/16.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAnimation+Combination.h"

@implementation HWAnimation (Combination)

- (HWAnimation *(^)(CGRect))frameTo {
    return ^(CGRect rect) {
        CGPoint toPositon = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
        CGRect toBounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
        return self
        .animateGroup()
        .animations(@[HWAnimInstance.animate(HW_Animation_Basic, @"position").to([NSValue valueWithCGPoint:toPositon]),
                      HWAnimInstance.animate(HW_Animation_Basic, @"bounds").to([NSValue valueWithCGRect:toBounds])])
        .fillMode(HW_FillMode_Retain);
    };
}

- (HWAnimation *(^)(CGFloat, CGFloat, CGFloat, CGFloat))scaleBounce {
    return ^(CGFloat start, CGFloat middle, CGFloat end, CGFloat duration) {
        return self
        .animateGroup()
        .animations(@[HWAnimInstance.animate(HW_Animation_Basic, @"transform.scale")
                        .from(@(start)).to(@(middle)).duration(duration),
                      HWAnimInstance.animate(HW_Animation_Basic, @"transform.scale")
                        .from(@(middle)).to(@(end)).duration(duration).beginTime(duration)])
        .fillMode(HW_FillMode_Retain)
        .duration(2 * duration);
    };
}

@end
