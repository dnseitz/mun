//
//  MoonPhaseSearchResponse.swift
//  mun
//
//  Created by Daniel Seitz on 9/4/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import YAPI

struct MoonPhaseSearchData: Decodable {
  let dateTimeISO: Date
  let code: Int
}

class MoonPhaseSearchResponse: Response {
  var error: APIError?
  let result: [MoonPhaseSearchData]
  required init(withJSON data: [String : AnyObject]) throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
    let response = data["response"] as? [[String: Any]]
    
    do {
      self.result = try decoder.decode(Array<MoonPhaseSearchData>.self,
                                       from: JSONSerialization.data(withJSONObject: response as Any))
    }
    catch {
      throw ParseError.decoderFailed(cause: error)
    }
  }
}
