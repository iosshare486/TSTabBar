//
//  TSDataPersistenceCache.swift
//  TSDataPersistence
//
//  Created by 洪利 on 2018/6/22.
//  Copyright © 2018年 洪利. All rights reserved.
//

import Foundation

/**
 CacheGenerator, support `for...in` loops, it is thread safe.
 */
open class TSDataPersistenceCacheGenerator : IteratorProtocol {
    
    public typealias Element = (String, AnyObject)
    
    fileprivate var _memoryCacheGenerator: TSDataPersistenceMemoryCacheGenerator
    
    fileprivate var _diskCacheGenerator: TSDataPersistenceDiskCacheGenerator
    
    fileprivate var _memoryCache: TSDataPersistenceMemoryCache
    
    fileprivate let _semaphoreLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    fileprivate init(memoryCacheGenerator: TSDataPersistenceMemoryCacheGenerator, diskCacheGenerator: TSDataPersistenceDiskCacheGenerator, memoryCache: TSDataPersistenceMemoryCache) {
        self._memoryCacheGenerator = memoryCacheGenerator
        self._diskCacheGenerator = diskCacheGenerator
        self._memoryCache = memoryCache
    }
    
    /**
     Advance to the next element and return it, or `nil` if no next element exists.
     
     - returns: next element
     */
    
    open func next() -> Element? {
        if let element = _memoryCacheGenerator.next() {
            self._diskCacheGenerator.shift()
            return element
        }
        else {
            if let element: Element = _diskCacheGenerator.next() as! TSDataPersistenceCacheGenerator.Element? {
                _memoryCache._unsafeSet(object: element.1, forKey: element.0)
                return element
            }
        }
        return nil
    }
}

/**
 Cache async operation callback
 */
public typealias CacheAsyncCompletion = (_ cache: TSDataPersistenceCache?, _ key: String?, _ object: Any?) -> Void

/**
 Cache Prefix, use on default disk cache folder name and queue name
 */
let TrackCachePrefix: String = "com.tsdpcache."

/**
 Cache default name, default disk cache folder name
 */
let TrackCacheDefauleName: String = "defaultTSDPCache"

/**
 this is a thread safe cache, contain a thread safe memory cache and a thread safe diskcache.
 And support thread safe `for`...`in` loops, map, forEach...
 */

public let ts_cache = TSDataPersistenceCache.shareInstance

open class TSDataPersistenceCache {
    
    /**
     cache name, used to create disk cache folder
     */
    open let name: String
    
    /**
     Thread safe memeory cache
     */
    open let memoryCache: TSDataPersistenceMemoryCache
    
    /**
     Thread safe disk cache
     */
    open let diskCache: TSDataPersistenceDiskCache
    
    fileprivate let _queue: DispatchQueue = DispatchQueue(label: TrackCachePrefix + (String(describing: TSDataPersistenceCache.self)), attributes: DispatchQueue.Attributes.concurrent)
    
    /**
     A share cache, contain a thread safe memory cache and a thread safe diskcache
     */
    open static let shareInstance = TSDataPersistenceCache(path: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])!
    
    /**
     Design constructor
     The same name has the same diskCache, but different memorycache.
     
     - parameter name: cache name
     - parameter path: diskcache path
     */
    public init?(name: String, path: String) {
        if name.characters.count == 0 || path.characters.count == 0 {
            return nil
        }
        self.diskCache = TSDataPersistenceDiskCache(name: name, path: path)!
        self.name = name
        self.memoryCache = TSDataPersistenceMemoryCache.shareInstance
    }
    
    /**
     Convenience constructor, use default path Library/Caches/
     
     - parameter name: cache name
     */
    public convenience init?(path: String){
        self.init(name: TrackCacheDefauleName, path: path)
    }
}

//  MARK:
//  MARK: Public
public extension TSDataPersistenceCache {
    //  MARK: Async
    /**
     Async store an object for the unique key in the memory cache and disk cache
     completion will be call after object has been store in memory cache and disk cache
     
     - parameter object:     object must be implement NSCoding protocal
     - parameter key:        unique key
     - parameter completion: stroe completion call back
     */
//    public func set(_ object: T, forKey key: String, completion: CacheAsyncCompletion?) {
//        _queue.async { [weak self] in
//            guard let strongSelf = self else { completion?(nil, key, object); return }
//            strongSelf.set(object, forKey: key)
//            completion?(strongSelf, key, object)
//        }
//    }
    public func set<T:Codable>(_ object: T, forKey key: String, completion: CacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, key, object); return }
            strongSelf.set(object, forKey: key)
            completion?(strongSelf, key, object)
        }
    }
    public func setObject<T: Codable>(_ object: T, forKey key: String, completion: CacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, key, object); return }
            strongSelf.set(object, forKey: key)
            completion?(strongSelf, key, object)
        }
    }
    /**
     Async search object according to unique key
     search from memory cache first, if not found, will search from diskCache
     
     - parameter key:        object unique key
     - parameter completion: search completion call back
     */
    public func object(forKey key: String, completion: CacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.memoryCache.object(forKey: key) { [weak self] (memCache, memKey, memObject) in
                guard let strongSelf = self else { return }
                if memObject != nil {
                    strongSelf._queue.async { [weak self] in
                        completion?(self, memKey, memObject)
                    }
                }
                else {
                    strongSelf.diskCache.object(forKey: key) { [weak self] (diskCache, diskKey, diskObject) in
                        guard let strongSelf = self else { return }
                        if let diskKey = diskKey, let diskCache = diskCache {
                            strongSelf.memoryCache.set(object: diskCache, forKey: diskKey, completion: nil)
                        }
                        strongSelf._queue.async { [weak self] in
                            completion?(self, diskKey, diskObject)
                        }
                    }
                }
            }
        }
    }
    
    /**
     Async remove object from memory cache and disk cache
     
     - parameter key:        object unique key
     - parameter completion: remove completion call back
     */
    public func removeObject(forKey key: String, completion: CacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, key, nil); return }
            strongSelf.removeObject(forKey: key)
            completion?(strongSelf, key, nil)
        }
        
    }
    
    /**
     Async remove all objects
     
     - parameter completion: remove completion call back
     */
    public func removeAllObjects(_ completion: CacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, nil, nil); return }
            strongSelf.removeAllObjects()
            completion?(strongSelf, nil, nil)
        }
        
    }
    
    //  MARK: Sync
    /**
     Sync store an object for the unique key in the memory cache and disk cache
     
     - parameter object:     object must be implement NSCoding protocal
     - parameter key:        unique key
     - parameter completion: stroe completion call back
     */
    
    public func set<T:Codable>(_ object: T, forKey key: String) {
        
        do {
            let encoder = JSONEncoder()
            let aData = try encoder.encode(object)
            memoryCache.set(object: aData as AnyObject, forKey: key)
            diskCache.set(aData, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    public func setObject<T:Codable>(_ object:T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(object) {
            memoryCache.set(object: data as AnyObject, forKey: key)
            diskCache.set(data, forKey: key)
        }
        
    }
    
    /**
     Sync search an object according to unique key
     search from memory cache first, if not found, will search from diskCache
     
     - parameter key:        object unique key
     - parameter completion: search completion call back
     */
    
//    public func object(forKey key: String) -> AnyObject? {
//        if let object = memoryCache.object(forKey: key) {
//            return object
//        }
//        else {
//            if let object = diskCache.object(forKey: key) {
//                memoryCache.set(object: object, forKey: key)
//                return object
//            }
//        }
//        return nil
//    }
    public func object<T: Codable>(forKey key: String) -> T? {
        if let object = memoryCache.object(forKey: key) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(T.self, from: object as! Data)
                return model
            } catch {
                print(error.localizedDescription)
            }

        }
        else {
            if let object = diskCache.object(forKey: key) {
                memoryCache.set(object: object, forKey: key)
                
                let decoder = JSONDecoder()
                do {
                    let model = try decoder.decode(T.self, from: object as! Data)
  
                    return model
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        return nil
    }
    /**
     Sync remove object from memory cache and disk cache
     
     - parameter key:        object unique key
     */
    public func removeObject(forKey key: String) {
        memoryCache.removeObject(forKey: key)
        diskCache.removeObject(forKey: key)
    }
    
    /**
     Sync remove all objects
     */
    public func removeAllObjects() {
        memoryCache.removeAllObjects()
        diskCache.removeAllObjects()
    }
    
    /**
     subscript method, sync set and get
     
     - parameter key: object unique key
     */
    //    public subscript(key: String) -> NSCoding? {
    //        get {
    //            if let returnValue = object(forKey: key) as? NSCoding {
    //                return returnValue
    //            }
    //            return nil
    //        }
    //        set {
    //            if let newValue = newValue {
    //                set(object: newValue, forKey: key)
    //            }
    //            else {
    //                removeObject(forKey: key)
    //            }
    //        }
    //    }
}

//  MARK: SequenceType
extension TSDataPersistenceCache : Sequence {
    /**
     CacheGenerator
     */
    public typealias Iterator = TSDataPersistenceCacheGenerator
    
    /**
     Returns a generator over the elements of this sequence.
     It is thread safe, if you call `generate()`, remember release it,
     otherwise maybe it lead to deadlock.
     
     - returns: A generator
     */
    
    public func makeIterator() -> TSDataPersistenceCacheGenerator {
        var generatror: TSDataPersistenceCacheGenerator
        generatror = TSDataPersistenceCacheGenerator(memoryCacheGenerator: memoryCache.makeIterator(), diskCacheGenerator: diskCache.makeIterator(), memoryCache: memoryCache)
        return generatror
    }
}

