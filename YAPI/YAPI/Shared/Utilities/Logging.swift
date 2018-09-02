//
//  Logging.swift
//  YAPI
//
//  Created by Daniel Seitz on 11/15/17.
//  Copyright © 2017 Daniel Seitz. All rights reserved.
//

import Foundation

private var systemLoggers: [Logger] = [ConsoleLogger()]

public func log(_ severity: LoggingSeverity, for domain: LoggingDomain = .general, message: String) {
  guard domain.shouldLog else { return }

  for logger in systemLoggers {
    logger.log(severity, for: domain, message)
  }
}

public func add(logger: Logger) {
  systemLoggers.append(logger)
}

public protocol Logger {
  func log( _ severity: LoggingSeverity, for domain: LoggingDomain, _ message: String)
}

public enum LoggingSeverity {
  case success
  case info
  case warning
  case error
}

public enum LoggingDomain {
  case general
  case network
  case imageLoading
  case caching
  
  private var envKey: String {
    switch self {
    case .general:
      return "LOG_GENERAL"
    case .network:
      return "LOG_NETWORK"
    case .imageLoading:
      return "LOG_IMAGES"
    case .caching:
      return "LOG_CACHE"
    }
  }
  
  fileprivate var shouldLog: Bool {
    return ProcessInfo.processInfo.environment[self.envKey] != nil
  }
}

extension LoggingSeverity: CustomStringConvertible {
  public var description: String {
    switch self {
    case .success: return "SUCCESS"
    case .info: return "INFO"
    case .warning: return "WARNING"
    case .error: return "ERROR"
    }
  }
}

struct ConsoleLogger: Logger {
  func log(_ severity: LoggingSeverity, for domain: LoggingDomain, _ message: String) {
    print("\n[\(severity.description)]: \(message)\n")
  }
}
