//
//  ViewController.swift
//  mun
//
//  Created by Daniel Seitz on 8/26/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import UIKit
import YAPI

class ViewController: UIViewController {
  
  private var moon: MoonView!
  private var dateLabel: UILabel!
  private var datePicker: UIDatePicker!
  private var datePickerAnimating: Bool = false
  private let datePickerHeight: CGFloat = 160
  private let datePickerAlpha: CGFloat = 0.7
  
  private var currentDateShown: Date = Date()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let width: CGFloat = 240.0
    let height: CGFloat = 240.0
    
    
    let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    backgroundImage.image = #imageLiteral(resourceName: "starry-background")
    
    view.addSubview(backgroundImage)
    
    moon = MoonView(frame: CGRect(x: self.view.frame.size.width/2 - width/2,
                                  y: self.view.frame.size.height/2 - height/2,
                                  width: width,
                                  height: height))
    
    moon.backgroundColor = .clear
    
    view.addSubview(moon)
    
    setupDateView(on: Date())
    
//    let slider = UISlider(frame: CGRect(x: 0, y: view.frame.height - 80, width: view.frame.width, height: 40))
//    view.addSubview(slider)
//    slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    
//    self.retrieveMoonValue(for: nil)
  }
  
  func setupDateView(on date: Date) {
    let containerView = UIView(frame: CGRect(x: 20, y: view.frame.height - 200, width: view.frame.width - 40, height: 44))
    
    containerView.backgroundColor = UIColor.clear
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateWasTapped))
    containerView.addGestureRecognizer(tapGesture)
    
    // Label
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
    label.backgroundColor = UIColor.clear
    label.text = "Moon on:"
    label.textColor = UIColor.lightText

    // Date label
    let textRect = label.textRect(forBounds: containerView.frame, limitedToNumberOfLines: 1)
    let dateLabel = UILabel(frame: CGRect(x: textRect.width + 8, y: 0, width: containerView.frame.width - textRect.width - 8, height: containerView.frame.height))
    dateLabel.backgroundColor = UIColor.clear
    dateLabel.textAlignment = .center
    dateLabel.text = format(date: date)
    dateLabel.textColor = UIColor.lightText
    dateLabel.layer.borderWidth = 1.5
    dateLabel.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    
    self.dateLabel = dateLabel
    
    containerView.addSubview(label)
    containerView.addSubview(dateLabel)
    
    view.addSubview(containerView)
    
    // Date Picker
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: containerView.frame.maxY + 4, width: view.frame.width, height: datePickerHeight))
    datePicker.backgroundColor = UIColor.lightGray.withAlphaComponent(datePickerAlpha)
    datePicker.datePickerMode = .date
    datePicker.addTarget(self, action: #selector(dateDidChange(_:)), for: UIControlEvents.valueChanged)
    
    // blur edges
    datePicker.layer.mask = createHorizontalGradientLayer(with: datePicker.bounds)
    
    self.datePicker = datePicker
    view.addSubview(datePicker)
    datePicker.frame.size.height = 0
  }
  
  func createHorizontalGradientLayer(with frame: CGRect) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = frame
    gradientLayer.colors = [UIColor.clear.cgColor,
                            UIColor.black.cgColor,
                            UIColor.black.cgColor,
                            UIColor.clear.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    gradientLayer.locations = [0, 0.2, 0.8, 1]
    
    return gradientLayer
  }
  
  @objc func dateDidChange(_ datePicker: UIDatePicker) {
    currentDateShown = datePicker.date
    dateLabel.text = format(date: currentDateShown)
  }
  
  @objc func dateWasTapped() {
    guard datePickerAnimating == false else {
      return
    }
    datePickerAnimating = true
    
    if datePicker.frame.height == 0 {
      // Open event
      UIView.animate(withDuration: 0.2, animations: {
        self.datePicker.alpha = self.datePickerAlpha
        // Calculated manually
        self.datePicker.frame.size.height = self.datePickerHeight
      }) { completed in
        self.datePickerAnimating = false
      }
    }
    else {
      // Close event, get the new date
      retrieveMoonValue(for: currentDateShown)
      UIView.animate(withDuration: 0.2,
                     delay: 0,
                     options: [UIViewAnimationOptions.curveEaseOut],
                     animations: {
        self.datePicker.alpha = 0
        self.datePicker.frame.size.height = 0
                      
      }, completion: { (completed) in
        self.datePickerAnimating = false
      })
    }
  }
  
  func format(date: Date) -> String {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale.autoupdatingCurrent
    
    return formatter.string(from: date)
  }
  
  @objc func sliderValueChanged(_ slider: UISlider) {
    moon.setPercentage(Double(slider.value), animated: false)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func retrieveMoonValue(for date: Date?) {
    let request = MoonPhaseRequest(date: date)
    request.send { result in
      guard let response = result.intoOk() else {
        log(.error, for: .network, message: "Error: \(result.unwrapErr())")
        return
      }
      
      guard let moon = response.result.first else {
        log(.error, for: .general, message: "No Moon data received")
        return
      }
      
      DispatchQueue.main.async {
        self.moon.setPercentage(moon.phase.phase, animated: true)
        self.moon.setAngle(CGFloat(moon.phase.angle), animated: true)
      }
    }
  }
}

extension ViewController: UIPickerViewDelegate {
  
}

