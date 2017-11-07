//
//  HWPromise+RxObserver.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/10/31.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^FilterBlock)(NSDictionary *);

@class HWRxObserver;

@interface HWPromise (RxObserver)

@property (nonatomic, readonly, class) HWPromise *(^observe)(HWRxObserver *);
@property (nonatomic, readonly, class) HWPromise *(^observeOnce)(HWRxObserver *, FilterBlock);

@end

NS_ASSUME_NONNULL_END
