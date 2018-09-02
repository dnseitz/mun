//
//  YelpAuthenticationTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/3/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpAuthenticationTests: YAPIXCTestCase {
  
  override func setUp() {
    super.setUp()
    
    AuthKeys.clearAuthentication()
  }
  
  func test_ConsumerKey_GetsSet() {
    AuthKeys.consumerKey = "CONSUMERKEY"
    
    XCTAssertNotNil(AuthKeys.consumerKey)
    XCTAssert(AuthKeys.consumerKey! == "CONSUMERKEY")
  }
  
  func test_ConsumerSecret_GetsSet() {
    AuthKeys.consumerSecret = "CONSUMERSECRET"
    
    XCTAssertNotNil(AuthKeys.consumerSecret)
    XCTAssert(AuthKeys.consumerSecret == "CONSUMERSECRET")
  }

  func test_Token_GetsSet() {
    AuthKeys.token = "TOKEN"
    
    XCTAssertNotNil(AuthKeys.token)
    XCTAssert(AuthKeys.token! == "TOKEN")
  }
  
  func test_TokenSecret_GetsSet() {
    AuthKeys.tokenSecret = "TOKENSECRET"
    
    XCTAssertNotNil(AuthKeys.tokenSecret)
    XCTAssert(AuthKeys.tokenSecret! == "TOKENSECRET")
  }
  
  func test_ConsumerKey_CantBeSetTwice() {
    AuthKeys.consumerKey = "CONSUMERKEY"
    AuthKeys.consumerKey = "CONSUMERKEY2"
    
    XCTAssertNotNil(AuthKeys.consumerKey)
    XCTAssert(AuthKeys.consumerKey! == "CONSUMERKEY")
  }
  
  func test_ConsumerSecret_CantBeSetTwice() {
    AuthKeys.consumerSecret = "CONSUMERSECRET"
    AuthKeys.consumerSecret = "CONSUMERSECRET2"
    
    XCTAssertNotNil(AuthKeys.consumerSecret)
    XCTAssert(AuthKeys.consumerSecret == "CONSUMERSECRET")
  }
  
  func test_Token_CantBeSetTwice() {
    AuthKeys.token = "TOKEN"
    AuthKeys.token = "TOKEN2"
    
    XCTAssertNotNil(AuthKeys.token)
    XCTAssert(AuthKeys.token! == "TOKEN")
  }
  
  func test_TokenSecret_CantBeSetTwice() {
    AuthKeys.tokenSecret = "TOKENSECRET"
    AuthKeys.tokenSecret = "TOKENSECRET2"
    
    XCTAssertNotNil(AuthKeys.tokenSecret)
    XCTAssert(AuthKeys.tokenSecret! == "TOKENSECRET")
  }
  
  func test_AuthKeys_AreSet_ReturnsFalseWhenNotSet() {
    XCTAssert(AuthKeys.areSet == false)
  }
  
  func test_AuthKeys_AreSet_ReturnsTrueWhenSet() {
    AuthKeys.consumerKey = "CONSUMERKEY"
    AuthKeys.consumerSecret = "CONSUMERSECRET"
    AuthKeys.token = "TOKEN"
    AuthKeys.tokenSecret = "TOKENSECRET"
    
    XCTAssert(AuthKeys.areSet == true)
  }
}
