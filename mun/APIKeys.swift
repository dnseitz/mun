//
//  APIKeys.swift
//  mun
//
//  Created by Daniel Seitz on 11/3/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI

private let defaultClientID = "klMeb5UcJgCPYVNwZfhaT"
private let defaultClientSecret = "nr6jc2XVCYq8degawXc8J0diHHs9QGzdHXcdeCVZ"

typealias APIKeyHandler = (_ clientID: String, _ secret: String) -> Void

enum APIKeys {
  private static var cachedID: String? = nil
  private static var cachedSecret: String? = nil

  static func getKeys(_ handler: @escaping APIKeyHandler) {
    if let cachedID = cachedID, let cachedSecret = cachedSecret {
      return handler(cachedID, cachedSecret)
    }
    
    let request = APIKeyRequest()
    request.send { result in
      guard case let .ok(response) = result else {
        log(.error, for: .network, message: "APIKey request failed: \(result.unwrapErr())")
        return handler(defaultClientID, defaultClientSecret)
      }
      
      cachedID = response.clientID
      cachedSecret = response.secret
      
      return handler(response.clientID, response.secret)
    }
  }
}
