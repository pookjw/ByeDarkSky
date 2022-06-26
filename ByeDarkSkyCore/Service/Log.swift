//
//  Log.swift
//  ByeDarkSkyCore
//
//  Created by Jinwoo Kim on 6/26/22.
//

import Foundation
import OSLog

public let log: Log = .shared

final public class Log {
    fileprivate static let shared: Log = .init()
    private let logger: Logger = .init()
    
    public func notice(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.notice("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    public func debug(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.debug("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    public func trace(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.trace("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    public func info(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.info("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    public func error(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
#if DEBUG
        fatalError("\(self.string(message: message, file: file, line: line, function: function))")
#else
        logger.error("\(self.string(message: message, file: file, line: line, function: function))")
#endif
    }
    
    public func warning(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.warning("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    public func fault(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.fault("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    public func critical(_ message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        logger.critical("\(self.string(message: message, file: file, line: line, function: function))")
    }
    
    private func string(message: Any, file: String, line: Int, function: String) -> String {
        return "\(file):\(line):\(function) - \(String(describing: message))"
    }
}
