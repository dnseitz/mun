//
//  Parameter.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation

public protocol Parameter : CustomStringConvertible {
  var key: String { get }
  var value: String { get }
}

protocol BooleanParameter : ExpressibleByBooleanLiteral, Parameter {
  var internalValue: Bool { get }
}

protocol StringParameter : ExpressibleByStringLiteral, Parameter {
  var internalValue: String { get }
}

protocol IntParameter : ExpressibleByIntegerLiteral, Parameter {
  var internalValue: Int { get }
}

protocol DoubleParameter : ExpressibleByFloatLiteral, Parameter {
  var internalValue: Double { get }
}

protocol ArrayParameter : ExpressibleByArrayLiteral, Parameter {
  associatedtype Element
  
  var internalValue: [Self.Element] { get }
  
  init(_ elements: [Self.Element])
}

extension Parameter {
  public var description: String {
    return self.value
  }
}

extension BooleanParameter {
  public var value: String {
    return String(self.internalValue)
  }
  
  public init(_ value: BooleanLiteralType) {
    self.init(booleanLiteral: value)
  }
}

extension StringParameter {
  public var value: String {
    return self.internalValue
  }
  
  public init(_ value: StringLiteralType) {
    self.init(stringLiteral: value)
  }
}

extension IntParameter {
  public var value: String {
    return String(self.internalValue)
  }
  
  public init(_ value: IntegerLiteralType) {
    self.init(integerLiteral: value)
  }
}

extension DoubleParameter {
  public var value: String {
    return String(self.internalValue)
  }
  
  public init(_ value: FloatLiteralType) {
    self.init(floatLiteral: value)
  }
}

extension ArrayParameter {
  public var value: String {
    return self.internalValue.map() { "\($0)" }.joined(separator: ",")
  }
  
  public init(arrayLiteral elements: Self.Element...) {
    self.init(elements)
  }
}
