//
//  HWRxVariable.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWRxObserver.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^refreshCallBack)(id object, NSInteger index);


@interface HWRxVariable : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSArray *content;

@property (nonatomic, strong, readonly) HWRxObserver *observer; //HWVariableSquence

+ (instancetype)variable:(NSArray *)array;

- (id)objectAtIndex:(NSUInteger)index;

- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)addObject:(id)object;
- (void)removeObject:(id)object;

- (void)replaceByObject:(id)object select:(refreshCallBack)callBack;
- (void)reloadObject:(NSArray *)objects;

@end


typedef NS_ENUM(NSUInteger, HWVariableChangeType) {
    HWVariableChangeType_Add,
    HWVariableChangeType_Remove,
    HWVariableChangeType_Reload,
};

@interface HWVariableSequence : NSObject

@property (nonatomic) HWVariableChangeType type;
@property (nonatomic) NSUInteger location;
@property (nonatomic, strong) NSArray *content;

@end

NS_ASSUME_NONNULL_END
