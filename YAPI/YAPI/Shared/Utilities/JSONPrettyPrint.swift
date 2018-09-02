//
//  JSONPrettyPrint.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/16/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

func jsonStringify(_ value: Any) -> String {
  if JSONSerialization.isValidJSONObject(value) {
    do {
      let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
      if let string = String(data: data, encoding: String.Encoding.utf8) {
        return string
      }
    }  catch {
      return ""
    }
  }
  return ""
}
