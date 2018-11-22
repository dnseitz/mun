//
//  MoonPhaseSearchRequestParameters.swift
//  mun
//
//  Created by Daniel Seitz on 11/10/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI

struct MoonPhaseSearchRequestLimitParameter: IntParameter {
  typealias IntegerLiteralType = Int

  let internalValue: Int
  let key: String = "limit"
  
  init(integerLiteral value: Int) {
    self.internalValue = value
  }
}
