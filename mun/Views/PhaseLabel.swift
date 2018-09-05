//
//  PhaseLabel.swift
//  mun
//
//  Created by Daniel Seitz on 9/4/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import UIKit

class PhaseLabel: UILabel {
  private let boundingBox: UIView
  private let activityIndicator: UIActivityIndicatorView
  
  var isLoading: Bool = false {
    didSet {
      let disabledBackgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
      let enabledBackgroundColor = UIColor.clear
      if isLoading {
        boundingBox.backgroundColor = disabledBackgroundColor
        activityIndicator.startAnimating()
        isUserInteractionEnabled = false
      }
      else {
        boundingBox.backgroundColor = enabledBackgroundColor
        activityIndicator.stopAnimating()
        isUserInteractionEnabled = true
      }
    }
  }
  
  override init(frame: CGRect) {
    boundingBox = UIView()
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    super.init(frame: frame)
    
    isUserInteractionEnabled = true
    
    boundingBox.layer.borderColor = UIColor.lightGray.cgColor
    boundingBox.layer.borderWidth = 1.5
    boundingBox.isUserInteractionEnabled = false
    
    activityIndicator.hidesWhenStopped = true

    addSubview(boundingBox)
    addSubview(activityIndicator)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let boundingRect = textRect(forBounds: bounds, limitedToNumberOfLines: 1)
    boundingBox.frame = CGRect(x: boundingRect.origin.x - 5,
                               y: bounds.origin.y,
                               width: boundingRect.width + 10,
                               height: bounds.height)
    
    activityIndicator.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
  }
}
