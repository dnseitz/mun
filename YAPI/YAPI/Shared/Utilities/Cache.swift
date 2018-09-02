//
//  Cache.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/18/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

// Used to uniquely identify cacheAccessQueues
private var id: Int = 0

public protocol Cacheable: class {
  var isCacheable: Bool { get }
  var cacheKey: CacheKey { get }
}

public struct CacheKey {
  fileprivate let key: String
  
  public init(_ key: String) {
    self.key = key
  }
}

final public class Cache<Stored: Cacheable> {
  private var internalCache = [String: Stored]()
  private let cacheAccessQueue: DispatchQueue
  let identifier: String
  
  public init(identifier: String) {
    self.identifier = identifier
    self.cacheAccessQueue = DispatchQueue(label: "com.yapi.cache-access.\(identifier)-\(id)", attributes: .concurrent)
    id += 1
  }
  
  // TODO (dseitz): Uh... I think statics in Swift are automatically synchronized across
  // threads... So I don't think we need any of these synchronization operations... Let's
  // do some research
  public subscript(key: CacheKey) -> Stored? {
    get {
      var imageReference: Stored? = nil
      self.readLock() {
        imageReference = self.internalCache[key.key]
      }
      return imageReference
    }
  }
  
  /**
   Flush all items from the cache
   */
  public func flush() {
    log(.info, for: .caching, message: "Cache (\(identifier)) was flushed")
    self.writeLock() {
      self.internalCache.removeAll()
    }
  }
  
  /**
   Check if an image for a given image reference is stored in the cache
   
   - Parameter object: The object to check for inclusion
   
   - Returns: true if the object is in the cache, false if it is not
   */
  public func contains(_ object: Stored) -> Bool {
    return self[object.cacheKey] != nil
  }
  
  /**
   Insert an object into the cache
   
   - Parameter object: The object to insert into the cache
   
   - Returns: true if the object was successfully inserted, false otherwise
   */
  @discardableResult
  public func insert(_ object: Stored) -> Bool {
    guard object.isCacheable else { return false }
    
    let alreadyCached = internalCache[object.cacheKey.key]
    if alreadyCached != nil {
      if alreadyCached === object {
        log(.warning, for: .caching, message: "\(object) already stored in Cache '\(identifier)'")
        return true
      }
      else {
        log(.warning, for: .caching, message: "An object matching key '\(object.cacheKey.key) is already in Cache '\(identifier)' evicting old object")
      }
    }
    
    self.writeLock {
      self.internalCache[object.cacheKey.key] = object
    }
    return true
  }
  
  private func readLock(_ block: () -> Void) {
    self.cacheAccessQueue.sync(execute: block)
  }
  
  private func writeLock(_ block: () -> Void) {
    self.cacheAccessQueue.sync(flags: .barrier, execute: block)
  }
  
}
