//
//  NetworkMockObjects.swift
//  Chowroulette
//
//  Created by Daniel Seitz on 7/29/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import Foundation
@testable import YAPI

class MockURLSession: URLSessionProtocol {
  var nextData: Data?
  var nextError: Error?
  private(set) var nextDataTask: MockURLSessionDataTask?
  var asyncAfter: DispatchTimeInterval?
  fileprivate(set) var lastURL: URL?
  
  func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
    self.lastURL = url
    let dataTask = MockURLSessionDataTask(asyncAfter: asyncAfter) {
      completionHandler(self.nextData, nil, self.nextError)
    }
    self.nextDataTask = dataTask
    return dataTask
  }
  
  func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
    self.lastURL = request.url
    let dataTask = MockURLSessionDataTask(asyncAfter: asyncAfter) {
      completionHandler(self.nextData, nil, self.nextError)
    }
    self.nextDataTask = dataTask
    return dataTask
  }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
  fileprivate(set) var resumeWasCalled = false
  fileprivate let asyncAfter: DispatchTimeInterval?
  fileprivate let completionHandler: () -> Void
  
  fileprivate init(asyncAfter: DispatchTimeInterval? = nil, completionHandler: @escaping () -> Void) {
    self.asyncAfter = asyncAfter
    self.completionHandler = completionHandler
  }
  
  func resume() {
    if let asyncAfter = asyncAfter {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + asyncAfter) { [weak self] in
        self?.completionHandler()
      }
    }
    else {
      completionHandler()
    }
    resumeWasCalled = true
  }
}
