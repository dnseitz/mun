//
//  AssertOverride.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/1/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation

public enum Asserts {
  public static var shouldAssert: Bool = true
}

// Disable asserts for testing
public func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
  if Asserts.shouldAssert {
    Swift.assert(condition, message, file: file, line: line)
  }
  else {
    print("Assertion with message: \(message()) in file: \(file) at line: \(line)")
  }
}

public func assertionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
  if Asserts.shouldAssert {
    Swift.assertionFailure(message, file: file, line: line)
  }
  else {
    print("Assertion Failure with message: \(message()) in file: \(file) at line: \(line)")
  }
}
