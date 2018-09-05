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
  let riseISO: Date?
  let setISO: Date?
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
    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
    let response = data["response"] as? [[String: Any]]
    guard let moons = response?.compactMap({ $0["moon"] as? [String: Any] }) else {
      throw ParseError.missing(field: "moon")
    }
    
    do {
      
      self.result = try decoder.decode(Array<Moon>.self,
                                       from: JSONSerialization.data(withJSONObject: moons as Any))
    }
    catch {
      throw ParseError.decoderFailed(cause: error)
    }
  }
  
  var error: APIError?
  let result: [Moon]
}

extension Formatter {
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
  }()
}
