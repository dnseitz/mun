//
//  APIFactory.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/25/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation
import CoreLocation

/// Factory to generate requests and responses for use.
public enum APIFactory {
  
  // Injection for testing purposes
  internal static var session: HTTPClient? = nil
  public static var currentSession: HTTPClient {
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
    catch let error as APIError {
      return .err(error)
    }
    catch {
      return .err(ResponseError.unknownError(cause: error))
    }
  }
  
  /**
   Build a response from the still encoded body recieved from making a request.
   
   - Parameter data: An NSData object of the data recieved from a Yelp response,
       should be a serialized JSON dictionary or array
   - Parameter request: The request that was sent in order to recieve this response
   
   - Returns: A valid response object, or nil if the data cannot be parsed
   */
  static func makeResponse<T: Request>(for type: T.Type, with data: Data) -> Result<T.ResponseType, APIError> {
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
      
      let jsonDictionary: [String: AnyObject]
      if let jsonArray = json as? [AnyObject] {
        jsonDictionary = ["data": jsonArray] as [String : AnyObject]
      } else if let json = json as? [String: AnyObject] {
        jsonDictionary = json
      } else {
        return .err(ParseError.jsonNotArrayOrDictionary)
      }

      log(.info, for: .network, message: "\(T.ResponseType.self) Received:\n\(jsonStringify(json))")
      return APIFactory.makeResponse(for: type, withJSON: jsonDictionary)
    }
    catch {
      return .err(ParseError.invalidJson(cause: error))
    }
  }
}
