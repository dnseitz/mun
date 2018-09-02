//
//  Atomics.swift
//  YAPI
//
//  Created by Daniel Seitz on 12/19/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

public struct Atomic<T> {
  private var value: T
  private let lock: NSRecursiveLock

  public init(_ value: T) {
    self.value = value
    self.lock = NSRecursiveLock()
  }
  
  public mutating func set(_ value: T) {
    execute {
      self.value = value
    }
  }
  
  public func get() -> T {
    return execute { return self.value }
  }
  
  public mutating func swap(_ newValue: T) -> T {
    return execute {
      let oldValue = self.value
      self.value = newValue
      return oldValue
    }
  }
  
  public mutating func update(updateBlock: (T) -> T) {
    execute {
      self.value = updateBlock(self.value)
    }
  }
  
  private func execute<R>(block: () -> R) -> R {
    lock.lock()
    let result = block()
    lock.unlock()
    return result
  }
}

public extension Atomic where T: Equatable {
  mutating func compareAndSwap(old: T, new: T) -> Bool {
    return execute {
      if self.value == old {
        self.value = new
        return true
      }
      return false
    }
  }
}
