//
//  YelpSearchParametersTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpSearchParametersTests: YAPIXCTestCase {
  func test_ParametersValue_GivesCorrectValue() {
    let search = YelpV2SearchParameters(location: "LOCATION" as YelpSearchLocation, term: .food, limit: 10, offset: 50, sortMode: .best, categories: ["CATEGORY1", "CATEGORY2"], radius: 1000, filterDeals: false)
    
    XCTAssertNotNil(search.term)
    XCTAssertNotNil(search.limit)
    XCTAssertNotNil(search.offset)
    XCTAssertNotNil(search.sortMode)
    XCTAssertNotNil(search.categories)
    XCTAssertNotNil(search.radius)
    XCTAssertNotNil(search.filterDeals)
    
    XCTAssert(search.location.value == "LOCATION")
    XCTAssert(search.term!.value == "food")
    XCTAssert(search.limit!.value == "10")
    XCTAssert(search.offset!.value == "50")
    XCTAssert(search.sortMode!.value == "0")
    XCTAssert(search.categories!.value == "CATEGORY1,CATEGORY2")
    XCTAssert(search.radius!.value == "1000")
    XCTAssert(search.filterDeals!.value == "false")
  }
  
  func test_Term_GivesCorrectKeyValue() {
    let term = YelpV2SearchParameters.SearchTerm.drink
    
    XCTAssert(term.key == "term")
    XCTAssert(term.value == "drink")
  }
  
  func test_Limit_GivesCorrectKeyValue() {
    let limit: YelpV2SearchParameters.Limit = 100
    
    XCTAssert(limit.key == "limit")
    XCTAssert(limit.value == "100")
  }
  
  func test_Offset_GivesCorrectKeyValue() {
    let offset: YelpV2SearchParameters.Offset = 50
    
    XCTAssert(offset.key == "offset")
    XCTAssert(offset.value == "50")
  }
  
  func test_SortMode_GivesCorrectKeyValue() {
    let sortMode = YelpV2SearchParameters.SortMode.highestRated
    
    XCTAssert(sortMode.key == "sort")
    XCTAssert(sortMode.value == "2")
  }
  
  func test_Categories_GivesCorrectKeyValue() {
    let categories: YelpV2SearchParameters.Categories = ["C1", "C2"]
    
    XCTAssert(categories.key == "category_filter")
    XCTAssert(categories.value == "C1,C2")
  }
  
  func test_Radius_GivesCorrectKeyValue() {
    let radius: YelpV2SearchParameters.Radius = 1000
    
    XCTAssert(radius.key == "radius_filter")
    XCTAssert(radius.value == "1000")
  }
  
  func test_FilterDeals_GivesCorrectKeyValue() {
    let deals: YelpV2SearchParameters.Deals = false
    
    XCTAssert(deals.key == "deals_filter")
    XCTAssert(deals.value == "false")
  }
}
