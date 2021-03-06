//
//  UIView+RxObserver.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+RxObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RxObserver)

@property (nonatomic, readonly) HWRxObserver *rx_tap; // Without animation except UIButton
@property (nonatomic, readonly) HWRxObserver *rx_dynamicTap; // Animate just like what UIButton do, default: 0.6 * self.alpha

@property (nonatomic, readonly) HWRxObserver *(^rx_dynamicTapToAlpha)(CGFloat pressAlpha); // Custom press alpha

@end

@interface UITextField (RxObserver)

@property (nonatomic, readonly) HWRxObserver *rx_text;

@end

NS_ASSUME_NONNULL_END
