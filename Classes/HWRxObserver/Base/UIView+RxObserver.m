//
//  UIView+RxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "UIView+RxObserver.h"
#import "NSArray+FunctionalType.h"
#import "HWFunctionalType.h"
#import "HWRxObserver.h"
#import "HWAnimation.h"
#import <objc/runtime.h>

#define PressAlpha(alpha) (alpha / 5)

@implementation UIView (RxObserver)

- (HWRxObserver *)rx_tap {
    [self setRx_tapAni:NO];
    return self.Rx(@"RxObserver_tap");
}

- (HWRxObserver *)rx_dynamicTap {
    [self setRx_tapAni:YES];
    return self.Rx(@"RxObserver_tap");
}

#pragma mark - Property
- (void)setRx_tapAni:(BOOL)tapAni {
    objc_setAssociatedObject(self, @selector(rx_tapAni), @(tapAni), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)rx_tapAni {
    return [objc_getAssociatedObject(self, @selector(rx_tapAni)) boolValue];
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
        
    } else {
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:observer action:observer.tapAction];
        press.minimumPressDuration = 0;
        
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:press];
        
        if (![self rx_tapAni]) {
            return;
        }
        
        CGFloat alpha = self.alpha;
        CABasicAnimation *resetAni = [CABasicAnimation animationWithKeyPath:HWAnimation_Opacity];
        resetAni.fromValue = @(PressAlpha(alpha));
        resetAni.toValue = @(alpha);
        resetAni.duration = 0.3;
        
        Weakify(self)
        press.Rx(@"state").disposeBy(self).subscribe(HW_BLOCK(HWIntegerNumber *) { Strongify(self)
            UIGestureRecognizerState state = $0.integerValue;
            switch (state) {
                case UIGestureRecognizerStateBegan:
                {
                    self.alpha = PressAlpha(alpha);
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

- (HWRxObserver *)rx_text {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
                                                 name:UITextFieldTextDidChangeNotification object:self];
    return self.Rx(@"text");
}

- (void)textFiledEditChanged:(NSNotification *)notification {
    self.rx_repost(@"text");
}

@end
