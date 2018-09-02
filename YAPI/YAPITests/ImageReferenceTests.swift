//
//  ImageReferenceTests.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/29/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import XCTest
@testable import YAPI

class ImageReferenceTests: YAPIXCNetworkTestCase {
  let mockCache = Cache<ImageReference>(identifier: "MockCache")
  
  override func tearDown() {
    mockCache.flush()
    
    super.tearDown()
  }
  
  func test_Init_WithInvalidURLStringFails() {
    let imageReference = ImageReference(from: "")
    
    XCTAssertNil(imageReference)
  }
  
  func test_Prefetch_LoadsImage() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)

    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    
    imageReference.prefetch()
    
    XCTAssertNotNil(imageReference.cachedImage)
  }
  
  func test_LoadImage_WhileLoadIsInFlight_DefersLoadForImage() {
    mockSession.asyncAfter = .milliseconds(100)
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)

    var image: UIImage? = nil
    var image2: UIImage? = nil

    let expect = expectation(description: "The image load finished")
    let expect2 = expectation(description: "The second image load finished")

    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      
      image = result.unwrap()
      expect.fulfill()
    }
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      
      image2 = result.unwrap()
      expect2.fulfill()
    }
    
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      XCTAssertNotNil(image)
      XCTAssertNotNil(image2)
    }
  }
  
  func test_LoadImage_WhileLoadIsInFlight_MultipleLoads_DefersLoadsForImage() {
    mockSession.asyncAfter = .milliseconds(100)
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)

    var image: UIImage? = nil
    var image2: UIImage? = nil
    var image3: UIImage? = nil
    var image4: UIImage? = nil

    let expect = expectation(description: "The image load finished")
    let expect2 = expectation(description: "The second image load finished")
    let expect3 = expectation(description: "The third image load finished")
    let expect4 = expectation(description: "The fourth image load finished")
    
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      
      image = result.unwrap()
      expect.fulfill()
    }
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      
      image2 = result.unwrap()
      expect2.fulfill()
    }
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      
      image3 = result.unwrap()
      expect3.fulfill()
    }
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      
      image4 = result.unwrap()
      expect4.fulfill()
    }
    
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      XCTAssertNotNil(image)
      XCTAssertNotNil(image2)
      XCTAssertNotNil(image3)
      XCTAssertNotNil(image4)
    }
  }
  
  func test_LoadImage_WhileLoadIsInFlight_ErrorInLoad_ReturnsError() {
    mockSession.asyncAfter = .milliseconds(100)
    mockSession.nextError = Mock.error
    var resultError: ImageLoadError? = nil
    
    let expect = expectation(description: "The image load finished")
    let expect2 = expectation(description: "The second image load finished")
    
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    
    imageReference.load { result in
      XCTAssert(result.isErr())
      expect.fulfill()
    }
    
    imageReference.load { result in
      XCTAssert(result.isErr())
      
      resultError = result.unwrapErr()
      expect2.fulfill()
    }
  
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      XCTAssertNotNil(resultError)
    }
  }
  
  func test_LoadImage_LoadsAnImageFromValidData() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handlerCalled = false
    imageReference.load() { result in
      handlerCalled = true
      XCTAssert(result.isOk())
    }
    
    XCTAssertTrue(handlerCalled)
  }
  
  func test_LoadImage_LoadsAnImageFromValidData_CachesTheImage() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    let imageReference2 = ImageReference(from: Mock.url, using: mockCache, session: session)

    imageReference.load() { _ in }
    imageReference2.load() { _ in }

    XCTAssertNotNil(imageReference.cachedImage)
    XCTAssertNotNil(imageReference2.cachedImage)
  }
  
  func test_LoadImage_LoadsAnImageFromInvalidData_GivesAnError() {
    mockSession.nextData = Data()
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handlerCalled = false

    imageReference.load() { result in
      handlerCalled = true
      XCTAssert(result.isErr())
      
      guard case .invalidData = result.unwrapErr() else {
        return XCTFail("Error was wrong type")
      }
    }
    
    XCTAssertTrue(handlerCalled)
  }
  
  func test_LoadImage_WhereRequestErrors_GivesTheError() {
    mockSession.nextError = Mock.error
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handlerCalled = false

    imageReference.load() { result in
      handlerCalled = true
      XCTAssert(result.isErr())
      
      guard case .requestError = result.unwrapErr() else {
        return XCTFail("Error was wrong type")
      }
    }
    
    XCTAssertTrue(handlerCalled)
  }
  
  func test_LoadImage_RecievesNoData_GivesAnError() {
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handlerCalled = false
    
    imageReference.load() { result in
      handlerCalled = true
      XCTAssert(result.isErr())
      
      guard case .noDataReceived = result.unwrapErr() else {
        return XCTFail("Error was wrong type")
      }
    }
    
    XCTAssertTrue(handlerCalled)
  }
  
  func test_LoadImage_WithDifferentImageReferencesToSameURL_GivesCachedImage() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    let imageReference2 = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handlersCalled = false
    
    imageReference.load() { result in
      imageReference2.load() { result2 in
        handlersCalled = true
        XCTAssert(result.isOk())
        XCTAssert(result2.isOk())
        
        let image = result.unwrap()
        let image2 = result2.unwrap()
        
        let imageData = UIImagePNGRepresentation(image)!
        let imageData2 = UIImagePNGRepresentation(image2)!
        let cachedImageData = UIImagePNGRepresentation(imageReference.cachedImage!)!
        let cachedImageData2 = UIImagePNGRepresentation(imageReference2.cachedImage!)!

        XCTAssert(cachedImageData == imageData)
        XCTAssert(cachedImageData == imageData2)
        XCTAssert(cachedImageData2 == imageData)
        XCTAssert(cachedImageData2 == imageData2)
        XCTAssert(imageData == imageData2)
      }
    }
    
    XCTAssertTrue(handlersCalled)
  }
  
  func test_LoadImage_StoresImagesInCache() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    let url = URL(string: "http://s3-media3.fl.yelpcdn.com/asdf.jpg")!
    let url2 = URL(string: "http://s3-media3.fl.yelpcdn.com/qwer.jpg")!
    let imageReference = ImageReference(from: url, using: mockCache, session: session)
    let imageReference2 = ImageReference(from: url2, using: mockCache, session: session)
    var handlersCalled = false
    
    XCTAssertFalse(mockCache.contains(imageReference))
    XCTAssertFalse(mockCache.contains(imageReference2))

    imageReference.load() { result in
      imageReference2.load() { result2 in
        handlersCalled = true
        XCTAssert(result.isOk())
        XCTAssert(result2.isOk())
        
        XCTAssertTrue(self.mockCache.contains(imageReference))
        XCTAssertTrue(self.mockCache.contains(imageReference2))
      }
    }
    
    XCTAssertTrue(handlersCalled)
  }
  
  func test_CachedImageProperty_ReturnsCopy() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handlerCalled = false
    
    imageReference.load() { result in
      handlerCalled = true
      let cachedImage = imageReference.cachedImage
      
      XCTAssertNotNil(cachedImage)
      XCTAssert(result.isOk())
      
      let image = result.unwrap()
      
      // These seem wierd, but we're asserting that the cachedImage property is returning copies of the 
      // image, not the same reference
      XCTAssert(cachedImage !== image)
      XCTAssert(cachedImage !== imageReference.cachedImage)
      XCTAssert(imageReference.cachedImage !== imageReference.cachedImage)
    }
    
    XCTAssertTrue(handlerCalled)
  }
  
  func test_LoadImageWithScale_ScalesTheImage() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var handler1Called = false
    var handler2Called = false
    
    imageReference.load(withScale: 0.5) { result in
      handler1Called = true
      XCTAssert(result.isOk())
      
      let image = result.unwrap()
      
      XCTAssert(image.scale == 0.5)
    }
    
    imageReference.load(withScale: 1.5) { result in
      handler2Called = true
      XCTAssert(result.isOk())
      
      let image = result.unwrap()
      
      XCTAssert(image.scale == 1.5)
    }
    
    XCTAssert(imageReference.cachedImage?.scale == 1.0)
    XCTAssertTrue(handler1Called)
    XCTAssertTrue(handler2Called)
  }
 
  func test_Subclass_OverridesCachedImage_LoadsFromOverriddenProperty() {
    class MockImageReference: ImageReference {
      let expectedImage: UIImage

      override var cachedImage: UIImage? {
        return expectedImage
      }
      
      init(expectedImage: UIImage,
           using cache: Cache<ImageReference>,
           session: HTTPClient) {
        self.expectedImage = expectedImage
        super.init(from: Mock.url, using: cache, session: session)
      }
    }
    
    let expectedImage = UIImage(data: Data(base64Encoded: ResponseInjections.yelpValidImage)!)!
    let mockImageReference = MockImageReference(expectedImage: expectedImage, using: mockCache, session: session)
    
    let expectedImageData = UIImagePNGRepresentation(expectedImage)!
    let cachedImageData = UIImagePNGRepresentation(mockImageReference.cachedImage!)!
    var handlerCalled = false
    
    XCTAssertEqual(expectedImageData, cachedImageData)
    
    mockImageReference.load { result in
      handlerCalled = true
      XCTAssert(result.isOk())
      
      let loadedImageData = UIImagePNGRepresentation(result.unwrap())!
      
      XCTAssertEqual(expectedImageData, loadedImageData)
    }

    XCTAssertTrue(handlerCalled)
  }
  
  func test_ImageReference_CanLoadImageMultipleTimes() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidImage)
    let imageReference = ImageReference(from: Mock.url, using: mockCache, session: session)
    var loadedCount = 0
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      loadedCount += 1
    }
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      loadedCount += 1
    }
    
    imageReference.load { result in
      XCTAssert(result.isOk())
      loadedCount += 1
    }
    
    XCTAssertEqual(loadedCount, 3)
  }
}
