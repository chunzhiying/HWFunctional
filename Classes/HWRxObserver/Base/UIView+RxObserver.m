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
#import <objc/runtime.h>

@implementation UIView (RxObserver_Base)

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
        
        CGFloat alpha = self.alpha;
        Weakify(self)
        press.Rx(@"state").disposeBy(self).subscribe(HW_BLOCK(HWIntegerNumber *) { Strongify(self)
            UIGestureRecognizerState state = $0.integerValue;
            switch (state) {
                case UIGestureRecognizerStateBegan:
                {
                    self.alpha = alpha / 5;
                    break;
                }
                case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateEnded:
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.alpha = alpha;
                    }];
                    break;
                }
                default:
                    break;
            }
        });
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:press];
    }
}

@end


@implementation UIView (RxObserver)

- (HWRxObserver *)rx_tap {
    return self.Rx(@"RxObserver_tap");
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
