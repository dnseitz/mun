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
import CoreLocation

class MoonPhaseRequest: Request {
  typealias ResponseType = MoonPhaseResponse

  var oauthVersion: OAuthSwiftCredential.Version? = .oauth2
  var host: String = "api.aerisapi.com/"
  var path: String = "sunmoon/"
  var parameters: [String : String] = ["filter": "moon,moonphase"]
  
  var requestMethod: OAuthSwiftHTTPRequest.Method = .GET
  
  var session: HTTPClient = HTTPClient.sharedSession
  
  init(date: Date? = nil, location: CLLocation? = nil) {
    if let date = date {
      parameters["from"] = String(Int(date.timeIntervalSince1970))
    }
    
    if let location = location {
      parameters["p"] = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
    }
    else {
      parameters["p"] = "portland,or,us"
    }
  }
  
  func prepare(completionHandler handler: @escaping RequestPrepareHandler) {
    APIKeys.getKeys { [weak self] clientID, clientSecret in
      guard let self = self else { return }
      self.parameters["client_id"] = clientID
      self.parameters["client_secret"] = clientSecret
      return handler()
    }
  }
}
