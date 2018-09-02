//
//  YelpRequestTestCase.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpV2GenericRequestTestCase : YAPIXCTestCase {
  var session: HTTPClient!
  var request: YelpV2BusinessRequest!
  let mockSession = MockURLSession()
  
  override func setUp() {
    super.setUp()
    
    session = HTTPClient(session: mockSession)
    request = YelpV2BusinessRequest(businessId: "", session: session)
  }
  
  override func tearDown() {
    mockSession.nextData = nil
    mockSession.nextError = nil
    
    super.tearDown()
  }
  
  func test_SendRequest_WhereRequestErrors_GivesTheError() {
    let mockError = MockError()
    mockSession.nextError = mockError
    request.send() { result in
      XCTAssert(result.isErr())
      
      guard
        case RequestError.failedToSendRequest(cause: let error) = result.unwrapErr(),
        error is MockError
        else {
          return XCTFail("Wrong error type thrown: \(result.unwrapErr())")
      }
    }
  }
  
  func test_SendRequest_RecievesNoData_GivesAnError() {
    request.send() { result in
      XCTAssert(result.isErr())
      
      guard case YelpResponseError.noDataRecieved = result.unwrapErr() else {
        return XCTFail("Wrong error type thrown: \(result.unwrapErr())")
      }
    }
  }
  
  func test_SendRequest_RecievesBadData_GivesAnError() {
    mockSession.nextData = Data()
    request.send() { result in
      XCTAssert(result.isErr())

      guard case YelpResponseError.failedToParse(cause: ParseError.invalidJson) = result.unwrapErr() else {
        return XCTFail("Wrong error type given: \(result.unwrapErr())")
      }
    }
  }
  
  func test_SendRequest_RecievesYelpError_GivesTheError() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpErrorResponse, options: .ignoreUnknownCharacters)
    request.send() { result in
      XCTAssert(result.isOk())
      let response = result.unwrap()
      
      XCTAssertNil(response.businesses)
      XCTAssertNotNil(response.error)
      
      guard case YelpResponseError.invalidParameter(field: "location") = response.error! else {
        return XCTFail("Wrong error type given: \(response.error!)")
      }
      XCTAssert(response.wasSuccessful == false)
    }
  }
}
