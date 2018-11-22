//
//  ParameterList.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/10/18.
//  Copyright © 2018 Daniel Seitz. All rights reserved.
//

import Foundation

public struct ParameterList {
  private(set) var parameterDictionary: [String: String]
  
  public subscript(key: CustomStringConvertible) -> CustomStringConvertible? {
    get {
      return parameterDictionary[key.description]
    }
    
    set {
      parameterDictionary[key.description] = newValue?.description
    }
  }
  
  public init(parameters: [Parameter] = []) {
    self.parameterDictionary = [:]
    
    for parameter in parameters {
      add(parameter: parameter)
    }
  }
  
  public mutating func add(parameter: Parameter) {
    assert(parameterDictionary[parameter.key] == nil, "Should not have duplicate parameter entries")
    parameterDictionary[parameter.key] = parameter.value
  }
  
  public mutating func remove(parameter: Parameter) {
    parameterDictionary[parameter.key] = nil
  }
}
