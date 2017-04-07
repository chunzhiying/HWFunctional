//
//  NSArray+FunctionalType.h
//  HWKitTestDemo
//
//  Created by 陈智颖 on 16/8/30.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWFunctionalType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (FunctionalType) <HWFunctionalType>

@property (nonatomic, readonly) NSArray *(^map)(mapType);
@property (nonatomic, readonly) NSArray *(^mapWithIndex)(mapWithIndexType);
@property (nonatomic, readonly) NSArray *(^flatMap)(flatMapType);
@property (nonatomic, readonly) NSArray *(^sort)(sortType);
@property (nonatomic, readonly) NSArray *(^filter)(filterType);

@property (nonatomic, readonly) id (^reduce)(id, reduceType);
@property (nonatomic, readonly) BOOL(^compare)(compareType);

@property (nonatomic, readonly) id (^find)(findType);
@property (nonatomic, readonly) BOOL(^contains)(findType);

@property (nonatomic, readonly) NSArray *(^just)(NSUInteger count);
@property (nonatomic, readonly) NSArray *(^justTail)(NSUInteger count);
@property (nonatomic, readonly) NSArray *(^drop)(NSUInteger count);
@property (nonatomic, readonly) NSArray *(^dropLast)(NSUInteger count);

@property (nonatomic, readonly) NSArray *(^forEach)(forEachType);
@property (nonatomic, readonly) NSArray *(^forEachWithIndex)(forEachWithIndexType);

@property (nonatomic, readonly) NSMutableArray *(^mutate)();

@end

@interface NSArray (FunctionalType_Extension)

+ (instancetype)allocWithElementCount:(NSUInteger)elementCount;

@end

NS_ASSUME_NONNULL_END

