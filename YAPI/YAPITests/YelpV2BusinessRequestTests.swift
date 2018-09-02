//
//  YelpBusinessRequestTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class YelpV2BusinessRequestTests : YAPIXCTestCase {
  var session: HTTPClient!
  var request: YelpV2BusinessRequest!
  var mockSession = MockURLSession()
  
  override func setUp() {
    super.setUp()
    
    session = HTTPClient(session: mockSession)
    request = YelpV2BusinessRequest(businessId: "BUSINESS_ID", session: session)
  }
  
  func test_SendRequest_RecievesData_ParsesTheData() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidBusinessResponse, options: .ignoreUnknownCharacters)
    request.send() { result in
      XCTAssert(result.isOk())
      
      let response = result.unwrap()
      
      XCTAssertNil(response.region)
      XCTAssertNil(response.total)
      
      let business = response.businesses![0]
      
      XCTAssert(business.categories.count == 2)
      
      XCTAssertNotNil(business.deals)
      XCTAssert(business.deals!.count == 1)
      
      XCTAssertNotNil(business.displayPhoneNumber)
      XCTAssert(business.displayPhoneNumber! == "+1-415-677-9743")
      
      XCTAssert(business.id == "urban-curry-san-francisco")
      
      XCTAssertNotNil(business.image)
      XCTAssert(business.image!.url.absoluteString == "http://s3-media1.fl.yelpcdn.com/bphoto/u5b1u7c04C1GkptUg0grdA/ms.jpg")
      
      XCTAssert(business.claimed == true)
      
      XCTAssert(business.closed == false)
     
      XCTAssert(business.location.address.count == 1)
      XCTAssert(business.location.address[0] == "523 Broadway")
      XCTAssert(business.location.city == "San Francisco")
      XCTAssertNotNil(business.location.coordinate)
      XCTAssert(business.location.coordinate!.latitude == 37.7978994)
      XCTAssert(business.location.coordinate!.longitude == -122.4059649)
      XCTAssert(business.location.countryCode == "US")
      XCTAssertNotNil(business.location.crossStreets)
      XCTAssert(business.location.crossStreets! == "Romolo Pl & Kearny St")
      XCTAssert(business.location.displayAddress.count == 3)
      XCTAssert(business.location.geoAccuraccy == 9.5)
      XCTAssertNotNil(business.location.neighborhoods)
      XCTAssert(business.location.neighborhoods!.count == 2)
      XCTAssert(business.location.postalCode == "94133")
      XCTAssert(business.location.stateCode == "CA")
      
      XCTAssert(business.mobileURL.absoluteString == "http://m.yelp.com/biz/urban-curry-san-francisco")
      
      XCTAssert(business.name == "Urban Curry")
      
      XCTAssertNotNil(business.phoneNumber)
      XCTAssert(business.phoneNumber! == "4156779743")
      
      XCTAssert(business.rating.rating == 4.0)
      XCTAssert(business.rating.image.url.absoluteString == "http://s3-media4.fl.yelpcdn.com/assets/2/www/img/c2f3dd9799a5/ico/stars/v1/stars_4.png")
      XCTAssert(business.rating.largeImage.url.absoluteString == "http://s3-media2.fl.yelpcdn.com/assets/2/www/img/ccf2b76faa2c/ico/stars/v1/stars_large_4.png")
      XCTAssert(business.rating.smallImage.url.absoluteString == "http://s3-media4.fl.yelpcdn.com/assets/2/www/img/f62a5be2f902/ico/stars/v1/stars_small_4.png")
      
      XCTAssert(business.reviewCount == 455)
      
      XCTAssertNotNil(business.snippet.image)
      XCTAssert(business.snippet.image!.url.absoluteString == "http://s3-media3.fl.yelpcdn.com/photo/hk31BkJvJ8qcqoUvZ38rmQ/ms.jpg")
      XCTAssertNotNil(business.snippet.text)
      XCTAssert(business.snippet.text! == "One of the owners is a former Sherpa from Nepal who has summitted Mt. Everest twice. While the restaurant is in a seeder part of the City, it's also on one...")
      
      XCTAssert(business.url.absoluteString == "http://www.yelp.com/biz/urban-curry-san-francisco")
    }
  }
  
  func test_BusinessRequest_HasModifiedEndpoint() {
    XCTAssert(request.path == APIEndpoints.Yelp.V2.business + "BUSINESS_ID")
  }
}
