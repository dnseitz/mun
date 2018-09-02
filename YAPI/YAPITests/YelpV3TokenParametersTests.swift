//
//  YelpV3TokenParametersTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 10/3/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpV3TokenParametersTests: YAPIXCTestCase {
  func test_ParametersValue_GivesCorrectValue() {
    let token = YelpV3TokenParameters(grantType: .clientCredentials, clientId: "CLIENTID", clientSecret: "CLIENTSECRET")
    
    XCTAssert(token.grantType.value == "client_credentials")
    XCTAssert(token.clientId.value == "CLIENTID")
    XCTAssert(token.clientSecret.value == "CLIENTSECRET")
  }
  
  func test_GrantType_GivesCorrectKeyValue() {
    let grantType = YelpV3TokenParameters.GrantType.clientCredentials
    
    XCTAssert(grantType.key == "grant_type")
    XCTAssert(grantType.value == "client_credentials")
  }
  
  func test_ClientId_GivesCorrectKeyValue() {
    let clientId: YelpV3TokenParameters.ClientID = "CID"
    
    XCTAssert(clientId.key == "client_id")
    XCTAssert(clientId.value == "CID")
  }
  
  func test_ClientSecret_GivesCorrectKeyValue() {
    let clientSecret: YelpV3TokenParameters.ClientSecret = "CSECRET"
    
    XCTAssert(clientSecret.key == "client_secret")
    XCTAssert(clientSecret.value == "CSECRET")
  }
}
