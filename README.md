# HWFunctional
### 概要
汲取 ```Swift``` 中的函数式思想，为 ```Objective-C``` 定制的函数式工具

1. **NSArray、NSDictionary类别**：
实现了基本的函数式操作符，如 ```map```、```reduce```、```filter``` 等。

2. **HWRxObserver**：
对 ```Objective-C``` 中 ```KVO``` 、```Notification``` 的封装，配合函数式操作符，实现轻量级的函数响应式范式。[更多](https://github.com/chunzhiying/HWFunctional/tree/master/Classes/HWRxObserver)

3. **HWPomise**：
灵感来源于 ```PromiseKit```，这是对 ```block``` 回调的一个封装，支持处理并发式、上下文依赖式的 ```callback hell``` 。[更多](https://github.com/chunzhiying/HWFunctional/tree/master/Classes/HWPromise)

4. **HWAnimation**：
```CoreAnimation``` 的函数式封装，极大地减少了代码量。

5. **HWEnum**：类似 ```Swift``` 的 ```enum```，能存储额外的数据，并由此衍生了```HWOptional```。


### Cocoapods 

#### 使用
```pod 'HWFunctional', '= 0.4.2'```


#### 版本说明
**```0.0.2```**：```包含NSArray&NSDictionary类别，HWRxObservdder，HWAnimation，HWPromise等基本功能。```

**```0.1.0```**：```添加HWEnum。``` 

**```0.2.0```**：```添加HWMacro、HWTypeDef，提供常用宏，以及Parameter的便捷写法。```

**```0.3.0```**：```HWRxObserver添加自动释放，上层可不再调用释放```

**```0.4.0```**：```HWRxObserver能创建自定义信号，Cocoa上的应用```

**```0.5.0```**：```集成HWWeakTimer，提供计时器相关操作符```

**```0.6.0```**：```对现有功能模块的进一步优化，添加KVO的快速宏编写```