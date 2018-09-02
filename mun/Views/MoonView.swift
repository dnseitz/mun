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
  private var destination: (waxing: Bool, controlX: CGFloat)?
//  private var animation: CABasicAnimation
  private var currentPath: UIBezierPath!
  private var nextPath: UIBezierPath!
//  private var path1: UIBezierPath
//  private var path2: UIBezierPath
  private var shapeLayer: CAShapeLayer?
  private let defaultDuration: CFTimeInterval = 0.2
  
  private let imageView: UIImageView
  
  private var maskLayer: CAShapeLayer? {
    return shapeLayer?.mask as? CAShapeLayer
//    return shapeLayer
  }
  
  public override init(frame: CGRect) {
    let halfWidth = frame.size.width / 2
    let halfHeight = frame.size.height / 2
    let circleControlPointOffset: CGFloat = 40
    
    imageView = UIImageView(frame: frame)
    
    initialControlX = 2 * halfWidth + circleControlPointOffset
    minControlX = -circleControlPointOffset
    currentControlX = initialControlX
//    animation = CABasicAnimation(keyPath: "path")
//    shapeLayer = CAShapeLayer()
    
    super.init(frame: frame)
    
    imageView.center = CGPoint(x: halfWidth, y: halfHeight)
    
    self.addSubview(imageView)
    imageView.image = #imageLiteral(resourceName: "moon-png-no-background-15")

//    let cp1y: CGFloat = -halfHeight
//    let cp2y: CGFloat = frame.size.height + halfHeight
//    let path1 = path(controlPoint: CGPoint(x: currentControlX, y: halfHeight))
    currentPath = path(controlPoint1: CGPoint(x: currentControlX, y: 0),
                     controlPoint2: CGPoint(x: currentControlX, y: frame.height),
                       waxing: false)
//    let path2 = path(controlPoint: CGPoint(x: -halfWidth, y: halfHeight))
//    let path2 = path(controlPoint1: CGPoint(x: -40, y: 0),
//                     controlPoint2: CGPoint(x: -40, y: frame.height))
    currentControlX -= 10
    nextPath = path(controlPoint1: CGPoint(x: currentControlX, y: 0),
                     controlPoint2: CGPoint(x: currentControlX, y: frame.height),
                    waxing: false)

    let shapeLayer = CAShapeLayer()
    self.shapeLayer = shapeLayer
    shapeLayer.path = circlePath(origin: CGPoint(x: 0, y: 0), radius: halfWidth).cgPath
    shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.9).cgColor
    shapeLayer.lineWidth = 0
    
    let maskLayer = CAShapeLayer()
    maskLayer.path = currentPath.cgPath
    maskLayer.fillColor = UIColor.black.cgColor
    
    shapeLayer.mask = maskLayer
    shapeLayer.frame = layer.bounds
    shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    layer.addSublayer(shapeLayer)
  }
  
  func setAngle(_ radians: CGFloat) {
    guard let shapeLayer = shapeLayer else { return }
    var transform = CATransform3DIdentity
    transform = CATransform3DRotate(transform, radians, 0, 0, -1)
    shapeLayer.transform = transform
  }
  
  func setPercentage(_ percentage: Double, animated: Bool) {
    let actualPercentage = max(min(percentage, 1), 0)
    
    let totalValues: Double = Double(initialControlX) - Double(minControlX)
    let value = actualPercentage * (2 * totalValues) + -totalValues
    
    let waxing = value > 0

    let correctedValue: Double
    if waxing == true {
      correctedValue = value + Double(minControlX)
    }
    else {
      let range = 0 - -totalValues
      let percent = (value - -totalValues) / range
      correctedValue = (percent * totalValues) + Double(minControlX)
    }

    if animated {
      animate(to: CGFloat(correctedValue), waxing: waxing)
    }
    else {
      currentControlX = CGFloat(correctedValue)
      maskLayer?.path = path(controlPoint1: CGPoint(x: currentControlX, y: 0),
                             controlPoint2: CGPoint(x: currentControlX, y: frame.height),
                             waxing: waxing).cgPath
    }
  }
  
  private func animate(to destinationControlX: CGFloat, waxing: Bool) {
    guard self.destination == nil else {
      // Just update the value and get out
      self.destination = (waxing: waxing, controlX: destinationControlX)
      return
    }
    self.destination = (waxing: waxing, controlX: destinationControlX)
    let animation = self.animation(from: currentPath, to: nextPath, duration: defaultDuration)
    
    maskLayer?.add(animation, forKey: "animatePath")
  }
  
  func path(controlPoint1: CGPoint, controlPoint2: CGPoint, waxing: Bool = true) -> UIBezierPath {
    let path = UIBezierPath()
    let height = frame.height + 2
    let halfWidth = frame.size.width / 2
    let halfHeight = height / 2
    path.move(to: CGPoint(x: halfWidth, y: 0))
    path.addCurve(to: CGPoint(x: halfWidth, y: height),
                  controlPoint1: controlPoint1,
                  controlPoint2: controlPoint2)
    path.addArc(withCenter: CGPoint(x: halfWidth, y: halfHeight),
                radius: halfHeight,
                startAngle: CGFloat(90).toRadians(),
                endAngle: CGFloat(270).toRadians(),
                clockwise: waxing)
    
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

private var count: Int = 0
private var didSwitch: Bool = false
private var waxing: Bool = false

extension MoonView: CAAnimationDelegate {
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    print("Animation completed")
    guard flag else {
      return assertionFailure("Animation failed to finish")
    }
    let shouldSwitch = currentControlX < minControlX
    if shouldSwitch == true {
      waxing = !waxing
      
      currentControlX = initialControlX
      currentPath = path(controlPoint1: CGPoint(x: currentControlX, y: 0),
                         controlPoint2: CGPoint(x: currentControlX, y: frame.height),
                         waxing: waxing)
    }
    else {
      currentPath = nextPath
    }
    if let destination = destination {
      if currentControlX <= destination.controlX && waxing == destination.waxing {
        self.destination = nil
        maskLayer?.path = currentPath.cgPath
        maskLayer?.removeAllAnimations()
        return
      }
    }
    currentControlX -= 10
    if let destination = destination {
      if currentControlX < destination.controlX && waxing == destination.waxing {
        currentControlX = destination.controlX
      }
    }
    nextPath = path(controlPoint1: CGPoint(x: currentControlX, y: 0),
                    controlPoint2: CGPoint(x: currentControlX, y: frame.height),
                    waxing: waxing)
    maskLayer?.path = currentPath.cgPath
    
    let nextAnimation = animation(from: currentPath, to: nextPath, duration: defaultDuration, timingBehavior: .linear)

    maskLayer?.removeAllAnimations()
    maskLayer?.add(nextAnimation, forKey: "animatePath")
    
    count += 1
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
