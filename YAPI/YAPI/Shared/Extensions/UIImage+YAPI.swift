//
//  UIImage+YAPI.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/30/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

extension UIImage {
  func copy(withScale scale: CGFloat = 1.0) -> UIImage? {
    guard let cgImage = self.cgImage?.copy() else {
      return nil
    }
    return UIImage(cgImage: cgImage, scale: scale, orientation: self.imageOrientation)
  }
}
