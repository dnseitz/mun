//
//  APIKeyResponse.swift
//  mun
//
//  Created by Daniel Seitz on 11/3/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI

enum APIKeyError: APIError {
  case noClienID
  case noSecret
  
  var description: String {
    switch  self {
    case .noClienID:
      return "No client ID found in response"
    case .noSecret:
      return "No client secret found in response"
    }
  }
}

class APIKeyResponse: Response {
  var error: APIError?
  
  private enum ResponseParams {
    static let clientID = "key"
    static let secret = "secret"
  }
  
  var clientID: String
  var secret: String

  required init(withJSON data: [String : AnyObject]) throws {
    guard let clientID = data[ResponseParams.clientID] as? String else {
      throw APIKeyError.noClienID
    }
    
    guard let secret = data[ResponseParams.secret] as? String else {
      throw APIKeyError.noSecret
    }
    
    self.clientID = clientID
    self.secret = secret
  }
}
