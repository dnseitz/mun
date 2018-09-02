//
//  APIFactoryTests.swift
//  YAPITests
//
//  Created by Daniel Seitz on 11/18/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import XCTest
import OAuthSwift
@testable import YAPI

private struct MockRawError: Error {}

private class MockRequestBase {
  let oauthVersion: OAuthSwiftCredential.Version? = nil
  let host: String = "mock"
  let path: String = "/path"
  var parameters: [String : String] = [:]
  var requestMethod: OAuthSwiftHTTPRequest.Method = .GET
  
  let session: HTTPClient
  let mockSession: MockURLSession = MockURLSession()
  
  init() {
    self.session = HTTPClient(session: self.mockSession)
  }
}

private class MockValid: MockRequestBase, Request, Response {
  typealias ResponseType = MockValid

  let error: APIError? = nil
  
  let int: Int
  let string: String
  let double: Double
  let boolean: Bool
  let array: [Int]
  
  required init(withJSON data: [String : AnyObject]) throws {
    self.int = try data.parseParam(key: "int")
    self.string = try data.parseParam(key: "string")
    self.double = try data.parseParam(key: "double")
    self.boolean = try data.parseParam(key: "boolean")
    self.array = try data.parseParam(key: "array")
  }
}

private class MockMissingParam: MockRequestBase, Request, Response {
  typealias ResponseType = MockMissingParam
  
  let error: APIError? = nil
  
  let missing: Int
  required init(withJSON data: [String : AnyObject]) throws {
    self.missing = try data.parseParam(key: "missing")
  }
}

private class MockDomainError: MockRequestBase, Request, Response {
  typealias ResponseType = MockDomainError
  
  let error: APIError? = MockError()
  
  required init(withJSON data: [String : AnyObject]) throws {
    throw self.error!
  }
}

private class MockUnknownError: MockRequestBase, Request, Response {
  typealias ResponseType = MockUnknownError
  
  let error: APIError? = nil
  
  required init(withJSON data: [String : AnyObject]) throws {
    throw MockRawError()
  }
}

private class MockInvalidJSONError: MockRequestBase, Request, Response {
  typealias ResponseType = MockInvalidJSONError
  
  let error: APIError? = nil
  
  required init(withJSON data: [String : AnyObject]) throws {
    XCTFail("Error should be thrown before attempting to parse")
  }
}

// MARK: Response Parsing
class APIFactoryTests: YAPIXCTestCase {
  
  var session: HTTPClient!
  let mockSession = MockURLSession()
  
  override func setUp() {
    super.setUp()
    
    session = HTTPClient(session: mockSession)
    APIFactory.session = session
  }
  
  override func tearDown() {
    mockSession.nextData = nil
    mockSession.nextError = nil
    
    AuthKeys.clearAuthentication()
    GoogleAuth.token = nil
    
    APIFactory.Yelp.V2.actionlinkParameters = nil
    APIFactory.Yelp.V2.localeParameters = nil
    APIFactory.session = nil
    super.tearDown()
  }
  
  func test_Factory_MakeResponse_ValidResponse_ReturnsResponse() {
    guard let data = Data(base64Encoded: ResponseInjections.validMockJSONResponse) else {
      return XCTFail("Failed to generate data from test fixture")
    }
    let result = APIFactory.makeResponse(for: MockValid.self, with: data)
    
    XCTAssert(result.isOk())
  }
  
  func test_Factory_MakeResponse_ResponseMissingField_ReturnsError() {
    guard let data = Data(base64Encoded: ResponseInjections.validMockJSONResponse) else {
      return XCTFail("Failed to generate data from test fixture")
    }
    let result = APIFactory.makeResponse(for: MockMissingParam.self, with: data)
    
    XCTAssert(result.isErr())
    
    guard case YelpResponseError.failedToParse(cause: .missing(field: "missing")) = result.unwrapErr() else {
      return XCTFail("Wrong error type returned")
    }
  }
  
  func test_Factory_MakeResponse_ResponseThrowsError_ReturnsError() {
    guard let data = Data(base64Encoded: ResponseInjections.validMockJSONResponse) else {
      return XCTFail("Failed to generate data from test fixture")
    }
    let result = APIFactory.makeResponse(for: MockDomainError.self, with: data)
    
    XCTAssert(result.isErr())
    
    guard result.unwrapErr() is MockError else {
      return XCTFail("Wrong error type returned")
    }
  }
  
  func test_Factory_MakeResponse_ResponseThrowsUnknownError_ReturnsError() {
    guard let data = Data(base64Encoded: ResponseInjections.validMockJSONResponse) else {
      return XCTFail("Failed to generate data from test fixture")
    }
    let result = APIFactory.makeResponse(for: MockUnknownError.self, with: data)
    
    XCTAssert(result.isErr())
    
    guard case YelpResponseError.unknownError(cause: let error) = result.unwrapErr(), error is MockRawError else {
      return XCTFail("Wrong error type returned")
    }
  }
  
  func test_Factory_MakeResponse_InvalidJSONData_ReturnsError() {
    let data = Data()
    let result = APIFactory.makeResponse(for: MockInvalidJSONError.self, with: data)
    
    XCTAssert(result.isErr())
    
    guard case YelpResponseError.failedToParse(cause: .invalidJson) = result.unwrapErr() else {
      return XCTFail("Wrong error type returned")
    }
  }
}

// MARK: Yelp V2
extension APIFactoryTests {
  func test_V2_Factory_Authenticate_SetsKeys() {
    APIFactory.Yelp.V2.setAuthenticationKeys(consumerKey: "consumer", consumerSecret: "secret", token: "token", tokenSecret: "tokenSecret")
    
    XCTAssertEqual(AuthKeys.consumerKey, "consumer")
    XCTAssertEqual(AuthKeys.consumerSecret, "secret")
    XCTAssertEqual(AuthKeys.token, "token")
    XCTAssertEqual(AuthKeys.tokenSecret, "tokenSecret")
  }
  
  // These are pretty crappy tests... Way too much coupling, but there's
  // not really anything to test here otherwise
  func test_V2_Factory_CreateSearchRequest_SetsCorrectParameters() {
    let params = YelpV2SearchParameters(location: YelpSearchLocation(location: "location"))
    
    let request = APIFactory.Yelp.V2.makeSearchRequest(with: params)
    XCTAssertEqual(request.parameters["location"], "location")
  }
  
  func test_V2_Factory_CreateBusinessRequest_SetsCorrectParameters() {
    APIFactory.Yelp.V2.localeParameters = YelpV2LocaleParameters(countryCode: YelpCountryCodeParameter.unitedStates, language: YelpV2LocaleParameters.Language.english, filterLanguage: false)
    APIFactory.Yelp.V2.actionlinkParameters = YelpV2ActionlinkParameters(actionlinks: true)
    let request = APIFactory.Yelp.V2.makeBusinessRequest(with: "12345")
    
    guard let range = request.path.range(of: "12345") else {
      return XCTFail("String not found in path")
    }
    
    // Make sure the string is at the end of the path
    XCTAssertEqual(range.upperBound, request.path.endIndex)
    
    XCTAssertEqual(request.parameters["lang"], "en")
    XCTAssertEqual(request.parameters["lang_filter"], "false")
    XCTAssertEqual(request.parameters["cc"], "US")
    XCTAssertEqual(request.parameters["actionlinks"], "true")
  }
  
  func test_V2_Factory_CreatePhoneRequest_SetsCorrectParameters() {
    let params = YelpV2PhoneSearchParameters(phone: "123456789")
    
    let request = APIFactory.Yelp.V2.makePhoneSearchRequest(with: params)
    
    XCTAssertEqual(request.parameters["phone"], "123456789")
  }
}

// MARK: Yelp V3
extension APIFactoryTests {
  func test_V3_Factory_Authenticate_ValidTokenResponse_SetsKeyAndCallsBackWithNoError() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpValidTokenRequestResponse)
    APIFactory.Yelp.V3.authenticate(appId: "appId", clientSecret: "secret") { error in
      XCTAssertNil(error)
      XCTAssertNotNil(AuthKeys.token)
    }
  }
  
  func test_V3_Factory_Authenticate_ErrorTokenResponse_DoesntSetKeyAndCallsBackWithError() {
    mockSession.nextData = Data(base64Encoded: ResponseInjections.yelpTokenRequestErrorResponse)
    APIFactory.Yelp.V3.authenticate(appId: "appId", clientSecret: "secret") { error in
      XCTAssertNotNil(error)
      
      guard case YelpResponseError.badAuth = error! else {
        return XCTFail("Wrong type of error returned")
      }
      
      XCTAssertNil(AuthKeys.token)
    }
  }
  
  func test_V3_Factory_Authenticate_InternalError_DoesntSetKeyAndCallsBackWithError() {
    mockSession.nextError = MockError()
    APIFactory.Yelp.V3.authenticate(appId: "appId", clientSecret: "secret") { error in
      XCTAssertNotNil(error)
      
      guard
        case RequestError.failedToSendRequest(cause: let error) = error!,
        error is MockError
        else {
          return XCTFail("Wrong type of error returned")
      }
      
      XCTAssertNil(AuthKeys.token)
    }
  }
  
  func test_V3_Factory_MakeSearchRequest_SetsCorrectParameters() {
    let params = YelpV3SearchParameters.init(location: YelpV3LocationParameter(location: "location"))
    
    let request = APIFactory.Yelp.V3.makeSearchRequest(with: params)
    
    XCTAssertEqual(request.parameters["location"], "location")
  }
}

// MARK: Google
extension APIFactoryTests {
  func test_Google_Factory_SetToken_SetsAuthToken() {
    APIFactory.Google.setAppToken("12345")
    
    XCTAssertEqual(GoogleAuth.token?.token, "12345")
  }
  
  func test_Google_Factory_MakeSearchRequest_WithTokenSet_ReturnsRequest() {
    let params = GooglePlaceSearchParameters(location: GooglePlaceSearchParameters.Location(latitude: 100.0, longitude: 100.0))
    
    APIFactory.Google.setAppToken("12345")
    
    let result = APIFactory.Google.makeSearchRequest(with: params)
    
    XCTAssert(result.isOk())
    XCTAssertEqual(result.unwrap().parameters["key"], "12345")
  }
  
  func test_Google_Factory_MakeSearchRequest_WithTokenUnset_ReturnsError() {
    let params = GooglePlaceSearchParameters(location: GooglePlaceSearchParameters.Location(latitude: 100.0, longitude: 100.0))
    
    let result = APIFactory.Google.makeSearchRequest(with: params)
    
    XCTAssert(result.isErr())
    
    guard case RequestError.failedToGenerateRequest = result.unwrapErr() else {
      return XCTFail("Wrong error type given")
    }
  }
}
