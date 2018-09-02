//
//  CacheTests.swift
//  YAPITests
//
//  Created by Daniel Seitz on 11/18/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

private typealias MockCache = Cache<MockCacheable>

private class MockCacheable: Cacheable {
  let isCacheable: Bool
  let cacheKey: CacheKey
  
  init(cacheKey: CacheKey, isCacheable: Bool = true) {
    self.cacheKey = cacheKey
    self.isCacheable = isCacheable
  }
}

class CacheTests: YAPIXCTestCase {
  func test_Cache_InsertCacheableObject_ReturnsTrue_CachesObject() {
    let cacheKey = CacheKey("key")
    
    let cache = MockCache(identifier: "mock")
    let object = MockCacheable(cacheKey: cacheKey)
    
    XCTAssertNil(cache[cacheKey])
    
    XCTAssertTrue(cache.insert(object))
    
    XCTAssert(cache[cacheKey] === object)
  }
  
  func test_Cache_InsertUncacheableObject_ReturnsFalse_DoesntCacheObject() {
    let cacheKey = CacheKey("key")
    
    let cache = MockCache(identifier: "mock")
    let object = MockCacheable(cacheKey: cacheKey, isCacheable: false)
    
    XCTAssertNil(cache[cacheKey])
    
    XCTAssertFalse(cache.insert(object))
    
    XCTAssertNil(cache[cacheKey])
  }
  
  func test_Cache_InsertCachedObject_ReturnsTrue_KeepsObjectInCache() {
    let cacheKey = CacheKey("key")
    
    let cache = MockCache(identifier: "mock")
    let object = MockCacheable(cacheKey: cacheKey)
    
    XCTAssertNil(cache[cacheKey])
    
    XCTAssertTrue(cache.insert(object))
    
    XCTAssert(cache[cacheKey] === object)
    
    XCTAssertTrue(cache.insert(object))
    
    XCTAssert(cache[cacheKey] === object)
  }
  
  func test_Cache_InsertCollidingObject_EvictsOldObject() {
    let cacheKey = CacheKey("key")
    
    let cache = MockCache(identifier: "mock")
    let object1 = MockCacheable(cacheKey: cacheKey)
    let object2 = MockCacheable(cacheKey: cacheKey)
    
    XCTAssertNil(cache[cacheKey])
    
    XCTAssertTrue(cache.insert(object1))
    
    XCTAssert(cache[cacheKey] === object1)
    
    XCTAssertTrue(cache.insert(object2))
    
    XCTAssert(cache[cacheKey] === object2)
  }
  
  func test_Cache_FlushCache_FlushesTheCache() {
    let cacheKey1 = CacheKey("key1")
    let cacheKey2 = CacheKey("key2")
    
    let cache = MockCache(identifier: "mock")
    let object1 = MockCacheable(cacheKey: cacheKey1)
    let object2 = MockCacheable(cacheKey: cacheKey2)
    
    XCTAssertNil(cache[cacheKey1])
    XCTAssertNil(cache[cacheKey2])
    
    cache.insert(object1)
    cache.insert(object2)
    
    XCTAssert(cache[cacheKey1] === object1)
    XCTAssert(cache[cacheKey2] === object2)
    
    cache.flush()
    
    XCTAssertNil(cache[cacheKey1])
    XCTAssertNil(cache[cacheKey2])
  }
  
  func test_Cache_ContainsCachedObject_ReturnsTrue() {
    let cacheKey = CacheKey("key")
    
    let cache = MockCache(identifier: "mock")
    let object = MockCacheable(cacheKey: cacheKey)
    
    cache.insert(object)
    
    XCTAssertTrue(cache.contains(object))
  }
  
  func test_Cache_ContainsUncachedObject_ReturnsFalse() {
    let cacheKey = CacheKey("key")
    
    let cache = MockCache(identifier: "mock")
    let object = MockCacheable(cacheKey: cacheKey)
    
    XCTAssertFalse(cache.contains(object))
  }
}
