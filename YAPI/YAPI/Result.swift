//
//  Result.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/11/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

public enum Result<T, E> {
  case ok(T)
  case err(E)
}

public extension Result {
  func isOk() -> Bool {
    switch self {
    case .ok(_): return true
    case .err(_): return false
    }
  }
  
  func isErr() -> Bool {
    return !self.isOk()
  }
  
  func intoOk() -> T? {
    guard case .ok(let val) = self else {
      return nil
    }
    return val
  }
  
  func intoErr() -> E? {
    guard case .err(let error) = self else {
      return nil
    }
    return error
  }
  
  func map<U>(_ op: (T) -> U) -> Result<U, E> {
    switch self {
    case .ok(let val): return .ok(op(val))
    case .err(let error): return .err(error)
    }
  }
  
  func mapErr<F>(_ op: (E) -> F) -> Result<T, F> {
    switch self {
    case .ok(let val): return .ok(val)
    case .err(let error): return .err(op(error))
    }
  }
  
  func flatMap<U>(_ op: (T) -> Result<U, E>) -> Result<U, E> {
    switch self {
    case .ok(let val): return op(val)
    case .err(let error): return .err(error)
    }
  }
  
  func flatMapErr<F>(_ op: (E) -> Result<T, F>) -> Result<T, F> {
    switch self {
    case .ok(let val): return .ok(val)
    case .err(let error): return op(error)
    }
  }
  
  func and<U>(_ res: Result<U, E>) -> Result<U, E> {
    guard case .err(let error) = self else {
      return res
    }
    return .err(error)
  }
  
  func andThen<U>(_ op: (T) -> Result<U, E>) -> Result<U, E> {
    switch self {
    case .ok(let val): return op(val)
    case .err(let error): return .err(error)
    }
  }
  
  func or<F>(_ res: Result<T, F>) -> Result<T, F> {
    guard case .ok(let val) = self else {
      return res
    }
    return .ok(val)
  }
  
  func orElse<F>(_ op: (E) -> Result<T, F>) -> Result<T, F> {
    switch self {
    case .ok(let val): return .ok(val)
    case .err(let error): return op(error)
    }
  }
  
  func unwrap(or def: T) -> T {
    guard case .ok(let val) = self else {
      return def
    }
    return val
  }
  
  func unwrap(orElse handler: (E) -> T) -> T {
    switch self {
    case .ok(let val): return val
    case .err(let error): return handler(error)
    }
  }
  
  func unwrap() -> T {
    switch self {
    case .ok(let val): return val
    case .err(let error): fatalError("Tried to unwrap result with error: \(error)")
    }
  }
  
  func expect(message: String) -> T {
    guard case .ok(let val) = self else {
      fatalError(message)
    }
    return val
  }
  
  func unwrapErr() -> E {
    switch self {
    case .ok(let val): fatalError("Tried to unwrap result with value: \(val)")
    case .err(let error): return error
    }
  }
}

