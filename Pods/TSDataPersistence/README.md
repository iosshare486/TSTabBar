# TSDataPersistence

### 数据持久化解决方案
>1、支持本地缓存、内存缓存
>
>2、支持异步线程安全式存储
>
>3、支持数据淘汰策略
>


## 使用
//直接使用对象
`ts_cache`
### 字符串等轻量级数据
	//写入
	//默认方式存入数据
	ts_cache.set("洪利", forKey: "cacheObj")
	//单独向内存中存入数据
	ts_cache.memoryCache.set(object: "memoryDataCache", forKey: "memory")
	//单独向本地磁盘中存入数据
	ts_cache.memoryCache.set(object: "diskDataCache" as AnyObject, forKey: "disk")
	
	
	
	//读取
	if let md: cacheData = ts_cache.object(forKey: "cacheObj") {
            print(md)
        }
        
> `ts_cache`.set(...) 同时向内存、本地磁盘中存入
> 
> `ts_cache`.memoryCache.set(...)单独向内存中添加
> 
> `ts_cache`.diskCache.set(...)单独向本地磁盘中添加
> 
> `ts_cache`.object(...)读取时不区分存储路径
> 
> ps：model等对象需要遵循 Codable，如下        

	let model = AModel()
    ts_cache.set(model, forKey: "Model")
    if let md: AModel = ts_cache.object(forKey: "Model") {
        print(md)
    }

	//声明Amodel
	class AModel:Codable {
	    var name = "洪利"
	    var age = "8"
	    
	}

