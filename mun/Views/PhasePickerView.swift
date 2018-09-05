//
//  PhasePickerView.swift
//  mun
//
//  Created by Daniel Seitz on 9/4/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import UIKit

enum PhaseChoice: String {
  case nextNew = "Next New Moon"
  case nextQuarter = "Next Quarter Moon"
  case nextFull = "Next Full Moon"
  case nextThreeQuarter = "Next Three Quarters Moon"
  case previousNew = "Previous New Moon"
  case previousQuarter = "Previous Quarter Moon"
  case previousFull = "Previous Full Moon"
  case previousThreeQuarter = "Previous Three Quarters Moon"
  case `default`
  
  func isLike(_ other: PhaseChoice) -> Bool {
    switch self {
    case .nextNew, .previousNew:
      return other == .nextNew || other == .previousNew
    case .nextQuarter, .previousQuarter:
      return other == .nextQuarter || other == .previousQuarter
    case .nextFull, .previousFull:
      return other == .nextFull || other == .previousFull
    case .nextThreeQuarter, .previousThreeQuarter:
      return other == .nextThreeQuarter || other == .previousThreeQuarter
    case .default:
      return other == .default
    }
  }
}

class PhasePickerView: UIView {
  private let pickerView: UIPickerView
  private let pickerOptions: [PhaseChoice] = [
    .previousThreeQuarter,
    .previousFull,
    .previousQuarter,
    .previousNew,
    .default,
    .nextNew,
    .nextQuarter,
    .nextFull,
    .nextThreeQuarter
  ]
  
  var defaultValue: String? {
    didSet {
      // Set value to middle choice
      pickerView.selectRow(4, inComponent: 0, animated: false)
      selectedValue = .default
    }
  }
  
  private(set) var selectedValue: PhaseChoice = .default
  
  override init(frame: CGRect) {
    pickerView = UIPickerView(frame: .zero)

    super.init(frame: frame)

    pickerView.frame = bounds
    addSubview(pickerView)
    pickerView.dataSource = self
    pickerView.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    pickerView.frame = bounds
  }
}

extension PhasePickerView: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerOptions.count
  }
}

extension PhasePickerView: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    guard row < pickerOptions.count else { return nil }
    
    if case .default = pickerOptions[row] {
      return defaultValue
    }
    return pickerOptions[row].rawValue
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard row < pickerOptions.count else { return }
    
    selectedValue = pickerOptions[row]
  }
}
