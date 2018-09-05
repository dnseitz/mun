//
//  DateView.swift
//  mun
//
//  Created by Daniel Seitz on 9/4/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import UIKit

class DateView: UIView {
  let label: UILabel
  let dateLabel: UILabel
  let activityIndicator: UIActivityIndicatorView
  
  var text: String? {
    get {
      return dateLabel.text
    }

    set {
      dateLabel.text = newValue
    }
  }
  
  var isLoading: Bool = false {
    didSet {
      let disabledBackgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
      let enabledBackgroundColor = UIColor.clear
      
      if isLoading {
        dateLabel.backgroundColor = disabledBackgroundColor
        activityIndicator.startAnimating()
        isUserInteractionEnabled = false
      }
      else {
        dateLabel.backgroundColor = enabledBackgroundColor
        activityIndicator.stopAnimating()
        isUserInteractionEnabled = true
      }
    }
  }

  override init(frame: CGRect) {
    label = UILabel()
    dateLabel = UILabel()
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    super.init(frame: frame)
//    let containerView = UIView(frame: CGRect(x: 20, y: view.frame.height - 200, width: view.frame.width - 40, height: 44))
    
    backgroundColor = UIColor.clear
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateWasTapped))
//    containerView.addGestureRecognizer(tapGesture)
    
    label.backgroundColor = UIColor.clear
    label.text = "Moon on:"
    label.textColor = UIColor.lightText
    
    dateLabel.backgroundColor = UIColor.clear
    dateLabel.textAlignment = .center
    dateLabel.textColor = UIColor.lightText
    dateLabel.layer.borderWidth = 1.5
    dateLabel.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    
    activityIndicator.hidesWhenStopped = true

    dateLabel.addSubview(activityIndicator)

    addSubview(label)
    addSubview(dateLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    // Label
    label.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    
    // Date label
    let textRect = label.textRect(forBounds: label.bounds, limitedToNumberOfLines: 1)
    dateLabel.frame = CGRect(x: textRect.width + 8, y: 0,
                             width: frame.width - textRect.width - 8,
                             height: frame.height)

//    dateLabel.text = format(date: date)
    
    activityIndicator.frame = CGRect(x: 0, y: 0,
                                     width: dateLabel.frame.width,
                                     height: dateLabel.frame.height)
  }
}
