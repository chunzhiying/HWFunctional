//
//  HWEnum.m
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2017/1/22.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWEnum.h"

@implementation HWEnum

+ (instancetype)type:(NSInteger)type content:(NSObject *)extend {
    HWEnum *Enum = [HWEnum new];
    Enum->_type = type;
    Enum->_extend = extend;
    return Enum;
}

@end


@implementation HWOptional

+ (instancetype)content:(NSObject *)content {
    return [self type:(content == nil || [content isKindOfClass:[NSNull class]] ? HWOptional_None : HWOptional_Some)
              content:content];
}

+ (instancetype)contentBlock:(OptionalBlock)block {
    
    if (!block) {
        return [self content:nil];
    }
    return [self content:block().value];
}

@end

@implementation HWOptionalData

@end
