//
//  MoonPhaseSearchRequest.swift
//  mun
//
//  Created by Daniel Seitz on 9/4/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI
import OAuthSwift

class MoonPhaseSearchRequest: Request {
  typealias ResponseType = MoonPhaseSearchResponse
  
  var oauthVersion: OAuthSwiftCredential.Version? = .oauth2
  var host: String = "api.aerisapi.com/"
  var path: String = "sunmoon/moonphases/search"
  var parameters: [String : String] = ["client_id": "klMeb5UcJgCPYVNwZfhaT",
                                       "client_secret": "Ya1VIjNhqJCsbkpxsz9xdf5dR6KjpijDbv5IS0n9",
                                       "p": "45.5122,122.6587"]
  
  var requestMethod: OAuthSwiftHTTPRequest.Method = .GET
  
  var session: HTTPClient = HTTPClient.sharedSession
  
  init?(phaseChoice: PhaseChoice, currentSelectedDate: Date) {
    // Arbitrary values that we use to massage the service data
    let thirtyDaysAsSeconds = 2592000.0 * 2.0
    let twelveHoursAsSeconds = 43200.0
    let currentTimeMinus30Days = String(Int(currentSelectedDate.timeIntervalSince1970 - thirtyDaysAsSeconds))
    let currentTimeMinus6Hours = String(Int(currentSelectedDate.timeIntervalSince1970 - twelveHoursAsSeconds))
    let currentTimePlus6Hours = String(Int(currentSelectedDate.timeIntervalSince1970 + twelveHoursAsSeconds))
    let currentTimePlus30Days = String(Int(currentSelectedDate.timeIntervalSince1970 + thirtyDaysAsSeconds))
    parameters["limit"] = "2"
    parameters["query"] = phaseChoice.queryParameter
    parameters["sort"] = phaseChoice.sortParameter
    parameters["filter"] = phaseChoice.filterParameter
    switch phaseChoice {
    case .default: return nil
    case .nextFull:
      parameters["from"] = currentTimePlus6Hours
      parameters["to"] = currentTimePlus30Days
    case .nextNew:
      parameters["from"] = currentTimePlus6Hours
      parameters["to"] = currentTimePlus30Days
    case .nextQuarter:
      parameters["from"] = currentTimePlus6Hours
      parameters["to"] = currentTimePlus30Days
    case .nextThreeQuarter:
      parameters["from"] = currentTimePlus6Hours
      parameters["to"] = currentTimePlus30Days
    case .previousFull:
      parameters["from"] = currentTimeMinus30Days
      parameters["to"] = currentTimeMinus6Hours
    case .previousNew:
      parameters["from"] = currentTimeMinus30Days
      parameters["to"] = currentTimeMinus6Hours
    case .previousQuarter:
      parameters["from"] = currentTimeMinus30Days
      parameters["to"] = currentTimeMinus6Hours
    case .previousThreeQuarter:
      parameters["from"] = currentTimeMinus30Days
      parameters["to"] = currentTimeMinus6Hours
    }
  }
}

extension PhaseChoice {
  var queryParameter: String? {
    switch self {
    case .nextNew, .previousNew:
      return "code:0"
    case .nextQuarter, .previousQuarter:
      return "code:1"
    case .nextFull, .previousFull:
      return "code:2"
    case .nextThreeQuarter, .previousThreeQuarter:
      return "code:3"
    case .default:
      return nil
    }
  }
  
  var filterParameter: String? {
    switch self {
    case .nextNew, .previousNew:
      return "new"
    case .nextQuarter, .previousQuarter:
      return "first"
    case .nextFull, .previousFull:
      return "full"
    case .nextThreeQuarter, .previousThreeQuarter:
      return "third"
    case .default:
      return nil
    }
  }
  
  var sortParameter: String? {
    switch self {
    case .nextNew, .nextQuarter, .nextFull, .nextThreeQuarter:
      return "dt:1"
    case .previousNew, .previousQuarter, .previousFull, .previousThreeQuarter:
      return "dt:-1"
    case .default:
      return nil
    }
  }
}
