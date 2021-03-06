//
//  AppenderTests.swift
//  ShipBookTests
//
//  Created by Elisha Sterngold on 08/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import XCTest
@testable import ShipBookSDK

class AppenderTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    let dir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    let dirURL = dir!.appendingPathComponent("shipbook")
    try? FileManager.default.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testPatternLayout() {
    var  config  =  Config()
    config["pattern"] = "$time $severityIcon $severity $tag $message [$file:$line] $isMainThread $queueLabel $threadId"
    let consoleAppender = ConsoleAppender(name: "console", config: config)
    let msg = "this is a test"
    let line = #line
    let severity = Severity.Debug
    let tag = "Tag"
    let message = Message(message: msg, severity:severity, tag: tag, function: #function, file: #file, line: line)
    let result = consoleAppender.toString(message: message)
    print(result)
    let expected = "\( message.time.toTimeFormat()) \(consoleAppender.color(severity: severity)) \( severity.name ) \(tag) \(msg) [\(#file):\(line)] true com.apple.main-thread \(Thread.threadId)"
    XCTAssertTrue(result.range(of: expected) != nil)
    
  }
  
  func testCloudAppender() {
    let cloudAppender = SBCloudAppender(name: "cloud", config: nil)
    try? FileManager.default.removeItem(at: cloudAppender.fileURL)
    let token = "testing"
    SessionManager.shared.token = token
    var logs1 = [BaseLog]()
    logs1.append(Message(message: "message1", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs1.append(Message(message: "message2", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs1.append(Message(message: "message3", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs1.append(Message(message: "message4", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs1.append(Message(message: "message5", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs1.append(Exception(name: "test"))
    
    for log in logs1 {
      cloudAppender.saveToFile(data: log)
    }
    
    cloudAppender.hasLog = false //doing like that it starts a new load
    SessionManager.shared.token = nil
    SessionManager.shared.login = Login(appId:"59f196837211df173c430c51", appKey:"5a4b2e7f82416460bd2afc1cdb002e743ac25ce9")
    var logs2 = [BaseLog]()
    logs2.append(Message(message: "message1", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs2.append(Message(message: "message2", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs2.append(Message(message: "message3", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs2.append(Message(message: "message4", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs2.append(Message(message: "message5", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs2.append(Message(message: "message6 \nnew line", severity: .Info, tag: "test", function: #function, file: #file, line: #line))
    logs2.append(Exception(name: "test"))
    
    for log in logs2 {
      cloudAppender.saveToFile(data: log)
    }

    var sessionsData: [SessionLogData]? = nil
    XCTAssertNoThrow (sessionsData = try cloudAppender.loadFromFile(url: cloudAppender.fileURL))
    XCTAssertEqual(sessionsData!.count, 2)
    var sessionLogData1 = sessionsData![0]
    XCTAssertNil(sessionLogData1.login)
    XCTAssertEqual(sessionLogData1.token, token)
    XCTAssertEqual(sessionLogData1.logs, logs1)
    var sessionLogData2 = sessionsData![1]
    XCTAssertNil(sessionLogData2.token)
    XCTAssertEqual(sessionLogData2.login, SessionManager.shared.login)
    XCTAssertEqual(sessionLogData2.logs, logs2)
    
    // checking the usage of temp file works
    try! FileManager.default.moveItem(at: cloudAppender.fileURL, to: cloudAppender.tempFileURL)
    let log = Message(message: "message6", severity: .Info, tag: "test", function: #function, file: #file, line: #line)
    cloudAppender.saveToFile(data: log)
    logs2.append(log)
    
    cloudAppender.concatTmpFile()
    sessionsData = nil
    XCTAssertNoThrow (sessionsData = try cloudAppender.loadFromFile(url: cloudAppender.fileURL))
    XCTAssertEqual(sessionsData!.count, 2)
    sessionLogData1 = sessionsData![0]
    XCTAssertNil(sessionLogData1.login)
    XCTAssertEqual(sessionLogData1.token, token)
    XCTAssertEqual(sessionLogData1.logs, logs1)
    sessionLogData2 = sessionsData![1]
    XCTAssertNil(sessionLogData2.token)
    XCTAssertEqual(sessionLogData2.login, SessionManager.shared.login)
    XCTAssertEqual(sessionLogData2.logs, logs2)
  }
}
