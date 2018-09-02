//
//  YelpV3TokenResponseTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 10/3/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpV3TokenResponseTests: YAPIXCTestCase {
  func test_ValidResponse_ParsedFromEncodedJSON() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpValidTokenRequestResponse)
      let response = try YelpV3TokenResponse(withJSON: dict)
      
      XCTAssertNil(response.error)
      XCTAssert(response.wasSuccessful)
      XCTAssert(response.accessToken == "your access token")
      XCTAssert(response.tokenType == .bearer)
      XCTAssert(response.expiresIn == 15552000)
    }
    catch {
      XCTFail()
    }
  }
  
  func test_ErrorResponse_ParsedFromEncodedJSON() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpErrorResponse)
      let response = try YelpV3TokenResponse(withJSON: dict)
      
      XCTAssertNotNil(response.error)
      XCTAssert(!response.wasSuccessful)
      XCTAssertNil(response.accessToken)
      XCTAssertNil(response.tokenType)
      XCTAssertNil(response.expiresIn)
    }
    catch {
      XCTFail()
    }
  }
}
