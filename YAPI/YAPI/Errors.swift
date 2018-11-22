//
//  YelpErrors.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/27/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation

/**
    A protocol describing an error caused by either a Request or Response
 */
public protocol APIError: Error, CustomStringConvertible {}

/**
    Errors that occur while trying to send the request
 */
public enum RequestError: APIError {
  /// The request was unable to be generated, possibly a malformed url
  case failedToGenerateRequest
  /// The request failed to send for some reason, see the wrapped Error for details
  case failedToSendRequest(cause: Error)
  
  public var description: String {
    switch self {
    case .failedToGenerateRequest:
      return "Failed to generate the Network Request for some reason"
    case .failedToSendRequest(cause: let cause):
      return "Failed to send request (\(cause))"
    }
  }
}

/// Errors that can return from a response
public enum ResponseError: APIError {
  /// An unknown error occurred with the service
  case unknownError(cause: Error?)
  /// No data was recieved in the response
  case noDataRecieved
  
  public var description: String {
    switch self {
    case .unknownError(cause: let cause):
      let causeDescription: String
      if let cause = cause {
        causeDescription = ": \(cause)"
      }
      else {
        causeDescription = ""
      }
      return "An unknown error has occurred" + causeDescription
    case .noDataRecieved:
      return "No data was recieved in the response"
    }
  }
}

public enum ParseError: APIError {
  
  // The data is not in JSON format
  case invalidJson(cause: Error)
  
  /// The data was not an array or a dictionary
  case jsonNotArrayOrDictionary
  
  // A required field was missing in the response
  case missing(field: String)
  
  // A piece of data was not recognized
  case invalid(field: String, value: String)
  
  // The decoder failed to decode the response object
  case decoderFailed(cause: Error)
  
  // The cause of the failure is unknown
  case unknown
  
  public var description: String {
    switch self {
    case .invalidJson(cause: let cause):
      return "The data is not in JSON format: <\(cause)>"
    case .jsonNotArrayOrDictionary:
      return "The data was not a JSON array or dictionary, we do not support this"
    case .missing(field: let field):
      return "A required field <\(field)> was missing in the response"
    case .invalid(field: let field, value: let value):
      return "A piece of data was not recognized <\(field): \(value)>"
    case .decoderFailed(cause: let cause):
      return "The decoder failed to decode the response object: <\(cause)>"
    case .unknown:
      return "The cause of the failure is unknown"
    }
  }
}

internal struct UnknownErrorCode: Error {
  let code: String
  
  init?(code: String?) {
    guard let code = code else { return nil }
    
    self.code = code
  }
}
