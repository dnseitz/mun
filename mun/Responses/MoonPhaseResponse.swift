//
//  MoonPhaseResponse.swift
//  mun
//
//  Created by Daniel Seitz on 9/1/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI

struct NotImplementedError: Error {
  
}

struct Moon: Decodable {
//  let riseISO: Date?
//  let setISO: Date?
//  let transitISO: Date?
//  let underfootISO: Date?
  let phase: MoonPhase
}

struct MoonPhase: Decodable {
  /// The moon phase percentage.
  let phase: Double
  
  /// The moon phase name.
  let name: String
  
  /// The percentage of the moon that is illuminated.
  let illum: Double
  
  /// The age of the moon phase in days
  let age: Double
  
  /// The moon phase angle
  let angle: Double
}

class MoonPhaseResponse: Response {
  required init(withJSON data: [String : AnyObject]) throws {
    let decoder = JSONDecoder()
    let response = data["response"] as? [[String: Any]]
    guard let moons = response?.compactMap({ $0["moon"] as? [String: Any] }) else {
      throw ParseError.missing(field: "moon")
    }
    
//    self.error = try GooglePlaceSearchResponse.parseError(from: data)
    
    do {
      
      self.result = try decoder.decode(Array<Moon>.self,
                                       from: JSONSerialization.data(withJSONObject: moons as Any))
//      self.nextPageToken = try? data.parseParam(key: Params.next_page_token)
    }
    catch {
      throw ParseError.decoderFailed(cause: error)
    }
  }
  
  var error: APIError?
  let result: [Moon]
}
