//
//  YelpPhoneSearchRequestTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/12/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpPhoneSearchRequestTests: YAPIXCTestCase {
  var session: HTTPClient!
  var request: YelpV2PhoneSearchRequest!
  var mockSession = MockURLSession()
  
  override func setUp() {
    super.setUp()
    
    session = HTTPClient(session: mockSession)
    request = YelpV2PhoneSearchRequest(phoneSearch: YelpV2PhoneSearchParameters(phone: "PHONENUMBER"), session: session)
  }
  
  func test_SendRequest_RecievesData_ParsesTheData() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidPhoneSearchResponse, options: .ignoreUnknownCharacters)
    request.send() { result in
      XCTAssert(result.isOk())
      let response = result.unwrap()
      
      XCTAssertNil(response.region)
      XCTAssertNotNil(response.total)
      XCTAssert(response.total! == 2316)
      
      XCTAssertNotNil(response.businesses)
      
      let business = response.businesses![0]
      
      XCTAssert(business.categories.count == 2)
      
      XCTAssertNotNil(business.displayPhoneNumber)
      XCTAssert(business.displayPhoneNumber! == "+1-415-908-3801")
      
      XCTAssert(business.id == "yelp-san-francisco")
      
      XCTAssertNotNil(business.image)
      XCTAssert(business.image!.url.absoluteString == "http://s3-media3.fl.yelpcdn.com/bphoto/nQK-6_vZMt5n88zsAS94ew/ms.jpg")
      
      XCTAssert(business.claimed == true)
      
      XCTAssert(business.closed == false)
      
      XCTAssert(business.location.address.count == 1)
      XCTAssert(business.location.address[0] == "140 New Montgomery St")
      XCTAssert(business.location.city == "San Francisco")
      XCTAssertNotNil(business.location.coordinate)
      XCTAssert(business.location.coordinate!.latitude == 37.7867703362929)
      XCTAssert(business.location.coordinate!.longitude == -122.399958372115)
      XCTAssert(business.location.countryCode == "US")
      XCTAssertNotNil(business.location.crossStreets)
      XCTAssert(business.location.crossStreets! == "Natoma St & Minna St")
      XCTAssert(business.location.displayAddress.count == 3)
      XCTAssert(business.location.geoAccuraccy == 9.5)
      XCTAssertNotNil(business.location.neighborhoods)
      XCTAssert(business.location.neighborhoods!.count == 2)
      XCTAssert(business.location.postalCode == "94105")
      XCTAssert(business.location.stateCode == "CA")
      
      XCTAssert(business.mobileURL.absoluteString == "http://m.yelp.com/biz/yelp-san-francisco")
      
      XCTAssert(business.name == "Yelp")
      
      XCTAssertNotNil(business.phoneNumber)
      XCTAssert(business.phoneNumber! == "4159083801")
      
      XCTAssert(business.rating.rating == 2.5)
      XCTAssert(business.rating.image.url.absoluteString == "http://s3-media4.fl.yelpcdn.com/assets/2/www/img/c7fb9aff59f9/ico/stars/v1/stars_2_half.png")
      XCTAssert(business.rating.largeImage.url.absoluteString == "http://s3-media2.fl.yelpcdn.com/assets/2/www/img/d63e3add9901/ico/stars/v1/stars_large_2_half.png")
      XCTAssert(business.rating.smallImage.url.absoluteString == "http://s3-media4.fl.yelpcdn.com/assets/2/www/img/8e8633e5f8f0/ico/stars/v1/stars_small_2_half.png")
      
      XCTAssert(business.reviewCount == 7140)
      
      XCTAssertNotNil(business.snippet.image)
      XCTAssert(business.snippet.image!.url.absoluteString == "http://s3-media4.fl.yelpcdn.com/photo/YcjPScwVxF05kj6zt10Fxw/ms.jpg")
      XCTAssertNotNil(business.snippet.text)
      XCTAssert(business.snippet.text! == "What would I do without Yelp?\n\nI wouldn't be HALF the foodie I've become it weren't for this business.    \n\nYelp makes it virtually effortless to discover new...")
      
      XCTAssert(business.url.absoluteString == "http://www.yelp.com/biz/yelp-san-francisco")
    }
  }
}
