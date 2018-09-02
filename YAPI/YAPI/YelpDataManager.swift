//
//  YelpDataManager.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/25/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation
import UIKit

final class YelpDataManager {
  /// Singleton data manager to be shared globally
  static let sharedInstance: YelpDataManager = YelpDataManager()
  
  /// The request parameters that will be sent on the next request
  var requestParams: YelpSearchParameters
  
  private let spinner: UIActivityIndicatorView
  
  private init() {
    self.requestParams = YelpSearchParameters()
    self.spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 160, 160))
    self.spinner.activityIndicatorViewStyle = .Gray
  }
  
  /**
      Display an activity indicator on the top most viewcontroller to show that work is being done,
      can be called multiple times safely
   */
  func showSpinner() {
    if !self.spinner.isAnimating() {
//      if let topViewController = UIApplication.topViewController() {
        self.spinner.startAnimating()
//        self.spinner.center = topViewController.view.center
//        topViewController.view.addSubview(self.spinner)
//      }
    }
  }
  
  /**
      Remove the activity indicator from the superview that it was attatched to, this can be called
      multiple times safely
   */
  func hideSpinner() {
    if self.spinner.isAnimating() {
      self.spinner.stopAnimating()
      self.spinner.removeFromSuperview()
    }
  }
  
  /**
      Reset all request parameters to nil
   */
  func resetParams() {
    self.requestParams = YelpSearchParameters()
  }
}

