//
//  HWMacro.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2017/2/20.
//  Copyright © 2017年 YY. All rights reserved.
//

#ifndef HWMacro_h
#define HWMacro_h

// Common

#define SafeBlock(atBlock, ...) \
    if(atBlock) { atBlock(__VA_ARGS__); }

#define SafeBlockDefault(default, atBlock, ...)\
    (atBlock ? (atBlock(__VA_ARGS__)) : (default))

#define Weakify(obj) \
    __weak __typeof__(obj) obj##_weak_ = obj;

#define Strongify(obj) \
    __strong __typeof__(obj##_weak_) obj = obj##_weak_;

#define StrongifyEnsure(obj) \
    if (!obj##_weak_) { return; } \
    Strongify(obj)


// Log

#ifdef DEBUG
#define HWLog(class, fmt, ...) NSLog((@"[%@]: " fmt), NSStringFromClass(class), ##__VA_ARGS__)
#define HWError(class, fmt, ...) NSLog((@"[%@] error: " fmt), NSStringFromClass(class), ##__VA_ARGS__)
#else
#define HWLog(...)
#define HWError(...)
#endif


// String

#define ConstStringExtern(atName) \
    extern NSString * const atName;

#define ConstStringDefine(atName) \
    NSString * const atName = @#atName;


// Queue

#define HWMainQueue dispatch_get_main_queue()


// Parameter

#define HW_CONECT(x, y)     x, y

#define HW_MACROCAT_(x, y)  x##y
#define HW_MACROCAT(x, y)   HW_MACROCAT_(x, y)

#define HW_META_head(...)             HW_META_head_(__VA_ARGS__, 0)
#define HW_META_head_(FIRST, ...)     FIRST

#define HW_META_at4(_0, _1, _2, _3, ...)            HW_META_head(__VA_ARGS__)
#define HW_META_at5(_0, _1, _2, _3, _4, ...)        HW_META_head(__VA_ARGS__)

#define HW_META_at(N, ...)            HW_MACROCAT(HW_META_at, 5)(__VA_ARGS__)
#define HW_META_argCount(...)         HW_META_at(5, __VA_ARGS__, 5, 4, 3, 2, 1)


#define HW_APPEND_0(x)      x HW_MACROCAT($, 0)
#define HW_APPEND_1(x)      x HW_MACROCAT($, 1)
#define HW_APPEND_2(x)      x HW_MACROCAT($, 2)
#define HW_APPEND_3(x)      x HW_MACROCAT($, 3)
#define HW_APPEND_4(x)      x HW_MACROCAT($, 4)

#define HW_PARAMETER_1(a)               HW_APPEND_0(a)
#define HW_PARAMETER_2(a, b)            HW_CONECT(HW_PARAMETER_1(a), HW_APPEND_1(b))
#define HW_PARAMETER_3(a, b, c)         HW_CONECT(HW_PARAMETER_2(a, b), HW_APPEND_2(c))
#define HW_PARAMETER_4(a, b, c, d)      HW_CONECT(HW_PARAMETER_3(a, b, c), HW_APPEND_3(d))
#define HW_PARAMETER_5(a, b, c, d, e)   HW_CONECT(HW_PARAMETER_4(a, b, c, d), HW_APPEND_4(e))

#define HW_PARAMETER(...)   HW_MACROCAT(HW_PARAMETER_, HW_META_argCount(__VA_ARGS__))(__VA_ARGS__)
#define HW_BLOCK(...)       ^(HW_PARAMETER(__VA_ARGS__))


// KeyPath

#define HW_KEYPATH(OBJ, PATH) @(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
#define HWRx(OBJ, PATH) OBJ.Rx(HW_KEYPATH(OBJ, PATH))


#endif /* HWMacro_h */
