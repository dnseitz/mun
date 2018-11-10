//
//  ViewController.swift
//  mun
//
//  Created by Daniel Seitz on 8/26/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import UIKit
import YAPI
import CoreLocation

class ViewController: UIViewController {
  private let locationManager = CLLocationManager()
  private var shouldForceRotation: Bool = false
  
//  private var queuedAnimations: [(animation: () -> Void, completion: (Bool) -> Void)] = []
  
  private var dateActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
  
  private var moonLabel1: UILabel!
  private var moonLabel2: UILabel!
  private var moonPhaseLabel: PhaseLabel!
  private var phasePicker: PhasePickerView!
  private var phasePickerAlpha: CGFloat = 0.9

  private var moon: MoonView!
  private var dateView: DateView!
  private var datePicker: UIDatePicker!
  private let datePickerHeight: CGFloat = 160
  private let datePickerAlpha: CGFloat = 0.7
  
  private var currentDateShown: Date = Date() {
    didSet {
      dateView.text = format(date: currentDateShown)
      datePicker.date = currentDateShown
    }
  }
  private var currentDatePicked: Date = Date()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let width: CGFloat = 220.0
    let height: CGFloat = 220.0
    
    let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    backgroundImage.image = #imageLiteral(resourceName: "starry-background")
    
    view.addSubview(backgroundImage)
    
    moon = MoonView(frame: CGRect(x: self.view.frame.size.width/2 - width/2,
                                  y: self.view.frame.size.height/2 - height/2,
                                  width: width,
                                  height: height))
    
    moon.backgroundColor = .clear
    
    view.addSubview(moon)
    
    let phaseLabel = PhaseLabel(frame: CGRect(x: 0, y: moon.frame.minY - 58, width: view.frame.width, height: 50))
    phaseLabel.textAlignment = .center
    phaseLabel.textColor = UIColor.lightText
    phaseLabel.backgroundColor = .clear
    phaseLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    phaseLabel.text = "moon phase"
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(phaseWasTapped))
    phaseLabel.addGestureRecognizer(tapGesture)
    phaseLabel.isUserInteractionEnabled = true
  
    moonPhaseLabel = phaseLabel
    
    let picker = PhasePickerView(frame: CGRect(x: 0, y: phaseLabel.frame.maxY + 4, width: view.frame.width, height: datePickerHeight))
    picker.backgroundColor = UIColor.lightGray.withAlphaComponent(phasePickerAlpha)
    picker.layer.mask = createHorizontalGradientLayer(with: picker.bounds)

    phasePicker = picker
    view.addSubview(picker)
    picker.frame.size.height = 0
    picker.setNeedsLayout()

    view.addSubview(phaseLabel)
    
    let moonLabel1 = UILabel(frame: CGRect(x: 0, y: phaseLabel.frame.minY - 34, width: view.frame.width, height: 30))
    moonLabel1.textAlignment = .center
    moonLabel1.textColor = .lightText
    moonLabel1.backgroundColor = .clear
    self.moonLabel1 = moonLabel1
    view.addSubview(moonLabel1)
    
    let moonLabel2 = UILabel(frame: CGRect(x: 0, y: moonLabel1.frame.minY - 34, width: view.frame.width, height: 30))
    moonLabel2.textAlignment = .center
    moonLabel2.textColor = .lightText
    moonLabel2.backgroundColor = .clear
    self.moonLabel2 = moonLabel2
    view.addSubview(moonLabel2)
    
    setupDateView(on: Date())
    
    // Low accuracy since it doesn't matter that much
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    locationManager.distanceFilter = 10000
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    showLoadingSpinners(true)
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      locationManager.requestLocation()
    }
    else {
      retrieveMoonValue(for: currentDatePicked, dateInPast: false)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    currentDateShown = currentDatePicked
  }
  
  func setupDateView(on date: Date) {
    let dateView = DateView(frame: CGRect(x: 20, y: view.frame.height - 240, width: view.frame.width - 40, height: 44))

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateWasTapped))
    dateView.addGestureRecognizer(tapGesture)
    
    dateView.text = format(date: date)

    self.dateView = dateView
    view.addSubview(dateView)
    
    // Date Picker
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: dateView.frame.maxY + 4, width: view.frame.width, height: datePickerHeight))
    datePicker.backgroundColor = UIColor.lightGray.withAlphaComponent(datePickerAlpha)
    datePicker.datePickerMode = .dateAndTime
    datePicker.addTarget(self, action: #selector(dateDidChange(_:)), for: UIControlEvents.valueChanged)
    
    // blur edges
    datePicker.layer.mask = createHorizontalGradientLayer(with: datePicker.bounds)
    
    self.datePicker = datePicker
    view.addSubview(datePicker)
    datePicker.frame.size.height = 0
  }
}

// MARK: Networking
private extension ViewController {
  func retreiveNextPhase(_ phaseChoice: PhaseChoice) {
    guard let request = MoonPhaseSearchRequest(phaseChoice: phaseChoice,
                                               currentSelectedDate: currentDatePicked,
                                               location: locationManager.location) else {
      return
    }
    
    shouldForceRotation = phaseChoice.isLike(selectedPhase())
    
    showLoadingSpinners(true)
    request.send { result in
      guard let response = result.intoOk() else {
        self.showLoadingSpinners(false)
        log(.error, for: .network, message: "Error: \(result.unwrapErr())")
        return
      }
      
      guard let nextMoon = response.result.first else {
        self.showLoadingSpinners(false)
        log(.error, for: .general, message: "No moon data found")
        return
      }
      
      DispatchQueue.main.async {
        self.datePicker.date = nextMoon.dateTimeISO
        self.currentDateShown = nextMoon.dateTimeISO
        self.retrieveMoonValue(for: self.currentDateShown,
                               dateInPast: self.currentDateShown < self.currentDatePicked)
        self.currentDatePicked = self.currentDateShown
      }
    }
  }
  
  func retrieveMoonValue(for date: Date, dateInPast: Bool) {
    let request = MoonPhaseRequest(date: date, location: locationManager.location)
    showLoadingSpinners(true)
    request.send { result in
      defer {
        DispatchQueue.main.async {
          self.showLoadingSpinners(false)
          self.shouldForceRotation = false
        }
      }
      
      guard let response = result.intoOk() else {
        log(.error, for: .network, message: "Error: \(result.unwrapErr())")
        return
      }
      
      guard let moon = response.result.first else {
        log(.error, for: .general, message: "No Moon data received")
        return
      }
      
      DispatchQueue.main.async {
        self.moon.setPercentage(moon.phase.phase,
                                animated: true,
                                forward: dateInPast,
                                shouldForceRotation: self.shouldForceRotation)
        self.moon.setAngle(CGFloat(moon.phase.angle), animated: true)
        self.moonPhaseLabel.text = moon.phase.name
        self.view.setNeedsLayout()
        
        if let riseDate = moon.riseISO, let setDate = moon.setISO {
          let moonRiseText = "Moon rises at \(self.format(date: riseDate, withDate: false))"
          let moonSetText = "Moon sets at \(self.format(date: setDate, withDate: false))"
          self.moonLabel2.text = riseDate < setDate ? moonRiseText : moonSetText
          self.moonLabel1.text = riseDate < setDate ? moonSetText : moonRiseText
        }
        else if let riseDate = moon.riseISO {
          self.moonLabel2.text = nil
          self.moonLabel1.text = "Moon rises at \(self.format(date: riseDate, withDate: false))"
        }
        else if let setDate = moon.setISO {
          self.moonLabel2.text = nil
          self.moonLabel1.text = "Moon sets at \(self.format(date: setDate, withDate: false))"
        }
        else {
          self.moonLabel2.text = nil
          self.moonLabel1.text = nil
        }
      }
    }
  }
}

// MARK: Action Handling
private extension ViewController {
  @objc func dateWasTapped() {
    if datePicker.frame.height == 0 {
      // Open event
      expand(view: datePicker, toHeight: datePickerHeight, toAlpha: datePickerAlpha, animated: true)
      collapse(view: phasePicker, animated: true)
    }
    else {
      // Close event, get the new date
      if self.currentDateShown != self.currentDatePicked {
        self.retrieveMoonValue(for: self.currentDateShown, dateInPast: self.currentDateShown < self.currentDatePicked)
        self.currentDatePicked = self.currentDateShown
      }
      collapse(view: datePicker, animated: true)
    }
  }
  
  @objc func dateDidChange(_ datePicker: UIDatePicker) {
    currentDateShown = datePicker.date
  }
  
  @objc func phaseWasTapped() {
    if phasePicker.frame.height == 0 {
      phasePicker.defaultValue = moonPhaseLabel.text?.capitalized
      expand(view: phasePicker, toHeight: datePickerHeight, toAlpha: phasePickerAlpha, animated: true)
      self.currentDateShown = self.currentDatePicked
      collapse(view: datePicker, animated: true)
    }
    else {
      retreiveNextPhase(phasePicker.selectedValue)
      collapse(view: phasePicker, animated: true)
    }
  }
}

// MARK: Utility Methods
private extension ViewController {
//  func runQueuedAnimations() {
//    let localQueue = queuedAnimations
//    queuedAnimations.removeAll()
//
//    guard localQueue.isEmpty == false else { return }
//
//    let animationBlocks = localQueue.map { $0.animation }
//    let completionBlocks = localQueue.map { $0.completion }
//    UIView.animate(withDuration: 0.2, animations: {
//      for animationBlock in animationBlocks {
//        animationBlock()
//      }
//    }) { completed in
//      for completionBlock in completionBlocks {
//        completionBlock(completed)
//      }
//      self.runQueuedAnimations()
//    }
//  }

  func expand(view: UIView,
              toHeight height: CGFloat,
              toAlpha alpha: CGFloat,
              animated: Bool,
              completion: ((Bool) -> Void)? = nil) {
    if animated {
      UIView.animate(withDuration: 0.2, delay: 0.0, options: [.transitionCurlDown, .beginFromCurrentState], animations: {
        view.alpha = alpha
        view.frame.size.height = height
      }) { completed in
        completion?(completed)
      }
    }
    else {
      view.alpha = alpha
      view.frame.size.height = height
      completion?(true)
    }
  }
  
  func collapse(view: UIView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
    if animated {
      UIView.animate(withDuration: 0.2, delay: 0.0, options: [.transitionCurlUp, .beginFromCurrentState], animations: {
        view.alpha = 0
        view.frame.size.height = 0
      }) { completed in
        completion?(completed)
      }
    }
    else {
      view.alpha = 0
      view.frame.size.height = 0
      completion?(true)
    }
  }

  func createHorizontalGradientLayer(with frame: CGRect) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = frame
    gradientLayer.colors = [UIColor.clear.cgColor,
                            UIColor.lightGray.cgColor,
                            UIColor.lightGray.cgColor,
                            UIColor.clear.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    gradientLayer.locations = [0, 0.2, 0.8, 1]
    
    return gradientLayer
  }
  
  func createVerticalGradientLayer(with frame: CGRect) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = frame
    gradientLayer.colors = [UIColor.black.cgColor,
                            UIColor.black.cgColor,
                            UIColor.clear.cgColor]
    gradientLayer.locations = [0, 0.5, 1]
    
    return gradientLayer
  }
  
  func format(date: Date, withTime: Bool = true, withDate: Bool = true) -> String {
    let formatter = DateFormatter()
    
    formatter.dateStyle = withDate ? .medium : .none
    formatter.timeStyle = withTime ? .short : .none
    formatter.locale = Locale.autoupdatingCurrent
    
    return formatter.string(from: date)
  }
  
  func selectedPhase() -> PhaseChoice {
    guard let text = moonPhaseLabel.text else { return .default }
    switch text.lowercased() {
    case "new moon":
      return .nextNew
    case "first quarter":
      return .nextQuarter
    case "full moon":
      return .nextFull
    case "last quarter":
      return .nextThreeQuarter
    default:
      return .default
    }
  }
  
  func showLoadingSpinners(_ shouldShow: Bool) {
    if shouldShow {
      moonPhaseLabel.isLoading = true
      dateView.isLoading = true
    }
    else {
      moonPhaseLabel.isLoading = false
      dateView.isLoading = false
    }
  }
}

// MARK: CLLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations)
    retrieveMoonValue(for: currentDatePicked, dateInPast: false)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}

