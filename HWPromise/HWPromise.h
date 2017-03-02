//
//  HWPromise.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/9/23.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWTypeDef.h"

#define HWPromiseNetworkFail promise.failObj = @"网络异常";

NS_ASSUME_NONNULL_BEGIN

@class HWPromiseResult;
@class HWPromise;

typedef void(^finishType)(id obj);
typedef void(^alwaysType)(HWPromiseResult *result);
typedef void(^completeType)(NSArray<HWPromiseResult *> *results);
typedef HWPromise * _Nonnull (^nextFinishedType)(id obj);


@interface HWPromise<__covariant SuccessT, __covariant FailT> : NSObject

@property (nonatomic, strong) SuccessT successObj;
@property (nonatomic, strong) FailT failObj;

@end


@interface HWPromiseResult : NSObject

@property (nonatomic) BOOL status;
@property (nonatomic, strong) id object; // SuccessT || FailT

@end


@interface HWPromise (FunctionalType_Extension)

@property (nonatomic, readonly) HWPromise *(^success)(finishType);
@property (nonatomic, readonly) HWPromise *(^fail)(finishType);
@property (nonatomic, readonly) HWPromise *(^always)(alwaysType);

@end


@interface HWPromise (CallBack_Hell_Extension)

@property (nonatomic, readonly) HWPromise *(^next)(nextFinishedType);
@property (nonatomic, readonly) HWPromise *(^complete)(completeType);

@end


@interface NSArray (Promise_Extension) //callback hell, use complete.

@property (nonatomic, readonly) HWPromise *promise;

@end

NS_ASSUME_NONNULL_END
