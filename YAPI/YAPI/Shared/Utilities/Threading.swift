//
//  Threading.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/30/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

public class Condition<Signaled> {
  private let condition: NSCondition = NSCondition()
  private var value: Signaled?
  
  public init() {}
  
  @discardableResult
  public func wait() -> Signaled {
    condition.lock()
    defer {
      condition.unlock()
    }
    
    while true {
      if let value = value {
        return value
      }
      condition.wait()
      guard let value = value else {
        continue
      }
      
      return value
    }
  }
  
  public func broadcast(value: Signaled) {
    condition.lock()
    defer {
      condition.unlock()
    }
    
    self.value = value
    condition.broadcast()
  }
}
