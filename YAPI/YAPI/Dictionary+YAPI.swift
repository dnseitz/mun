//
//  Dictionary+YAPI.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation

extension Dictionary where Key: StringProtocol {
  func parseParam<ReturnType>(key: Key) throws -> ReturnType {
    guard let value = self[key] as? ReturnType else { throw ParseError.missing(field: key.description) }
    return value
  }
}
