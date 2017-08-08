# HWRxObserver
### 概要
对 ```Objective-C``` 中 ```KVO``` 、```Notification``` 的封装，配合函数式操作符，实现轻量级的函数响应式范式。

### 说明


#### HWRxObserver
类库的主要类，包含各种操作符，全部都是热信号，使用```behavior+connect```能实现带一个缓存的信号。

- **Base_Extension**: 主要的操作符，链式调用时返回的是同一个```observer```，使用```disposeBy```可以指定负责销毁该```observer```的对象
- **Create_Extension**: ```0.4.0```新加的功能，用于创建自定义的```observer```，使用```next```来发送数据。使用```HWRxInstance.asObservable()```创建的```observer```，没有加入任何对象中，由创建者负责销毁。
- **Functional_Extension**: 一些信号处理的操作符，返回的是新的```observer```（```type```为```HWRxObserverType_UnOwned```，这种```observer```由被操作的```observer```的```block```所持有，当上级```observer```被销毁时自动销毁）
- **NSArray RxObserver_Extension**: 多个```observer```的集合操作，返回的也是```HWRxObserverType_UnOwned```的```observer```

#### NSObject+RxObserver
定义生成Observer的方法，以及自动释放的方法

- **NSObject (RxObserver_Base)**: 给NSObject类添加的Rx支持方法，包括存储的容器和销毁的方法。
	- **rx_observers**: 每调用一次Rx，就会创建一个```observer```，存储观察的```keyPath(KVO)```或者观察的```Notification```，```observer```销毁时会去注销```KVO``或```Notification```
	- **rx_ delegateTo_disposers**: 配合```HWRxObserver```的```disposeBy```操作符，本类调用```executeDisposalBy:```时，会销毁被代理的```Observer```。（主要场景：单例.Rx()之后，由于单例一直存在，导致相关的```observer```不能被释放，调用```disposeBy(A)```，A可以调用```executeDisposalBy:```来销毁所用到的```单例observer```）
- **NSObject (RxObserver)**: 定义```Rx、RxOnce```等主要操作符，Rx的开始。```0.3.0```版本```hook```了```NSObject```的```dealloc```方法，在dealloc前，自动释放```rx_observers```数组和```rx_delegateTo_disposers```数组，这样上层不再需要关心释放```observer```。

#### NSNotificationCenter+RxObserver
- 重定义```NotificationCenter```对Rx的处理为：注册```Notification```；
- 重定义```rx_repose```的实现
- 重定义```remove```的实现

#### UIView+RxObserver
- ```rx_tap```点击事件的处理

#### UITableView & UICollectionView + RxObserver
通过把tableView、collectionView与variable绑定，实现只需要改变variable的内容，对应控件的数据自动变化。

- **HWRxVariable**：内部是一个```MutableArray```，在容器变化的时候，通过一个自建的```observer```往外发信号。
- **RxDataSource**：```cell```与绑定的```variable```数据量一致，一个```variable```为一个```section```。目前只实现在一个```section```中只有一个```cell```类。```register```用来注册```cell```（nib 或 class），设置```reusableIDs```(数量要跟```variable```数量一样)后，在```cellForItem```可以直接套数据。
- **RxDelegate**：与```DataSource```分开的原因是，```delegate```方法比较多，```RxDelegate```只提供常用的，若使用未覆盖到的代理，可以舍弃```RxDelegate```，只用```RxDataSource```。

### 详见Demo

