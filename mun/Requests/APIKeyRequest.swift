//
//  APIKeyRequest.swift
//  mun
//
//  Created by Daniel Seitz on 11/3/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI
import OAuthSwift

class APIKeyRequest: Request {
  typealias ResponseType = APIKeyResponse

  var oauthVersion: OAuthSwiftCredential.Version? = .oauth2
  var host: String = "themunman.com"
  var path: String = "/aeris_key"
  var parameters: [String : String] = [:]
  var requestMethod: OAuthSwiftHTTPRequest.Method = .GET
  var session: HTTPClient = .sharedSession
//  var port: Int? = 7979
}
