//
//  TSDataPersistenceMemoryCache.swift
//  TSDataPersistence
//
//  Created by 洪利 on 2018/6/22.
//  Copyright © 2018年 洪利. All rights reserved.
//

/**
 MemoryCache
 
 thread safe = concurrent + semaphore lock
 
 sync
 thread safe write = write + semaphore lock
 thread safe read = read + semaphore lokc
 
 async
 thread safe write = async concurrent queue + thread safe sync write
 thread safe read = async concurrent queue + thread safe sync read
 
 */


import Foundation
import UIKit



open class TSDataPersistenceMemoryCacheGenerator: IteratorProtocol{
    
    public typealias Element = (String, AnyObject)
    
    fileprivate var _lruGenerator: TSDataPersistenceLRUGenerator<TSDataPersistenceMemoryCacheObject>
    
    fileprivate var _completion: (() -> Void)?
    
    fileprivate init(generate: TSDataPersistenceLRUGenerator<TSDataPersistenceMemoryCacheObject>, cache: TSDataPersistenceMemoryCache, completion: (() -> Void)?) {
        self._lruGenerator = generate
        self._completion = completion
    }
    
    /**
     Advance to the next element and return it, or `nil` if no next element exists.
     
     - returns: next element
     */
    
    open func next() -> Element? {
        if let object = _lruGenerator.next() {
            return (object.key, object.value)
        }
        return nil
    }
    
    deinit {
        _completion?()
    }
    
}

private class TSDataPersistenceMemoryCacheObject: TSDataPersistenceLRUObject {
    
    var key: String = ""
    var cost: UInt = 0
    var time: TimeInterval = CACurrentMediaTime()
    var value: AnyObject
    
    init(key: String, value: AnyObject, cost: UInt = 0) {
        self.key = key
        self.value = value
        self.cost = cost
    }
}

public typealias MemoryCacheAsyncCompletion = (_ cache: TSDataPersistenceMemoryCache?, _ key: String?, _ object: AnyObject?) -> Void

/**
 MemoryCache is a thread safe cache implement by dispatch_semaphore_t lock and DISPATCH_QUEUE_CONCURRENT.
 Cache algorithms policy use LRU (Least Recently Used), implement by linked list and cache in NSDictionary.
 You can manage cache through functions to limit size, age of entries and memory usage to eliminate least recently used object.
 And support thread safe `for`...`in` loops, map, forEach...
 */
open class TSDataPersistenceMemoryCache {
    
    /**
     Memory cache object total count
     */
    open var totalCount: UInt {
        get {
            _lock()
            let count = _cache.count
            _unlock()
            return count
        }
    }
    
    /**
     Memory cache object total cost, if not set cost when set object, total cost may be zero
     */
    open var totalCost: UInt {
        get {
            _lock()
            let cost = _cache.cost
            _unlock()
            return cost
        }
    }
    
    fileprivate var _countLimit: UInt = UInt.max
    
    /**
     The maximum total count limit
     */
    open var countLimit: UInt {
        set {
            _lock()
            _countLimit = newValue
            _unsafeTrim(toCount: newValue)
            _unlock()
        }
        get {
            _lock()
            let countLimit = _countLimit
            _unlock()
            return countLimit
        }
    }
    
    fileprivate var _costLimit: UInt = UInt.max
    
    /**
     The maximum memory cost limit
     */
    open var costLimit: UInt {
        set {
            _lock()
            _costLimit = newValue
            _unsafeTrim(toCost: newValue)
            _unlock()
        }
        get {
            _lock()
            let costLimit = _costLimit
            _unlock()
            return costLimit
        }
    }
    
    fileprivate var _ageLimit: TimeInterval = DBL_MAX
    
    /**
     Memory cache object age limit
     */
    open var ageLimit: TimeInterval {
        set {
            _lock()
            _ageLimit = newValue
            _unsafeTrim(toAge: newValue)
            _unlock()
        }
        get {
            _lock()
            let ageLimit = _ageLimit
            _unlock()
            return ageLimit
        }
    }
    
    fileprivate var _autoRemoveAllObjectWhenMemoryWarning: Bool = true
    
    /**
     Auto remove all object when memory warning
     */
    open var autoRemoveAllObjectWhenMemoryWarning: Bool {
        set {
            _lock()
            _autoRemoveAllObjectWhenMemoryWarning = newValue
            _unlock()
        }
        get {
            _lock()
            let autoRemoveAllObjectWhenMemoryWarning = _autoRemoveAllObjectWhenMemoryWarning
            _unlock()
            return autoRemoveAllObjectWhenMemoryWarning
        }
    }
    
    fileprivate var _autoRemoveAllObjectWhenEnterBackground = false
    
    /**
     Auto remove all object when enter background
     */
    open var autoRemoveAllObjectWhenEnterBackground: Bool {
        set {
            _lock()
            _autoRemoveAllObjectWhenEnterBackground = newValue
            _unlock()
        }
        get {
            _lock()
            let autoRemoveAllObjectWhenEnterBackground = _autoRemoveAllObjectWhenEnterBackground
            _unlock()
            return autoRemoveAllObjectWhenEnterBackground
        }
    }
    
    fileprivate let _cache: LRU = LRU<TSDataPersistenceMemoryCacheObject>()
    
    fileprivate let _queue: DispatchQueue = DispatchQueue(label: TrackCachePrefix + String(describing: TSDataPersistenceMemoryCache.self), attributes: DispatchQueue.Attributes.concurrent)
    
    fileprivate let _semaphoreLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    /**
     A share memory cache
     */
    open static let shareInstance = TSDataPersistenceMemoryCache()
    
    /**
     Design constructor
     */
    public init () {
        NotificationCenter.default.addObserver(self, selector: #selector(TSDataPersistenceMemoryCache._didReceiveMemoryWarningNotification), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TSDataPersistenceMemoryCache._didEnterBackgroundNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}

//  MARK:
//  MARK: Public
public extension TSDataPersistenceMemoryCache {
    
    //  MARK: Async
    /**
     Async store an object for the unique key in memory cache and add object to linked list head
     completion will be call after object has been store in memory
     
     - parameter object:     object
     - parameter key:        unique key
     - parameter completion: stroe completion call back
     */
    public func set(object: AnyObject, forKey key: String, cost: UInt = 0, completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, key, object); return }
            strongSelf.set(object: object, forKey: key, cost: cost)
            completion?(strongSelf, key, object)
        }
    }
    
    /**
     Async search object according to unique key
     if find object, object will move to linked list head
     */
    public func object(forKey key: String, completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, key, nil); return }
            let object = strongSelf.object(forKey: key)
            completion?(strongSelf, key, object)
        }
    }
    
    /**
     Async remove object according to unique key from cache dic and linked list
     */
    public func removeObject(forKey key: String, completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, key, nil); return }
            strongSelf.removeObject(forKey: key)
            completion?(strongSelf, key, nil)
        }
    }
    
    /**
     Async remove all object and info from cache dic and clean linked list
     */
    public func removeAllObjects(_ completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, nil, nil); return }
            strongSelf.removeAllObjects()
            completion?(strongSelf, nil, nil)
        }
    }
    
    /**
     Async trim memory cache total to countLimit according LRU
     
     - parameter countLimit: maximum countLimit
     */
    public func trim(toCount countLimit: UInt, completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, nil, nil); return }
            strongSelf.trim(toCount: countLimit)
            completion?(strongSelf, nil, nil)
        }
    }
    
    /**
     Async trim memory cache totalcost to costLimit according LRU
     
     - parameter costLimit:  maximum costLimit
     */
    public func trim(toCost costLimit: UInt, completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, nil, nil); return }
            strongSelf.trim(toCost: costLimit)
            completion?(strongSelf, nil, nil)
        }
    }
    
    /**
     Async trim memory cache objects which age greater than ageLimit
     
     - parameter ageLimit:  maximum ageLimit
     */
    public func trim(toAge ageLimit: TimeInterval, completion: MemoryCacheAsyncCompletion?) {
        _queue.async { [weak self] in
            guard let strongSelf = self else { completion?(nil, nil, nil); return }
            strongSelf.trim(toAge: ageLimit)
            completion?(strongSelf, nil, nil)
        }
    }
    
    //  MARK: Sync
    /**
     Sync store an object for the unique key in memory cache and add object to linked list head
     */
    public func set(object: AnyObject, forKey key: String, cost: UInt = 0) {
        _lock()
        _unsafeSet(object: object, forKey: key, cost: cost)
        _unlock()
    }
    
    /**
     Async search object according to unique key
     if find object, object will move to linked list head
     */
    
    public func object(forKey key: String) -> AnyObject? {
        var object: AnyObject? = nil
        _lock()
        let memoryObject: TSDataPersistenceMemoryCacheObject? = _cache.object(forKey: key)
        memoryObject?.time = CACurrentMediaTime()
        object = memoryObject?.value
        _unlock()
        return object
    }
    
    /**
     Sync remove object according to unique key from cache dic and linked list
     */
    public func removeObject(forKey key: String) {
        _lock()
        _ = _cache.removeObject(forKey:key)
        _unlock()
    }
    
    /**
     Sync remove all object and info from cache dic and clean linked list
     */
    public func removeAllObjects() {
        _lock()
        _cache.removeAllObjects()
        _unlock()
    }
    
    /**
     Sync trim memory cache totalcost to costLimit according LRU
     */
    public func trim(toCount countLimit: UInt) {
        _lock()
        _unsafeTrim(toCount: countLimit)
        _unlock()
    }
    
    /**
     Sync trim memory cache totalcost to costLimit according LRU
     */
    public func trim(toCost costLimit: UInt) {
        _lock()
        _unsafeTrim(toCost: costLimit)
        _unlock()
    }
    
    /**
     Sync trim memory cache objects which age greater than ageLimit
     */
    public func trim(toAge ageLimit: TimeInterval) {
        _lock()
        _unsafeTrim(toAge: ageLimit)
        _unlock()
    }
    
    /**
     subscript method, sync set and get
     
     - parameter key: object unique key
     */
//    public subscript(key: String) -> AnyObject? {
//        get {
//            return object(forKey: key)
//        }
//        set {
//            if let newValue = newValue {
//                set(newValue, forKey: key)
//            } else {
//                removeObject(forKey: key)
//            }
//        }
//    }
}

//  MARK: SequenceType
extension TSDataPersistenceMemoryCache : Sequence {
    /**
     MemoryCacheGenerator
     */
    public typealias Iterator = TSDataPersistenceMemoryCacheGenerator
    
    /**
     Returns a generator over the elements of this sequence.
     It is thread safe, if you call `generate()`, remember release it,
     otherwise maybe it lead to deadlock.
     
     - returns: A generator
     */
    
    public func makeIterator() -> TSDataPersistenceMemoryCacheGenerator {
        var generatror: TSDataPersistenceMemoryCacheGenerator
        _lock()
        generatror = TSDataPersistenceMemoryCacheGenerator(generate: _cache.makeIterator(), cache: self) {
            self._unlock()
        }
        return generatror
    }
}

//  MARK:
//  MARK: Private
extension TSDataPersistenceMemoryCache {
    
    @objc fileprivate func _didReceiveMemoryWarningNotification() {
        if self.autoRemoveAllObjectWhenMemoryWarning {
            removeAllObjects(nil)
        }
    }
    
    @objc fileprivate func _didEnterBackgroundNotification() {
        if self.autoRemoveAllObjectWhenEnterBackground {
            removeAllObjects(nil)
        }
    }
    
    fileprivate func _unsafeTrim(toCount countLimit: UInt) {
        if _cache.count <= countLimit {
            return
        }
        if countLimit == 0 {
            _cache.removeAllObjects()
            return
        }
        if let _: TSDataPersistenceMemoryCacheObject = _cache.lastObject() {
            while (_cache.count > countLimit) {
                _cache.removeLastObject()
                guard let _: TSDataPersistenceMemoryCacheObject = _cache.lastObject() else { break }
            }
        }
    }
    
    fileprivate func _unsafeTrim(toCost costLimit: UInt) {
        if _cache.cost <= costLimit {
            return
        }
        if costLimit == 0 {
            _cache.removeAllObjects()
            return
        }
        if let _: TSDataPersistenceMemoryCacheObject = _cache.lastObject() {
            while (_cache.cost > costLimit) {
                _cache.removeLastObject()
                guard let _: TSDataPersistenceMemoryCacheObject = _cache.lastObject() else { break }
            }
        }
    }
    
    fileprivate func _unsafeTrim(toAge ageLimit: TimeInterval) {
        if ageLimit <= 0 {
            _cache.removeAllObjects()
            return
        }
        if var lastObject: TSDataPersistenceMemoryCacheObject = _cache.lastObject() {
            while (CACurrentMediaTime() - lastObject.time > ageLimit) {
                _cache.removeLastObject()
                guard let newLastObject: TSDataPersistenceMemoryCacheObject = _cache.lastObject() else { break }
                lastObject = newLastObject
            }
        }
    }
    
    func _unsafeSet(object: AnyObject, forKey key: String, cost: UInt = 0) {
        _cache.set(object: TSDataPersistenceMemoryCacheObject(key: key, value: object, cost: cost), forKey: key)
        if _cache.cost > _costLimit {
            _unsafeTrim(toCost: _costLimit)
        }
        if _cache.count > _countLimit {
            _unsafeTrim(toCount: _countLimit)
        }
    }
    
    fileprivate func _lock() {
        _ = _semaphoreLock.wait(timeout: DispatchTime.distantFuture)
    }
    
    fileprivate func _unlock() {
        _semaphoreLock.signal()
    }
}



