//
//  Utilities.swift
//  YAPITests
//
//  Created by Daniel Seitz on 11/11/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

internal func compare(_ x: Double, _ y: Double) -> Bool {
  return fabs(x - y) < Double.ulpOfOne
}

// MARK: Decoder Support

private struct Target<T: Decodable>: Decodable {
  let target: T
}

func decode<T: Decodable>(_ type: T.Type, using target: String) throws -> T {
  let data = try JSONEncoder().encode(["target": target])
  let decoded = try JSONDecoder().decode(Target<T>.self, from: data)
  return decoded.target
}
