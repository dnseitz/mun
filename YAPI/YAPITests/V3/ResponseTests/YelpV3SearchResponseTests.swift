//
//  YelpV3SearchResponseTests.swift
//  YAPITests
//
//  Created by Daniel Seitz on 11/11/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//


import XCTest
@testable import YAPI

class YelpV3SearchResponseTests: YAPIXCTestCase {
  func test_ValidResponse_ParsesFromEncodedJson() {
    do {
      let dict = try self.dictFromBase64(ResponseInjections.yelpV3ValidSearchResponse)
      let response = try YelpV3SearchResponse(withJSON: dict)
      
      // Total
      XCTAssert(response.total == 8228)
      
      // Businesses
      XCTAssert(response.businesses.count == 1)
      let business = response.businesses.first!
      XCTAssert(compare(business.rating, 4.0))
      XCTAssert(business.price == .one)
      XCTAssert(business.phoneNumber == "+14152520800")
      XCTAssert(business.id == "four-barrel-coffee-san-francisco")
      XCTAssert(business.closed == false)
      XCTAssert(business.reviewCount == 1738)
      XCTAssert(business.name == "Four Barrel Coffee")
      XCTAssert(business.url.absoluteString == "https://www.yelp.com/biz/four-barrel-coffee-san-francisco")
      XCTAssert(business.image?.url.absoluteString == "http://s3-media2.fl.yelpcdn.com/bphoto/MmgtASP3l_t4tPCL1iAsCg/o.jpg")
      XCTAssert(compare(business.distance, 1604.23))
      XCTAssertNil(business.displayPhoneNumber)
      
      
      // Category
      XCTAssert(business.categories.count == 1)
      let category = business.categories.first!
      XCTAssert(category.alias == "coffee")
      XCTAssert(category.categoryName == "Coffee & Tea")
      
      // Coordinates
      XCTAssert(compare(business.coordinates.latitude, 37.7670169511878))
      XCTAssert(compare(business.coordinates.longitude, -122.42184275))
      
      // Location
      let location = business.location
      XCTAssert(location.city == "San Francisco")
      XCTAssert(location.country == "US")
      XCTAssert(location.address2 == "")
      XCTAssert(location.address3 == "")
      XCTAssert(location.state == "CA")
      XCTAssert(location.address1 == "375 Valencia St")
      XCTAssert(location.zipCode == "94103")
      XCTAssert(location.displayAddress.count == 0)
      
      // Transactions
      XCTAssert(business.transactions.count == 2)
      XCTAssert(business.transactions[0] == .pickup)
      XCTAssert(business.transactions[1] == .delivery)
      
      // Region
      XCTAssertNil(response.region.span)
      XCTAssert(compare(response.region.center.latitude, 37.767413217936834))
      XCTAssert(compare(response.region.center.longitude, -122.42820739746094))
    }
    catch {
      XCTFail("\(error)")
    }
  }
}
