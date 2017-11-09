//
//  NSArray+FunctionalType.m
//  HWKitTestDemo
//
//  Created by 陈智颖 on 16/8/30.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSArray+FunctionalType.h"

@implementation NSArray (FunctionalType)

- (NSArray *(^)(mapType block))map {
    return ^(mapType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (id element in self) {
            id newElement = block(element);
            if (newElement) {
                [result addObject:newElement];
            }
        }
        return result;
    };
}

- (NSArray *(^)(mapWithIndexType block))mapWithIndex {
    return ^(mapWithIndexType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (NSInteger i = 0; i < self.count; i++) {
            id element = [self objectAtIndex:i];
            id newElement = block(element, i);
            if (newElement) {
                [result addObject:newElement];
            }
        }
        return result;
    };
}

- (NSArray *(^)(flatMapType block))flatMap {
    return ^(flatMapType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (id element in self) {
            if (!element || [element isKindOfClass:[NSNull class]]) {
                continue;
            }
            if ([element isKindOfClass:[NSArray class]]) {
                NSArray *subResult = ((NSArray *)element).flatMap(block);
                [result addObjectsFromArray:subResult];
            } else {
                id newElement = block(element);
                if (newElement) {
                    [result addObject:newElement];
                }
            }
        }
        return result;
    };
}

- (NSArray *(^)(sortType block))sort {
    return ^(sortType block) {
        NSMutableArray *mAry;
        if ([self isKindOfClass:[NSMutableArray class]]) {
            mAry = (NSMutableArray *)self;
        } else {
            mAry = [[NSMutableArray alloc] initWithArray:self];
        }
        [mAry sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return block(obj1, obj2);
        }];
        return mAry;
    };
}

- (NSArray *(^)(filterType block))filter {
    return ^(filterType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (id element in self) {
            if (block(element)) {
                [result addObject:element];
            }
        }
        return result;
    };
}

- (id (^)(id original, reduceType block))reduce {
    return ^(id original, reduceType block) {
        id result = original;
        for (id element in self) {
            result = block(result, element);
        }
        return result;
    };
}

- (id (^)(findType))find {
    return ^(findType block) {
        id result = nil;
        for (id element in self) {
            if (block(element)) {
                result = element;
                break;
            }
        }
        return result;
    };
}

- (BOOL (^)(findType))contains {
    return ^(findType block) {
        for (id element in self) {
            if (block(element)) {
                return YES;
            }
        }
        return NO;
    };
}

- (BOOL (^)(compareType block))compare {
    return ^(compareType block) {
        BOOL result = YES;
        if (self.count == 2) {
            id obj1 = [self objectAtIndex:0];
            id obj2 = [self objectAtIndex:1];
            if ([obj1 isKindOfClass:[NSArray class]] && [obj2 isKindOfClass:[NSArray class]]) {
                if ([obj1 count] != [obj2 count]) {
                    result = NO;
                } else {
                    for (NSUInteger i = 0; i < [obj1 count]; i++) {
                        result = block([obj1 objectAtIndex:i], [obj2 objectAtIndex:i]);
                        if (!result) {
                            break;
                        }
                    }
                }
            } else if(![obj1 isKindOfClass:[NSArray class]] && ![obj2 isKindOfClass:[NSArray class]]) {
                result = block(obj1, obj2);
            } else {
                result = NO;
            }
        }
        else if (self.count == 1){
            result = YES;
        }
        else {
            result = [self subarrayWithRange:NSMakeRange(0, 2)].compare(block)
            && [self subarrayWithRange:NSMakeRange(1, self.count - 1)].compare(block);
        }
        return result;
    };
}

- (NSArray *(^)(NSUInteger count))just {
    return ^(NSUInteger count) {
        if (count > self.count) {
            return self;
        }
        NSMutableArray *result = [NSMutableArray new];
        for (NSInteger i = 0; i < count; i++) {
            [result addObject:[self objectAtIndex:i]];
        }
        return (NSArray *)result;
    };
}

- (NSArray *(^)(NSUInteger count))justTail {
    return ^(NSUInteger count) {
        if (count > self.count) {
            return self;
        }
        NSMutableArray *result = [NSMutableArray new];
        for (NSInteger i = self.count - count; i < self.count; i++) {
            [result addObject:[self objectAtIndex:i]];
        }
        return (NSArray *)result;
    };
}

- (NSArray *(^)(NSUInteger))drop {
    return ^(NSUInteger count) {
        if (count >= self.count) {
            return [NSArray new];
        }
        NSMutableArray *result = [NSMutableArray new];
        for (NSInteger i = count; i < self.count; i++) {
            [result addObject:[self objectAtIndex:i]];
        }
        return (NSArray *)result;
    };
}

- (NSArray *(^)(NSUInteger))dropLast {
    return ^(NSUInteger count) {
        if (count >= self.count) {
            return [NSArray new];
        }
        NSMutableArray *result = [NSMutableArray new];
        for (NSInteger i = 0; i < self.count - count; i++) {
            [result addObject:[self objectAtIndex:i]];
        }
        return (NSArray *)result;
    };
}

- (NSArray *(^)(forEachType))forEach {
    return ^(forEachType block) {
        if (!self) {
            return [NSArray new];
        } else {
            for (id obj in self) {
                block(obj);
            }
            return self;
        }
    };
}

- (NSArray *(^)(forEachWithIndexType))forEachWithIndex {
    return ^(forEachWithIndexType block) {
        if (!self) {
            return [NSArray new];
        } else {
            for (NSInteger i = 0; i < self.count; i++) {
                block([self objectAtIndex:i], i);
            }
            return self;
        }
    };
}

- (NSMutableArray *(^)())mutate {
    return ^{
        return [[NSMutableArray alloc] initWithArray:self];
    };
}

@end

@implementation NSArray (FunctionalType_Extension)

+ (instancetype)allocWithElementCount:(NSUInteger)elementCount {
    NSMutableArray *array = [NSMutableArray new];
    for (NSUInteger i = 0; i < elementCount; i++) {
        [array addObject:@(i)];
    }
    return array;
}

@end

