//
//  HWAnimation+Combination.h
//  HWAnimationDemo
//
//  定义常用的组合动画
//
//  Created by 陈智颖 on 2016/12/16.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HWAnimation (Combination)

@property (nonatomic, readonly) HWAnimation *(^frameTo)(CGRect);
@property (nonatomic, readonly) HWAnimation *(^scaleBounce)(CGFloat, CGFloat, CGFloat, CGFloat); //start, middle, end, duration

@end

NS_ASSUME_NONNULL_END
