//
//  MockObjects.swift
//  YAPITests
//
//  Created by Daniel Seitz on 12/2/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation
import YAPI

// TODO: Make this private and fix any unit tests it breaks
struct MockError: APIError {
  var description: String {
    return "A Mock Error"
  }
}

enum Mock {
  static let url: URL = URL(string: "https://google.com")!
  static let error: APIError = MockError()
}
