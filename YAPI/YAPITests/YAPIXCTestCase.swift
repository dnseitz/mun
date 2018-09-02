//
//  YAPIXCTestCase.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/3/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YAPIXCTestCase : XCTestCase {
  
  override class func setUp() {
    super.setUp()
    
    APIFactory.Yelp.V2.setAuthenticationKeys(consumerKey: "", consumerSecret: "", token: "", tokenSecret: "")
    Asserts.shouldAssert = false
  }
  
  override class func tearDown() {
    AuthKeys.clearAuthentication()
    
    Asserts.shouldAssert = true
    super.tearDown()
  }
  
  func dictFromBase64(_ base64String: String) throws -> [String: AnyObject] {
    let base64Data = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0))
    let json = try JSONSerialization.jsonObject(with: base64Data!, options: .allowFragments)
    return json as! [String: AnyObject]
  }
}
