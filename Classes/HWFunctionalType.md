### 链式调用
- 示例
    - 点式
    - ~~方括号式~~

```
//点式
@[@1, @2, @3, @4, @5]
.filter(HW_BLOCK(HWIntNumber *) {
    return (BOOL)($0.intValue / 2 == 1);
})
.map(HW_BLOCK(HWIntNumber *) {
    return @($0.intValue * 100);
})
.reduce(@(0), HW_BLOCK(HWIntNumber *, HWIntNumber *) {
    return @($0.intValue + $1.intValue);
});

//方括号式
[[[@[@1, @2, @3, @4, @5] filter:HW_BLOCK(HWIntNumber *) {
    return (BOOL)($0.intValue / 2 == 1);
}] map:HW_BLOCK(HWIntNumber *) {
    return @($0.intValue * 100);
}] reduce:@(0) handle:HW_BLOCK(HWIntNumber *, HWIntNumber *) {
    return @($0.intValue + $1.intValue);
}];
```
- 实现：
    - readonly的block （实现.调用）
    - 参数视操作符不同，可传block可传数值 （实现逻辑回调）
    - 返回同类型对象 （实现链式调用）

```
// 示例
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
```

### then 操作符

- 实现：

```
#define Imp_then \
- (id(^)(thenType block))then { return ^(thenType block) { block(self); return self;}; }

```

- 作用：让层级更明晰

```
- (void)initView {
    
    _mediaView = [FEChannelMediaView new];
    [self.view addSubview:_mediaView.then(^(FEChannelMediaView *view) {
        view.frame = CGRectMake(0, 0, ATScreenLong, ATScreenShort);
        view.mediaType = MediaType_MMH;
    })];
    
    [self.view addSubview:[UIScrollView new].then(^(UIScrollView *scroll) {
        scroll.frame = CGRectMake(0, 0, ATScreenLong, ATScreenShort);
        scroll.contentSize = CGSizeMake(ATScreenLong * 2, ATScreenShort);
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.pagingEnabled = YES;
        scroll.bounces = NO;
        scroll.contentOffset = CGPointMake(ATScreenLong, 0);
        
        [scroll addSubview:[UIView new].then(^(UIView *view) {
            view.frame = CGRectMake(0, 0, ATScreenLong, ATScreenShort);
            view.backgroundColor = [UIColor clearColor];
        })];
        
        [scroll addSubview:[MMHMainView new].then(^(UIView *view) {
            view.x += ATScreenLong;
            view.backgroundColor = [UIColor clearColor];
        })];
    })];
    
    [self.view addSubview:[UIButton new].then(^(UIButton *btn) {
        btn.frame = CGRectMake(ATScreenLong - 32, 10, 22, 22);
        btn.alpha = 0.5;
        [btn setImage:[UIImage imageNamed:@"MMH_Close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onClickExit) forControlEvents:UIControlEventTouchUpInside];
    })];
}
```

### HW_BLOCK 宏
- 用途：用$0-$4代替block的变量名（想变量名困难户专用）
- 核心：计算参数个数
- 方式：先定义最多支持多少参数，量尺长度固定，未知数从前往后推，挤掉多少个预定值，未知数的个数就是多少

```
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
```

### NSArray+FunctionalType
- 定义了比较实用的数组操作
- 各操作均可链式调用

```
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
```