//
//  YAPIXCNetworkTestCase.swift
//  YAPITests
//
//  Created by Daniel Seitz on 12/2/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation
@testable import YAPI

class YAPIXCNetworkTestCase: YAPIXCTestCase {
  lazy var session: HTTPClient = {
    return HTTPClient(session: mockSession)
  }()
  private(set) var mockSession = MockURLSession()
  
  override func tearDown() {
    mockSession = MockURLSession()
    
    super.tearDown()
  }
}
