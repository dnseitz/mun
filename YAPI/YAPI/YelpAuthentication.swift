//
//  YelpAuthentication.swift
//  YAPI
//
//  Created by Daniel Seitz on 9/3/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation

internal enum AuthKeys {
  fileprivate static var _consumerKey: String?
  fileprivate static var _consumerSecret: String?
  fileprivate static var _token: String?
  fileprivate static var _tokenSecret: String?
  
  static var consumerKey: String? {
    get {
      return _consumerKey
    }
    set {
      guard _consumerKey == nil else {
        assert(false, "Only set the consumerKey once")
        return
      }
      _consumerKey = newValue
    }
  }
  static var consumerSecret: String? {
    get {
      return _consumerSecret
    }
    set {
      guard _consumerSecret == nil else {
        assert(false, "Only set the consumerSecret once")
        return
      }
      _consumerSecret = newValue
    }
  }
  static var token: String? {
    get {
      return _token
    }
    set {
      guard _token == nil else {
        assert(false, "Only set the token once")
        return
      }
      _token = newValue
    }
  }
  static var tokenSecret: String? {
    get {
      return _tokenSecret
    }
    set {
      guard _tokenSecret == nil else {
        assert(false, "Only set the tokenSecret once")
        return
      }
      _tokenSecret = newValue
    }
  }
  
  static var apiKey: String? {
    get {
      return _token
    }
    set {
      guard _token == nil else {
        assert(false, "Only set the apiKey once")
        return
      }
      _token = newValue
    }
  }
  
  static var areSet: Bool {
    return ((_consumerKey != nil) && (_consumerSecret != nil) && (_token != nil) && (_tokenSecret != nil))
  }
  
  static func clearAuthentication() {
    _consumerKey = nil
    _consumerSecret = nil
    _token = nil
    _tokenSecret = nil
  }
}
