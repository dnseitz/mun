//
//  YelpResponseModelTests.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/26/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpResponseModelTests: YAPIXCTestCase {
  func test_ValidResponse_ParsedFromEncodedJSON() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpValidThreeBusinessResponse)
      let response = YelpV2SearchResponse(withJSON: dict)
      
      XCTAssertNotNil(response.region)
      XCTAssertNotNil(response.total)
      XCTAssert(response.total == 50559)
      XCTAssertNotNil(response.businesses)
      XCTAssert(response.businesses!.count == 3)
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
  
  func test_Region_ParsesCorrectly() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpValidThreeBusinessResponse)
      let response = YelpV2SearchResponse(withJSON: dict)
      
      XCTAssertNotNil(response.region)
      XCTAssert(compare(response.region!.span!.latitudeDelta, 0.013946349999997665))
      XCTAssert(compare(response.region!.span!.longitudeDelta, 0.00908831000000987))
      XCTAssert(compare(response.region!.center.latitude, 37.75342474999999))
      XCTAssert(compare(response.region!.center.longitude, -122.42292094999999))
    }
    catch {
      XCTFail()
    }
  }
}
