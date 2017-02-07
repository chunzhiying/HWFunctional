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

@property (nonatomic, readonly) HWRxObserver *rx_tap;

@end

@interface UITextField (RxObserver)

@property (nonatomic, readonly) HWRxObserver *rx_text;

@end


//@interface UIResponder (RxObserver_dealloc)
//
//@property (nonatomic, readonly) HWRxObserver *rx_dealloc;
//
//@end

NS_ASSUME_NONNULL_END
