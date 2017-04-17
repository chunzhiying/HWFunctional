//
//  HWFunctionalType.h
//  HWKitTestDemo
//
//  Created by 陈智颖 on 16/8/30.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HWMacro.h"
#import "HWTypeDef.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^thenType)(id obj);
typedef void(^forEachType)(id obj);
typedef void(^forEachWithIndexType)(id obj, NSUInteger index);

typedef id _Nonnull (^mapType)(id element);
typedef id _Nonnull (^mapWithIndexType)(id element, NSUInteger index);
typedef id _Nonnull (^flatMapType)(id element);
typedef id _Nonnull (^reduceType)(id result, id element);
typedef BOOL(^findType)(id element);

typedef NSNumber * _Nonnull (^compareType)(id obj1, id obj2); //bool
typedef NSNumber * _Nonnull (^filterType)(id obj1); //bool
typedef NSComparisonResult(^sortType)(id obj1, id obj2);


@protocol HWFunctionalType <NSObject>

@optional
@property (nonatomic, readonly) id<HWFunctionalType>(^map)(mapType);
@property (nonatomic, readonly) id<HWFunctionalType>(^mapWithIndex)(mapWithIndexType);
@property (nonatomic, readonly) id<HWFunctionalType>(^flatMap)(flatMapType);

@property (nonatomic, readonly) id<HWFunctionalType>(^sort)(sortType);
@property (nonatomic, readonly) id<HWFunctionalType>(^filter)(filterType);
@property (nonatomic, readonly) id(^reduce)(id, reduceType);
@property (nonatomic, readonly) BOOL(^compare)(compareType);

@property (nonatomic, readonly) id (^find)(findType);
@property (nonatomic, readonly) BOOL(^contains)(findType);

@property (nonatomic, readonly) id<HWFunctionalType>(^just)(NSUInteger count);
@property (nonatomic, readonly) id<HWFunctionalType>(^justTail)(NSUInteger count);
@property (nonatomic, readonly) id<HWFunctionalType>(^drop)(NSUInteger count);
@property (nonatomic, readonly) id<HWFunctionalType>(^dropLast)(NSUInteger count);

@property (nonatomic, readonly) id<HWFunctionalType>(^forEach)(forEachType);
@property (nonatomic, readonly) id<HWFunctionalType>(^forEachWithIndex)(forEachWithIndexType);

@end

#define Interface(class, property) @interface class (FunctionalType_Basic)  property  @end
#define Implementation(class, method) @implementation class (FunctionalType_Basic)  method  @end

#define IFace_then \
@property (nonatomic, readonly) id(^then)(thenType);

#define Imp_then \
- (id(^)(thenType block))then { return ^(thenType block) { block(self); return self;}; }

Interface(NSObject, IFace_then)
Implementation(NSObject, Imp_then)

NS_ASSUME_NONNULL_END


