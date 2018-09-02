//
//  Dictionary+YAPI.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
  mutating func insert(parameter: Parameter?) {
    if
      let parameter = parameter,
      let key = parameter.key as? Key,
      let value = parameter.value as? Value {
        self[key] = value
    }
  }
}

extension Dictionary where Key: StringProtocol {
  func parseParam<ReturnType>(key: Key) throws -> ReturnType {
    guard let value = self[key] as? ReturnType else { throw ParseError.missing(field: key.description) }
    return value
  }
}
