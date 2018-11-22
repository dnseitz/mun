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

  let oauthVersion: OAuthSwiftCredential.Version? = .oauth2
  let host: String = "themunman.com"
  let path: String = "/aeris_key"
  let parameters: ParameterList = ParameterList()
  let requestMethod: OAuthSwiftHTTPRequest.Method = .GET
  let session: HTTPClient = .sharedSession
//  var port: Int? = 7979
}
