//
//  UIView+RxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "UIView+RxObserver.h"
#import "NSNotificationCenter+RxObserver.h"
#import "NSArray+FunctionalType.h"
#import "HWFunctionalType.h"
#import "HWRxObserver.h"
#import "HWAnimation.h"
#import <objc/runtime.h>

@implementation UIView (RxObserver)

- (HWRxObserver *)rx_tap {
    return self.rx_dynamicTapToAlpha(self.alpha);
}

- (HWRxObserver *)rx_dynamicTap {
    return self.rx_dynamicTapToAlpha(self.alpha * 0.6);
}

- (HWRxObserver * _Nonnull (^)(CGFloat))rx_dynamicTapToAlpha {
    return ^(CGFloat pressAlpha) {
        [self setRx_tapAlpha:pressAlpha];
        return self.RxOnce(@"RxObserver_tap");
    };
}

#pragma mark - Property
- (void)setRx_tapAlpha:(CGFloat)tapAlpha {
    objc_setAssociatedObject(self, @selector(rx_tapAlpha), @(tapAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)rx_tapAlpha {
    return [objc_getAssociatedObject(self, @selector(rx_tapAlpha)) floatValue];
}

- (void)setRx_gesture:(UIGestureRecognizer *)gesture {
    objc_setAssociatedObject(self, @selector(rx_gesture), gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizer *)rx_gesture {
    return objc_getAssociatedObject(self, @selector(rx_gesture));
}

#pragma mark - Add Observer & Gesture
- (void)addRxObserver:(HWRxObserver *)observer {
    if ([observer.keyPath isEqualToString:@"RxObserver_tap"]) {
        [self addGestureObserver:observer];
    }
    [super addRxObserver:observer];
}

- (void)addGestureObserver:(HWRxObserver *)observer {
    if ([self isKindOfClass:[UIButton class]]) {
        [(UIButton *)self addTarget:observer action:observer.tapAction forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    if ([self rx_gesture]) {
        [self removeGestureRecognizer:[self rx_gesture]];
    }
    
    [self setUserInteractionEnabled:YES];
    
    if ([self rx_tapAlpha] == self.alpha) {
        // normalTap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:observer action:observer.tapAction];
        [self addGestureRecognizer:tap];
        [self setRx_gesture:tap];
        
    } else {
        // dynamicTap
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:observer action:observer.tapAction];
        press.minimumPressDuration = 0;
        [self addGestureRecognizer:press];
        [self setRx_gesture:press];
        
        CGFloat alpha = self.alpha;
        CABasicAnimation *resetAni = [CABasicAnimation animationWithKeyPath:HWAnimation_Opacity];
        resetAni.fromValue = @([self rx_tapAlpha]);
        resetAni.toValue = @(alpha);
        resetAni.duration = 0.3 * (1 - [self rx_tapAlpha]);
        
        Weakify(self)
        press.Rx(@"state").disposeBy(self).subscribe(HW_BLOCK(HWIntegerNumber *) { Strongify(self)
            UIGestureRecognizerState state = $0.integerValue;
            switch (state) {
                case UIGestureRecognizerStateBegan:
                {
                    self.alpha = [self rx_tapAlpha];
                    [self.layer removeAllAnimations];
                    break;
                }
                case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateEnded:
                {
                    self.alpha = alpha;
                    [self.layer addAnimation:resetAni forKey:nil];
                    break;
                }
                default:
                    break;
            }
        });
    }
}

@end


@implementation UITextField (RxObserver)

- (HWRxObserver *)rx_text { Weakify(self)
    HWRxNoCenter.Rx(UITextFieldTextDidChangeNotification).disposeBy(self)
    .response(^{ Strongify(self)
        self.rx_repost(@"text");
    });
    return self.Rx(@"text");
}

@end
