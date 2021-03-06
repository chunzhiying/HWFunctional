//
//  NSDictionary+FunctionalType.h
//  HWKitDemo
//
//  Created by 陈智颖 on 16/8/31.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWFunctionalType.h"
#import "NSArray+FunctionalType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (FunctionalType) <HWFunctionalType>

@property (nonatomic, readonly) NSDictionary *(^map)(mapType);
@property (nonatomic, readonly) NSArray *(^flatMap)(flatMapType);
@property (nonatomic, readonly) NSDictionary *(^filter)(filterType);
@property (nonatomic, readonly) id (^reduce)(id, reduceType);

@property (nonatomic, readonly) NSMutableDictionary *(^mutate)();

@end

NS_ASSUME_NONNULL_END
