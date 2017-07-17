# HWPromise
### 概要
灵感来源于 ```PromiseKit```，这是异步回调的一个封装，支持处理并发式、上下文依赖式的 ```callback hell``` 。

#### 说明
- ```promise``` 由异步回调的```block```持有，上层不强持有```promise```对象，则```promise```的```block```中是不存在```retain cycle```。
 
```
- (HWPromise *)after:(NSUInteger)time result:(BOOL)result flag:(NSString *)flag {
    HWPromise *promise = [HWPromise new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%lu, %@, %@", (unsigned long)time, @(result), flag);
        if (result) {
            promise.successObj = [NSString stringWithFormat:@"成功,%@" ,flag];
        } else {
            promise.failObj = [NSString stringWithFormat:@"失败,%@",flag];
        }
    });
    return promise;
}
```
- 调用：

```
    [self after:1 result:YES flag:@"一"]
    .success(HW_BLOCK(id) {
    
    }).fail(HW_BLOCK(id) {
    
    }).always(HW_BLOCK(HWPromiseResult *) {
        
    });
```
  
#### 并发式 callback hell
 处理时需使用```complete```操作符，回调的结果会与调用的顺序一致

```
    @[[self after:1 result:YES flag:@"一"],
      [self after:3 result:YES flag:@"二"],
      [self after:1 result:YES flag:@"三"],
      [self after:2 result:YES flag:@"四"],
      [self after:1 result:NO flag:@"五"],
      [self after:9 result:YES flag:@"六"],
      [self after:1 result:YES flag:@"七"],
      [self after:1 result:NO flag:@"八"],
      [self after:1 result:YES flag:@"九"]]
    .promise
    .complete(^(NSArray *results) {
        NSLog(@"全部完成:%@", results);
    });
```

#### 上下文依赖 callback hell
 处理时使用```next```操作符，```next```返回的数据即为这次调用的数据，当链式调用时，中途某次```fail```，会直接在最后一步以该次的```fail```返回

```
        [self after:1 result:YES flag:@"一"]
        .next(^(id obj) {
           return [self after:1 result:YES flag:@"二"];
        })
        .next(^(id obj) {
            return [self after:1 result:NO flag:@"三"];
        })
        .next(^(id obj) {
            return [self after:1 result:YES flag:@"四"];
        })
        .next(^(id obj) {
            return [self after:1 result:YES flag:@"五"];
        })
        .next(^(id obj) {
           return  [self after:1 result:YES flag:@"六"];
        })
        .next(^(id obj) {
           return  [self after:1 result:YES flag:@"七"];
        })
        .always(^(HWPromiseResult *obj) {
            NSLog(@"all finised %@", obj.object);
        });
```
结果：

```
2017-07-17 17:55:26.613 HWRxObserverDemo[8950:473736] 1, 1, 一
2017-07-17 17:55:27.710 HWRxObserverDemo[8950:473736] 1, 1, 二
2017-07-17 17:55:28.810 HWRxObserverDemo[8950:473736] 1, 0, 三
2017-07-17 17:55:28.811 HWRxObserverDemo[8950:473736] all finised 失败,三
```

