//
//  MoonPhaseRequest.swift
//  mun
//
//  Created by Daniel Seitz on 9/1/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI
import OAuthSwift

class MoonPhaseRequest: Request {
  typealias ResponseType = MoonPhaseResponse

  var oauthVersion: OAuthSwiftCredential.Version? = .oauth2
  var host: String = "api.aerisapi.com/"
  var path: String = "sunmoon/"
  var parameters: [String : String] = ["client_id": "klMeb5UcJgCPYVNwZfhaT",
                                       "client_secret": "Ya1VIjNhqJCsbkpxsz9xdf5dR6KjpijDbv5IS0n9",
                                       "filter": "moon,moonphase",
                                       "p": "portland,or,us"]
  
  var requestMethod: OAuthSwiftHTTPRequest.Method = .GET
  
  var session: HTTPClient = HTTPClient.sharedSession
  
  init(date: Date? = nil) {
    if let date = date {
      parameters["from"] = String(Int(date.timeIntervalSince1970))
    }
  }
}
