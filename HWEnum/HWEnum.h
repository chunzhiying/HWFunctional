//
//  HWEnum.h
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2017/1/22.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWFunctionalType.h"

@class HWOptionalData;

typedef HWOptionalData *(^OptionalBlock)();

#define HWEnum(num, extend) [HWEnum type:num content:extend]

@interface HWEnum : NSObject

@property (nonatomic, readonly) NSInteger type;
@property (nonatomic, strong, readonly) NSObject *extend;

+ (instancetype)type:(NSInteger)type content:(NSObject *)extend;

@end

#define HWOptional(block) [HWOptional contentBlock:block]
#define HWOptionalNone [HWOptionalData new].then(^(HWOptionalData *data) { data.value = nil; })
#define HWOptionalSome(some) [HWOptionalData new].then(^(HWOptionalData *data) { data.value = some; })

typedef enum : NSInteger {
    HWOptional_None,
    HWOptional_Some
} HWOptionalType;


@interface HWOptionalData : NSObject

@property (nonatomic, strong) NSObject *value;

@end

@interface HWOptional<__covariant SomeT> : HWEnum

+ (instancetype)contentBlock:(OptionalBlock)block;
+ (instancetype)content:(SomeT)content;

@end
