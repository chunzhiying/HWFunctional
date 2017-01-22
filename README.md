# HWFunctional
### 概要
汲取```Swift```中的函数式思想，为```Objective-C```定制的函数式工具

1. **NSArray、NSDictionary类别**：
实现了基本的函数式操作符，如```map```、```reduce```、```filter```等。

2. **HWRxObserver**：
对```Objective-C```中```KVO```、```Notification```的封装，配合函数式操作符，实现轻量级的函数响应式范式。

3. **HWAnimation**：
```CoreAnimation```的函数式封装，极大地减少了代码量。

4. **HWPomise**：
灵感来源于```PromiseKit```，这是对```block```回调的一个封装，支持处理并发式、上下文依赖式的```callback hell```。


### Cocoapods 版本说明

**```0.0.2```**：```包含NSArray&NSDictionary类别，HWRxObserver，HWAnimation，HWPromise等基本功能。```
