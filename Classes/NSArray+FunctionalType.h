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

FOUNDATION_EXTERN NSArray * NotNilArray(NSArray *ary);

@interface NSArray (FunctionalType) <HWFunctionalType>

@property (nonatomic, readonly) NSArray *(^map)(mapType);
@property (nonatomic, readonly) NSArray *(^mapWithIndex)(mapWithIndexType);
@property (nonatomic, readonly) NSArray *(^flatMap)(flatMapType);
@property (nonatomic, readonly) NSArray *(^sort)(sortType);
@property (nonatomic, readonly) NSArray *(^filter)(filterType);

@property (nonatomic, readonly) NSArray *(^just)(NSUInteger count);
@property (nonatomic, readonly) NSArray *(^justTail)(NSUInteger count);
@property (nonatomic, readonly) NSArray *(^drop)(NSUInteger count);
@property (nonatomic, readonly) NSArray *(^dropLast)(NSUInteger count);

@property (nonatomic, readonly) NSArray *(^forEach)(forEachType);
@property (nonatomic, readonly) NSArray *(^forEachWithIndex)(forEachWithIndexType);

@property (nonatomic, readonly) NSMutableArray *(^mutate)();

@property (nonatomic, readonly) id (^reduce)(id, reduceType);
@property (nonatomic, readonly) BOOL(^compare)(compareType);

@property (nonatomic, readonly) id (^find)(findType);
@property (nonatomic, readonly) BOOL(^contains)(findType);
@property (nonatomic, readonly) NSInteger (^firstIndexOf)(findType);

+ (instancetype)allocWithElementCount:(NSUInteger)elementCount;

@end


@interface NSMutableArray (FunctionalType)

@property (nonatomic, readonly) id (^pop)(findType);

@end

NS_ASSUME_NONNULL_END

