//
//  HTTPClientTests.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/29/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class HTTPClientTests: YAPIXCTestCase {
  var subject: HTTPClient!
  let session = MockURLSession()
  
  override func setUp() {
    super.setUp()
    
    subject = HTTPClient(session: session)
  }
  
  override func tearDown() {
    session.nextData = nil
    session.nextError = nil
    
    super.tearDown()
  }
  
  func test_Send_RequestsTheURL() {
    let url = URL(string: "http://yelp.com")!
    
    subject.send(url) { _, _, _ -> Void in }
    
    XCTAssertNotNil(session.lastURL)
    XCTAssert(session.lastURL == url)
  }
  
  func test_Send_StartsTheRequest() {    
    subject.send(URL(fileURLWithPath: "")) { _, _, _ -> Void in }
    
    XCTAssertEqual(session.nextDataTask?.resumeWasCalled, true)
  }
  
  func test_Send_WithResponseData_ReturnsTheData() {
    let expectedData = "{}".data(using: String.Encoding.utf8)
    session.nextData = expectedData
    
    var actualData: Data?
    subject.send(URL(fileURLWithPath: "")) { (data, _, _) -> Void in
      actualData = data
    }
    
    XCTAssertEqual(actualData, expectedData)
  }
  
  func test_Send_WithANetworkError_ReturnsANetworkError() {
    session.nextError = NSError(domain: "error", code: 0, userInfo: nil)
    
    var error: Error?
    subject.send(URL(fileURLWithPath: "")) { _, _, theError -> Void in
      error = theError
    }
    
    XCTAssertNotNil(error)
  }
}
