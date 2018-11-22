//
//  RequestParameter.swift
//  mun
//
//  Created by Daniel Seitz on 11/10/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI

struct RequestParameter: Parameter {
  let key: String
  let value: String
  
  init(key: String, value: CustomStringConvertible) {
    self.key = key
    self.value = value.description
  }
  
  init?(key: String, value: CustomStringConvertible?) {
    guard let value = value else { return nil }
    
    self.init(key: key, value: value)
  }
}
