//
//  YelpPhoneSearchResponseTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/12/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpPhoneSearchResponseTests: YAPIXCTestCase {
  func test_ValidResponse_ParsedFromEncodedJSON() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpValidPhoneSearchResponse)
      let response = YelpV2SearchResponse(withJSON: dict)
      
      XCTAssertNil(response.region)
      XCTAssertNotNil(response.total)
      XCTAssert(response.total == 2316)
      XCTAssertNotNil(response.businesses)
      XCTAssert(response.businesses!.count == 1)
      XCTAssert(response.wasSuccessful == true)
      XCTAssert(response.error == nil)
    }
    catch {
      XCTFail()
    }
  }
  
  func test_ErrorResponse_ParsedFromEncodedJSON() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpErrorResponse)
      let response = YelpV2SearchResponse(withJSON: dict)
      
      XCTAssertNil(response.region)
      XCTAssertNil(response.total)
      XCTAssertNil(response.businesses)
      XCTAssertNotNil(response.error)
      
      guard case YelpResponseError.invalidParameter(field: "location") = response.error! else {
        return XCTFail("Wrong error type given: \(response.error!)")
      }
      XCTAssert(response.wasSuccessful == false)
    }
    catch {
      XCTFail()
    }
  }
}
