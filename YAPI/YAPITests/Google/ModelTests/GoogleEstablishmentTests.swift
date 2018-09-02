//
//  GoogleEstablishmentTests.swift
//  YAPITests
//
//  Created by Daniel Seitz on 11/18/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class GoogleEstablishmentTests: YAPIXCTestCase {
  
  override func tearDown() {

    GoogleAuth.token = nil

    super.tearDown()
  }
  
  func test_GoogleEstablishmentIcon_Decodes() {
    let urlString = "https://google.com/path"

    do {
      let icon = try decode(GoogleEstablishment.Icon.self, using: urlString)
      XCTAssertEqual(icon.url.absoluteString, urlString)
    }
    catch {
      XCTFail("Decoder threw an error: \(error)")
    }
  }
  
  func test_GoogleEstablishmentPhotoReference_WithAPIKeySet_Decodes() {
    let reference = "ABCDEFG12345"
    
    GoogleAuth.token = GoogleAuthToken("token")
    
    do {
      let photo = try decode(GoogleEstablishment.Photo.PhotoReference.self, using: reference)
      XCTAssert(photo.url.absoluteString.contains(reference))
    }
    catch {
      XCTFail("Decoder threw an error: \(error)")
    }
  }
  
  func test_GoogleEstablishmentPhotoReference_WithoutAPIKeySet_ThrowsError() {
    let reference = "ABCDEFG12345"
    
    do {
      let _ = try decode(GoogleEstablishment.Photo.PhotoReference.self, using: reference)
      XCTFail("Object was successfully decoded")
    }
    catch {
      guard case GoogleResponseError.requestDenied(message: _) = error else {
        return XCTFail("Wrong error type thrown")
      }
    }
  }
}
