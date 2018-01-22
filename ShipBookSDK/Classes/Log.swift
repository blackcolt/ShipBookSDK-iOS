//
//  Log.swift
//  iOSSdk
//
//  Created by Elisha Sterngold on 25/10/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import Foundation

fileprivate let appName = Bundle.main.infoDictionary?[kCFBundleExecutableKey as String] as? String ?? ""

public class Log {
  // static part of the class
  public static func e(_ msg:String,tag:String? = nil,function: String = #function, file: String = #file, line: Int = #line){
    Log.message(msg: msg, severity: .Error, tag: tag, function: function,file: file,line: line)
  }
  
  public static func w(_ msg:String,tag:String? = nil,function: String = #function, file: String = #file, line: Int = #line){
    Log.message(msg: msg, severity: .Warning, tag: tag, function: function,file: file,line: line)
  }
  
  public static func i(_ msg:String,tag:String? = nil,function: String = #function, file: String = #file, line: Int = #line){
    Log.message(msg: msg, severity: .Info, tag: tag, function: function,file: file,line: line)
  }
  
  public static func v(_ msg:String,tag:String? = nil,function: String = #function, file: String = #file, line: Int = #line){
    Log.message(msg: msg, severity: .Verbose, tag: tag, function: function,file: file,line: line)
  }
  
  public static func d(_ msg:String,tag:String? = nil,function: String = #function, file: String = #file, line: Int = #line){
    Log.message(msg: msg, severity: .Debug, tag: tag, function: function,file: file,line: line)
  }
  
  public static func message(msg:String,severity:Severity,tag:String? = nil,function: String = #function, file: String = #file, line: Int = #line){
    let logClass = Log(tag, file: file)
    logClass.message(msg: msg, severity:severity, function: function, file: file, line: line)
  }
  
  // None  static part of class
  var tag: String
  var level: Severity
  
  init(_ tag: String?, file: String = #file) {
    var tempTag = tag
    if tempTag == nil  { // for the case that there is no tag
      let lastPath = (file as NSString).lastPathComponent
      tempTag = lastPath.components(separatedBy: ".swift")[0]
    }
    
    self.tag = "\(appName).\(tempTag!)"
    level = LogManager.shared.getLevel(self.tag)
    addNotification()
  }
  
  init(_ klass: AnyClass) {
    self.tag = String(reflecting: klass)
    self.level = LogManager.shared.getLevel(tag)
    addNotification()
  }
  
  private func addNotification () {
    weak var _self = self
    NotificationCenter.default.addObserver(
      forName: NotificationName.ConfigChange,
      object: nil,
      queue: nil) { (notification) in
        if let _self = _self {
          _self.level = LogManager.shared.getLevel(self.tag)
        }
    }
  }

  public func e(_ msg:String, function: String = #function, file: String = #file, line: Int = #line){
    message(msg: msg, severity: .Error, function: function,file: file,line: line)
  }
  
  public  func w(_ msg:String, function: String = #function, file: String = #file, line: Int = #line){
    message(msg: msg, severity: .Warning, function: function,file: file,line: line)
  }
  
  public func i(_ msg:String, function: String = #function, file: String = #file, line: Int = #line){
    message(msg: msg, severity: .Info, function: function,file: file,line: line)
  }
  
  public func v(_ msg:String, function: String = #function, file: String = #file, line: Int = #line){
    message(msg: msg, severity: .Verbose, function: function,file: file,line: line)
  }
  
  public func d(_ msg:String, function: String = #function, file: String = #file, line: Int = #line){
    message(msg: msg, severity: .Debug, function: function,file: file,line: line)
  }
  
  public func isEnabled(_ severity: Severity) -> Bool {
    return severity.rawValue <= level.rawValue
  }
  
  public func message(msg:String, severity:Severity, function: String = #function, file: String = #file, line: Int = #line) {
    if (severity.rawValue > level.rawValue) { return }
    let messageObj = Message(message: msg, severity:severity, tag: self.tag, function: function, file: file, line: line)
    LogManager.shared.push(log: messageObj)
  }
}