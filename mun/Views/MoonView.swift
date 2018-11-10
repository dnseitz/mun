//
//  MoonView.swift
//  mun
//
//  Created by Daniel Seitz on 9/1/18.
//  Copyright © 2018 dboy. All rights reserved.
//

import Foundation
import UIKit

public class MoonView: UIView {
  
  private let initialControlX: CGFloat
  private let minControlX: CGFloat
  private var currentControlX: CGFloat
  private var destination: (waning: Bool, controlX: CGFloat)?
  private var currentPath: UIBezierPath!
  private var nextPath: UIBezierPath!
  private var shapeLayer: CAShapeLayer?
  private let defaultDuration: CFTimeInterval = 0.125
  private let yCurveOffset: CGFloat = 5
  
  private let imageView: UIImageView
  
  private var forward: Bool = true
  private var waning: Bool = false
  
  private var maskLayer: CAShapeLayer? {
    return shapeLayer?.mask as? CAShapeLayer
  }
  
  private var gradientLayer: CAGradientLayer?
  
  public override init(frame: CGRect) {
    let halfWidth = frame.size.width / 2
    let halfHeight = frame.size.height / 2
    let circleControlPointOffset: CGFloat = 43
//    let circleControlPointOffset: CGFloat = 75

    
    imageView = UIImageView(frame: frame)
    
    initialControlX = 2 * halfWidth + circleControlPointOffset
    minControlX = -circleControlPointOffset
    currentControlX = minControlX
    
    super.init(frame: frame)
    
    imageView.center = CGPoint(x: halfWidth, y: halfHeight)
    
    self.addSubview(imageView)
    imageView.image = #imageLiteral(resourceName: "moon-png-no-background-15")

    currentPath = path(controlPoint1: CGPoint(x: currentControlX, y: yCurveOffset),
                     controlPoint2: CGPoint(x: currentControlX, y: frame.height - yCurveOffset),
                       waning: false)
    currentControlX -= 10
    nextPath = path(controlPoint1: CGPoint(x: currentControlX, y: yCurveOffset),
                     controlPoint2: CGPoint(x: currentControlX, y: frame.height - yCurveOffset),
                    waning: false)

    let shapeLayer = CAShapeLayer()
    self.shapeLayer = shapeLayer
    shapeLayer.path = circlePath(origin: CGPoint(x: 0, y: 0), radius: halfWidth).cgPath
    shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.9).cgColor
    shapeLayer.lineWidth = 0
    
    let maskLayer = CAShapeLayer()
    maskLayer.path = currentPath.cgPath
    maskLayer.fillColor = UIColor.black.cgColor
    maskLayer.opacity = 0.85
    
    maskLayer.shadowRadius = 4
    maskLayer.shadowColor = UIColor.black.cgColor
    maskLayer.shadowOpacity = 1

    shapeLayer.mask = maskLayer
    shapeLayer.frame = layer.bounds
    shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    layer.addSublayer(shapeLayer)
  }

  private var currentAngleInRadians: CGFloat = 0.0
  func setAngle(_ radians: CGFloat, animated: Bool) {
    guard let shapeLayer = shapeLayer else { return }
    // Because when I built the view I accidentally did it backwards :-)
    let radians = radians + CGFloat(Double.pi)
    if animated {
      UIView.animate(withDuration: 0.5) {
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, radians, 0, 0, -1)
        shapeLayer.transform = transform
      }
    }
    else {
      var transform = CATransform3DIdentity
      transform = CATransform3DRotate(transform, radians, 0, 0, -1)
      shapeLayer.transform = transform
    }
    
//    if animated {
//      let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
//      rotationAnimation.fromValue = currentAngleInRadians
//      rotationAnimation.duration = 0.5
//      shapeLayer.add(rotationAnimation, forKey: "animateRotation")
//    }
    
    currentAngleInRadians = radians
  }
  
  func setPercentage(_ percentage: Double, animated: Bool, forward: Bool, shouldForceRotation: Bool = false) {
    let actualPercentage = max(min(percentage, 1), 0)
    
    let totalValues: Double = Double(initialControlX) - Double(minControlX)
    let value = actualPercentage * (2 * totalValues) + -totalValues
    
    let waning = value > 0

    let correctedValue: Double
    if waning == true {
      correctedValue = value + Double(minControlX)
    }
    else {
      let range = 0 - -totalValues
      let percent = (value - -totalValues) / range
      correctedValue = (percent * totalValues) + Double(minControlX)
    }

    if animated {
      forcedRotation = shouldForceRotation
      animate(to: CGFloat(correctedValue), waning: waning, forward: forward)
    }
    else {
      currentControlX = CGFloat(correctedValue)
      maskLayer?.path = path(controlPoint1: CGPoint(x: currentControlX, y: yCurveOffset),
                             controlPoint2: CGPoint(x: currentControlX, y: frame.height - yCurveOffset),
                             waning: waning).cgPath
    }
  }
  
  private func animate(to destinationControlX: CGFloat, waning: Bool, forward: Bool) {
    self.forward = forward
    guard self.destination == nil else {
      // Just update the value and get out
      self.destination = (waning: waning, controlX: destinationControlX)
      return
    }
    self.destination = (waning: waning, controlX: destinationControlX)
    // There's a weird pause after the first animation that is not repeated in subsequent animations, this just kicks off the other animations by animating in place
    let nextControlX: CGFloat = currentControlX
    nextPath = path(controlPoint1: CGPoint(x: nextControlX, y: yCurveOffset),
                    controlPoint2: CGPoint(x: nextControlX, y: frame.height - yCurveOffset),
                    // This is different on purpose so we can animate to the
                    // correct next path in case the waning switch changes in the animation
                    waning: self.waning)
    let animation = self.animation(from: currentPath, to: nextPath, duration: 0, timingBehavior: .linear)
    
    maskLayer?.add(animation, forKey: "animatePath")
  }
  
  func path(controlPoint1: CGPoint, controlPoint2: CGPoint, waning: Bool = true) -> UIBezierPath {
    let path = UIBezierPath()
    let height = frame.height + 2
    let halfWidth = frame.size.width / 2
    let halfHeight = height / 2
    path.move(to: CGPoint(x: halfWidth, y: 0))
    path.addCurve(to: CGPoint(x: halfWidth, y: height),
                  controlPoint1: controlPoint1,
                  controlPoint2: controlPoint2)
    path.addArc(withCenter: CGPoint(x: halfWidth, y: halfHeight),
                radius: halfHeight + halfHeight / 2,
                startAngle: CGFloat(90).toRadians(),
                endAngle: CGFloat(270).toRadians(),
                clockwise: waning)
    path.close()
    
    return path
  }
  
  func circlePath(origin: CGPoint, radius: CGFloat) -> UIBezierPath {
    let path = UIBezierPath(ovalIn:
      CGRect(
        x: origin.x,
        y: origin.y,
        width: radius * 2,
        height: radius * 2
      )
    )
    
    return path
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private var needsFullRotation: Bool = false
private var forcedRotation: Bool = false

extension MoonView: CAAnimationDelegate {
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    let shouldSwitch = forward ? currentControlX < minControlX : currentControlX > initialControlX
    if shouldSwitch == true {
      waning = !waning
      forcedRotation = false
      
      currentControlX = forward ? initialControlX : minControlX
      currentPath = path(controlPoint1: CGPoint(x: currentControlX, y: yCurveOffset),
                         controlPoint2: CGPoint(x: currentControlX, y: frame.height - yCurveOffset),
                         waning: waning)
      
      let width = waning ? 8 : -8
      maskLayer?.shadowOffset = CGSize(width: width, height: 0)
    }
    else {
      currentPath = nextPath
    }

    if let destination = destination {
      needsFullRotation = forward ?
        currentControlX < destination.controlX :
        currentControlX > destination.controlX
      let metDestination = currentControlX == destination.controlX
      if metDestination && waning == destination.waning {
        self.destination = nil
        maskLayer?.path = currentPath.cgPath
        maskLayer?.removeAnimation(forKey: "animatePath")
        return
      }
    }
    
    currentControlX -= forward ? 10 : -10
    if let destination = destination {
      let passedDestination = forward ?
        currentControlX < destination.controlX :
        currentControlX > destination.controlX

      if passedDestination && waning == destination.waning && needsFullRotation == false && forcedRotation == false {
        currentControlX = destination.controlX
      }
    }
    nextPath = path(controlPoint1: CGPoint(x: currentControlX, y: yCurveOffset),
                    controlPoint2: CGPoint(x: currentControlX, y: frame.height - yCurveOffset),
                    waning: waning)
    maskLayer?.path = currentPath.cgPath
    
    let nextAnimation = animation(from: currentPath, to: nextPath, duration: defaultDuration, timingBehavior: .linear)

    maskLayer?.removeAnimation(forKey: "animatePath")
    maskLayer?.add(nextAnimation, forKey: "animatePath")
  }
  
  private enum TimingBehavior {
    case easeIn
    case linear
    
    var timingFunction: CAMediaTimingFunction {
      switch self {
      case .easeIn:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      case .linear:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
      }
    }
  }
  
  private func animation(from startCurve: UIBezierPath, to endCurve: UIBezierPath, duration: CFTimeInterval, timingBehavior: TimingBehavior? = nil) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = currentPath.cgPath
    animation.toValue = nextPath.cgPath
    
    animation.delegate = self
    
    animation.timingFunction = timingBehavior?.timingFunction
    
    animation.duration = duration
    animation.fillMode = kCAFillModeForwards
    animation.isRemovedOnCompletion = false
    
    return animation
  }
}

extension CGFloat {
  func toRadians() -> CGFloat {
    return self * CGFloat(Double.pi) / 180.0
  }
}
