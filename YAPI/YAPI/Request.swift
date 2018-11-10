//
//  YelpInterfaceModel.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/22/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation
import CoreLocation
import OAuthSwift


// Cached oauth clients for sending requests
private var OAuth1Client: OAuthSwiftClient? = nil
private var OAuth2Client: OAuthSwiftClient? = nil
private func oAuthClient(for version: OAuthSwiftCredential.Version?) -> OAuthSwiftClient? {
  guard let version = version else {
    return nil
  }

  switch version {
  case .oauth1:
    if let client = OAuth1Client {
      return client
    }
    else {
      guard
        let consumerKey = AuthKeys.consumerKey,
        let consumerSecret = AuthKeys.consumerSecret,
        let token = AuthKeys.token,
        let tokenSecret = AuthKeys.tokenSecret
        else {
          assert(false, "The request requires a consumerKey, consumerSecret, token, and tokenSecret in order to access the Yelp API, set these through the YelpAPIFactory")
          return nil
      }
      let client = OAuthSwiftClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: token, oauthTokenSecret: tokenSecret, version: .oauth1)
      OAuth1Client = client
      return client
    }
  case .oauth2:
    if let client = OAuth2Client {
      if let token = AuthKeys.token {
        client.credential.oauthToken = token
      }
      return client
    }
    else {
//      guard let token = AuthKeys.apiKey else {
//        assert(false, "Yelp API requires an apiKey to function")
//        return nil
//      }
      let credential = OAuthSwiftCredential(consumerKey: "klMeb5UcJgCPYVNwZfhaT", consumerSecret: "Ya1VIjNhqJCsbkpxsz9xdf5dR6KjpijDbv5IS0n9")
//      credential.oauthToken = token
      credential.version = .oauth2
      OAuth2Client = OAuthSwiftClient(credential: credential)
      return OAuth2Client
//      guard
//        let consumerKey = AuthKeys.consumerKey,
//        let consumerSecret = AuthKeys.consumerSecret
//        else {
//          assert(false, "The request requires a consumerKey and consumerSecret in order to access the Yelp API, set these through the YelpAPIFactory")
//          return nil
//      }
//      let credential = OAuthSwiftCredential(consumerKey: consumerKey, consumerSecret: consumerSecret)
//      credential.version = .oauth2
//      let client = OAuthSwiftClient(credential: credential)
//      OAuth2Client = client
//      return client
    }
  }
}

public typealias RequestPrepareHandler = () -> Void

/**
    Any request that can be sent to the Yelp API conforms to this protocol. This could include requests to 
    the search API, business API, etc. The sendRequest function will query the Yelp API and return either a 
    response or an error.
 
    - Usage:
    ```
      // Given some Request
 
      // Send the request and handle the response
      yelpRequest.send() { (response, error) in
        // Handle response or error
      }
    ```
 */
public protocol Request {
  associatedtype ResponseType: Response
  
  /// The version of OAuth to use
  var oauthVersion: OAuthSwiftCredential.Version? { get }
  
  /// The hostname of the endpoint
  var host: String { get }
  
  /// The path to the api resource
  var path: String { get }
  
  /// Query parameters to include in the request
  var parameters: [String: String] { get }
  
  /// The HTTP Method used for this request
  var requestMethod: OAuthSwiftHTTPRequest.Method { get }
  
  /// The http session used to send this request
  var session: HTTPClient { get }
  
  /// The port to connect to
  var port: Int? { get }
  
  /**
   Prepare the request for sending, this is called right before sending the request, allowing the
   client to do any setup needed to finalize the request.
   
   - Parameter completionHandler: The block to call once preparation of the request has finished
   */
  func prepare(completionHandler handler: @escaping RequestPrepareHandler)
  
  /**
   Sends the request, calling the given handler with either the yelp response or an error. This can be
   called multiple times to retry sending the request
   
   - Parameter completionHandler: The block to call when the response returns, takes a Response? and
   a YelpError? as arguments, the error can be of YelpResponseError type or YelpRequestError type
   */
  func send(completionHandler handler: @escaping (_ result: Result<Self.ResponseType, APIError>) -> Void)
}

public extension Request {
  var port: Int? {
    return nil
  }
  
  public func prepare(completionHandler handler: @escaping RequestPrepareHandler) {
    return handler()
  }

  public func send(completionHandler handler: @escaping (_ result: Result<Self.ResponseType, APIError>) -> Void) {
    self.prepare {
      self.internalSend(completionHandler: handler)
    }
  }
}

internal extension Request {
  func internalSend(completionHandler handler: @escaping (_ result: Result<Self.ResponseType, APIError>) -> Void) {
    guard let urlRequest = self.generateURLRequest() else {
      handler(.err(RequestError.failedToGenerateRequest))
      return
    }
    
    self.session.send(urlRequest) { data, response, error in
      var result: Result<Self.ResponseType, APIError>
      defer {
        handler(result)
      }
      
      if let err = error {
        result = .err(RequestError.failedToSendRequest(cause: err))
        return
      }
      
      guard let jsonData = data else {
        result = .err(YelpResponseError.noDataRecieved)
        return
      }
      
      result = APIFactory.makeResponse(for: Self.self, with: jsonData)
    }
  }
}

fileprivate extension Request {
  func generateURLRequest() -> URLRequest? {
    
    if let client = oAuthClient(for: oauthVersion) {
      // HACK - only use port on custom server
      let scheme = "https"
//      let port = self.port != nil ? ":\(self.port!)" : ""
      guard
        let request = client.makeRequest("\(scheme)://\(self.host)\(self.path)",
                                         method: self.requestMethod,
                                         parameters: self.parameters,
                                         headers: nil,
                                         body: nil) else {
        return nil
      }
    
      return try? request.makeRequest()
    }
    else {
      var components = URLComponents()
      components.scheme = "https"
      components.host = self.host
      components.path = self.path
      components.port = self.port
      components.queryItems = self.parameters.map { URLQueryItem(name: $0, value: $1) }
      
      return components.url.map { URLRequest(url: $0) }
    }
  }
}
