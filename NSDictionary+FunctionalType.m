//
//  NSDictionary+FunctionalType.m
//  HWKitDemo
//
//  Created by 陈智颖 on 16/8/31.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSDictionary+FunctionalType.h"

@implementation NSDictionary (FunctionalType)

- (NSDictionary *(^)(mapType block))map {
    return ^(mapType block) {
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (id key in self.allKeys) {
            id newElement = block(@{@"key":key, @"value":self[key]});
            if (newElement) {
                [result setObject:newElement forKey:key];
            }
        }
        return result;
    };
}

- (NSArray *(^)(flatMapType))flatMap {
    return ^(flatMapType block) {
        id result = [NSMutableArray new];
        for (id key in self.allKeys) {
            if (!self[key] || [self[key] isKindOfClass:[NSNull class]]) {
                continue;
            }
            id newElement = block(@{@"key":key, @"value":self[key]});
            if (newElement) {
                [result addObject:newElement];
            }
        }
        return result;
    };
}

- (NSDictionary *(^)(filterType block))filter {
    return ^(filterType block) {
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (id key in self.allKeys) {
            if ([block(@{@"key":key, @"value":self[key]}) boolValue]) {
                [result setObject:self[key] forKey:key];
            }
        }
        return result;
    };
}

- (id (^)(id original, reduceType block))reduce {
    return ^(id original, reduceType block) {
        id result = original;
        for (id key in self.allKeys) {
            result = block(result, @{@"key":key, @"value":self[key]});
        }
        return result;
    };
}

@end

