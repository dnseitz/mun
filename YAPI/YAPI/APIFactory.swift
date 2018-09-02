//
//  APIFactory.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/25/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation
import CoreLocation

internal enum APIEndpoints {
  internal enum Yelp {
    internal static let host: String = "api.yelp.com"
    internal enum V2 {
      internal static let search: String = "/v2/search/"
      internal static let business: String = "/v2/business/"
      internal static let phone: String = "/v2/phone_search/"
    }
    
    internal enum V3 {
      internal static let token: String = "/oauth2/token"
      internal static let search: String = "/v3/businesses/search"
      internal static let lookup: String = "/v3/businesses"
      internal static func review(_ businessID: String) -> String {
        return "/v3/businesses/\(businessID)/reviews"
      }
    }
  }
  
  internal enum Google {
    internal static let host: String = "maps.googleapis.com"
    
    internal static let search: String = "/maps/api/place/nearbysearch/json"
    internal static let photo: String = "/maps/api/place/photo"
  }
}

/**
 Factory to generate Yelp requests and responses for use.
 */
public enum APIFactory {
  /// Yelp API namespace
  public enum Yelp {
    /// Namespace for Version 2 of Yelp API
    public enum V2 {}
    /// Namespace for Version 3 of Yelp API
    public enum V3 {}
  }
  /// Google API Namespace
  public enum Google {}
  
  // Injection for testing purposes
  static var session: HTTPClient? = nil
  static var currentSession: HTTPClient {
    return session ?? HTTPClient.sharedSession
  }

  /**
   Build a response from the JSON body recieved from making a request.
   
   - Parameter json: A dictionary containing the JSON body recieved in the Yelp response
   - Parameter request: The request that was sent in order to recieve this response
   
   - Returns: A valid response object, populated with businesses or an error
   */
  private static func makeResponse<T: Request>(for type: T.Type, withJSON json: [String: AnyObject]) -> Result<T.ResponseType, APIError> {
    do {
      return try .ok(T.ResponseType.init(withJSON: json))
    }
    catch let error as ParseError {
      return .err(YelpResponseError.failedToParse(cause: error))
    }
    catch let error as APIError {
      return .err(error)
    }
    catch {
      return .err(YelpResponseError.unknownError(cause: error))
    }
  }
  
  /**
   Build a response from the still encoded body recieved from making a request.
   
   - Parameter data: An NSData object of the data recieved from a Yelp response
   - Parameter request: The request that was sent in order to recieve this response
   
   - Returns: A valid response object, or nil if the data cannot be parsed
   */
  static func makeResponse<T: Request>(for type: T.Type, with data: Data) -> Result<T.ResponseType, APIError> {
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
      log(.info, for: .network, message: "\(T.ResponseType.self) Received:\n\(jsonStringify(json))")
      return APIFactory.makeResponse(for: type, withJSON: json as! [String: AnyObject])
    }
    catch {
      return .err(YelpResponseError.failedToParse(cause: .invalidJson(cause: error)))
    }
  }
}

// MARK: Yelp API
extension APIFactory.Yelp.V2 {
  /**
   Set the authentication keys that will be used to generate requests. These keys are needed in order
   for the Yelp API to successfully authenticate your requests, if you generate a request without these
   set the request will fail to send
   
   - Parameters:
   - consumerKey: The OAuth consumer key
   - consumerSecret: The OAuth consumer secret
   - token: The OAuth token
   - tokenSecret: The OAuth token secret
   */
  public static func setAuthenticationKeys(consumerKey: String,
                                           consumerSecret: String,
                                           token: String,
                                           tokenSecret: String) {
    AuthKeys.consumerKey = consumerKey
    AuthKeys.consumerSecret = consumerSecret
    AuthKeys.token = token
    AuthKeys.tokenSecret = tokenSecret
  }
}

extension APIFactory.Yelp.V3 {
  public static func authenticate(apiKey: String,
                                  completionBlock: @escaping (_ error: APIError?) -> Void) {
//    AuthKeys.consumerKey = appId
//    AuthKeys.consumerSecret = clientSecret
//
//    let clientId = YelpV3TokenParameters.ClientID(internalValue: appId)
//    let clientSecret = YelpV3TokenParameters.ClientSecret(internalValue: clientSecret)
//
//    let request = makeTokenRequest(with: YelpV3TokenParameters(grantType: .clientCredentials,
//                                                               clientId: clientId,
//                                                               clientSecret: clientSecret))
//
//    request.send { result in
//      switch result {
//      case .ok(let response):
//        AuthKeys.token = response.accessToken
//        completionBlock(response.error)
//      case .err(let error):
//        completionBlock(error)
//      }
//    }
    AuthKeys.apiKey = apiKey
    completionBlock(nil)
  }
}
