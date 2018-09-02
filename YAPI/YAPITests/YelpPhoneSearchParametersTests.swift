//
//  YelpPhoneSearchParametersTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/12/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpPhoneSearchParametersTests: YAPIXCTestCase {
  func test_ParametersValue_GivesCorrectValue() {
    let phoneSearch = YelpV2PhoneSearchParameters(phone: "PHONENUMBER", countryCode: .unitedStates, category: "CATEGORY")
    
    XCTAssertNotNil(phoneSearch.countryCode)
    XCTAssertNotNil(phoneSearch.category)
    
    XCTAssert(phoneSearch.phone.value == "PHONENUMBER")
    XCTAssert(phoneSearch.countryCode!.value == "US")
    XCTAssert(phoneSearch.category!.value == "CATEGORY")
  }
  
  func test_Phone_GivesCorrectKeyValue() {
    let phone: YelpV2PhoneSearchParameters.Phone = "PHONE"
    
    XCTAssert(phone.key == "phone")
    XCTAssert(phone.value == "PHONE")
  }
  
  func test_CountryCode_GivesCorrectKeyValue() {
    let countryCode = YelpCountryCodeParameter.unitedKingdom
    
    XCTAssert(countryCode.key == "cc")
    XCTAssert(countryCode.value == "GB")
  }
  
  func test_Category_GivesCorrectKeyValue() {
    let category: YelpV2PhoneSearchParameters.Category = "CATEGORY"
    
    XCTAssert(category.key == "category")
    XCTAssert(category.value == "CATEGORY")
  }
}
