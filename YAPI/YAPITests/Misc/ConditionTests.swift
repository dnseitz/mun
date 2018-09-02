//
//  ConditionTests.swift
//  YAPITests
//
//  Created by Daniel Seitz on 11/30/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation
import XCTest

@testable import YAPI

class ConditionTests: YAPIXCTestCase {
  func test_Condition_Wait_ReturnsBroadcastedValue() {
    let condition = Condition<Int>()
    let expect = expectation(description: "Thread was awoken")
    let expectedValue = 5
    var actualValue: Int? = nil
    
    DispatchQueue.global().async {
      actualValue = condition.wait()
      expect.fulfill()
    }
    
    DispatchQueue.global().async {
      condition.broadcast(value: 5)
    }
    
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      XCTAssertEqual(actualValue, expectedValue)
    }
  }
  
  func test_Condition_Broadcast_WakesAllWaitingThreads() {
    let condition = Condition<()>()
    let expect = expectation(description: "Thread was awoken")
    let expect2 = expectation(description: "Second thread was awoken")
    let expect3 = expectation(description: "Third thread was awoken")
    
    DispatchQueue.global().async {
      condition.wait()
      expect.fulfill()
    }
    
    DispatchQueue.global().async {
      condition.wait()
      expect2.fulfill()
    }
    
    DispatchQueue.global().async {
      condition.wait()
      expect3.fulfill()
    }
    
    DispatchQueue.global().async {
      condition.broadcast(value: ())
    }
    
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
    }
  }
}
