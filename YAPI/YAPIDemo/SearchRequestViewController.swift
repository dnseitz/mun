//
//  SearchRequestViewController.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/26/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import UIKit
import YAPI

class SearchRequestViewController: UIViewController {
  @IBOutlet weak var term: UISwitch!
  @IBOutlet weak var limit: UITextField!
  @IBOutlet weak var offset: UITextField!
  @IBOutlet weak var sortMode: UISegmentedControl!
  @IBOutlet weak var radius: UITextField!
  @IBOutlet weak var deals: UISwitch!
  @IBOutlet weak var categories: UITextField!
  
  @IBOutlet weak var send: UIButton!
  
  @IBOutlet weak var responseField: UITextView!
  
  var searchParameters: YelpV2SearchParameters = YelpV2SearchParameters(location: "Portland, OR" as YelpSearchLocation)

  override func viewDidLoad() {
    super.viewDidLoad()
    
    send.addTarget(self, action: #selector(sendRequest(sender:)), for: .touchUpInside)
    
    responseField.text = ""
  }
  
  @objc func sendRequest(sender: UIButton) {
    clearParameters()
    
    setTerm()
    setLimit()
    setOffset()
    setSortMode()
    setRadius()
    setDeals()
    setCategories()
    
    let request = YelpAPIFactory.V2.makeSearchRequest(with: self.searchParameters)
    
    request.send { result in
      var text = ""
      switch result {
      case .ok(let response):
        if response.wasSuccessful, let businesses = response.businesses {
          for business in businesses {
            text += "\(business.name)\n"
          }
        }
        else {
          text += "\(response.error)\n"
        }
      case .err(let error):
        text += "Error recieved: \(error)\n"
      }
      print(text)
      DispatchQueue.main.async {
        self.responseField.text = text
      }
    }
  }
  
  func setTerm() {
    if self.term.isOn {
      self.searchParameters.term = .food
    }
    else {
      self.searchParameters.term = .drink
    }
  }
  
  func setLimit() {
    guard let text = self.limit.text, let value = Int(text) else { return }
    self.searchParameters.limit = YelpV2SearchParameters.Limit(value)
  }
  
  func setOffset() {
    guard let text = self.offset.text, let value = Int(text) else { return }
    self.searchParameters.offset = YelpV2SearchParameters.Offset(value)
  }
  
  func setSortMode() {
    let mode: YelpV2SearchParameters.SortMode
    switch self.sortMode.selectedSegmentIndex {
    case 0:
      mode = .best
      break
    case 1:
      mode = .distance
      break
    case 2:
      mode = .highestRated
      break
    default:
      return
    }
    self.searchParameters.sortMode = mode
  }
  
  func setRadius() {
    guard let text = self.offset.text, let value = Int(text) else { return }
    self.searchParameters.radius = YelpV2SearchParameters.Radius(value)
  }
  
  func setDeals() {
    self.searchParameters.filterDeals = YelpV2SearchParameters.Deals(self.deals.isOn)
  }
  
  func setCategories() {
    guard let value = self.categories.text else { return }
    let array = value.components(separatedBy: ",")
    let categories = array.map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    self.searchParameters.categories = YelpV2SearchParameters.Categories(categories)
  }
  
  func clearParameters() {
    self.searchParameters = YelpV2SearchParameters(location: "Portland, OR" as YelpSearchLocation)
  }
}
