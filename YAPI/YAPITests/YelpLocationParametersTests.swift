//
//  YelpLocationParametersTests.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/11/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
import CoreLocation
@testable import YAPI

class YelpLocationParametersTests: YAPIXCTestCase {
  func test_SearchLocation_GivesCorrectKeyValue() {
    let searchLocation: YelpSearchLocation = "LOCATION"
    
    XCTAssertNil(searchLocation.hint)
    
    XCTAssert(searchLocation.key == "location")
    XCTAssert(searchLocation.value == "LOCATION")
  }
  
  func test_SearchLocationHint_GivesCorrectKeyValue() {
    let searchLocation = YelpSearchLocation(location: "LOCATION", locationHint: CLLocation(latitude: 42, longitude: 24))
    
    XCTAssert(searchLocation.key == "location")
    XCTAssert(searchLocation.value == "LOCATION")
    
    XCTAssertNotNil(searchLocation.hint)
    
    XCTAssert(searchLocation.hint!.key == "cll")
    XCTAssert(searchLocation.hint!.value == "42.0,24.0")
  }
  
  func test_BoundingBox_GivesCorrectKeyValue() {
    let bounds = YelpBoundingBox(southWest: CLLocationCoordinate2D(latitude: 10, longitude: 20), northEast: CLLocationCoordinate2D(latitude: 40, longitude: 60))
    
    XCTAssertNil(bounds.hint)
    
    XCTAssert(bounds.key == "bounds")
    XCTAssert(bounds.value == "10.0,20.0|40.0,60.0")
  }
  
  func test_GeographicCoordinate_GivesCorrectKeyValue() {
    let coordinate = YelpGeographicCoordinate(coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 100), accuracy: 10, altitude: 20, altitudeAccuracy: 30)
    
    XCTAssertNil(coordinate.hint)
    XCTAssertNotNil(coordinate.accuracy)
    XCTAssertNotNil(coordinate.altitude)
    XCTAssertNotNil(coordinate.altitudeAccuracy)
    
    XCTAssert(coordinate.key == "ll")
    XCTAssert(coordinate.value == "50.0,100.0,10.0,20.0,30.0")
  }
  
  func test_GeographicCoordinate_MissingAccuracy_IgnoresRest() {
    let coordinate = YelpGeographicCoordinate(coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 100), accuracy: nil, altitude: 20, altitudeAccuracy: 30)
    
    XCTAssertNil(coordinate.hint)
    XCTAssertNil(coordinate.accuracy)
    XCTAssertNotNil(coordinate.altitude)
    XCTAssertNotNil(coordinate.altitudeAccuracy)
    
    XCTAssert(coordinate.key == "ll")
    XCTAssert(coordinate.value == "50.0,100.0")
  }
  
  func test_GeographicCoordinate_LeavesOutMissingParameters() {
    let coordinate = YelpGeographicCoordinate(coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 100), accuracy: 10, altitude: 20, altitudeAccuracy: nil)
    
    XCTAssertNil(coordinate.hint)
    XCTAssertNotNil(coordinate.accuracy)
    XCTAssertNotNil(coordinate.altitude)
    XCTAssertNil(coordinate.altitudeAccuracy)
    
    XCTAssert(coordinate.key == "ll")
    XCTAssert(coordinate.value == "50.0,100.0,10.0,20.0")
  }
}
