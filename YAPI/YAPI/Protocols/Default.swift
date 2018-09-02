//
//  Default.swift
//  YAPI
//
//  Created by Daniel Seitz on 5/26/18.
//  Copyright © 2018 Daniel Seitz. All rights reserved.
//

import Foundation

public protocol Default {
  static var defaultValue: Self { get }
}
