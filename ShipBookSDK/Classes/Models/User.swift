//
//  User.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 23/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import Foundation

public struct User {
  var userId: String
  var userName: String?
  var email: String?
  var phoneNumber: String?
  var additionalInfo: [String: String]?
}
  
extension User: Codable {
  enum CodingKeys: String, CodingKey
  {
    case userId
    case userName
    case email
    case phoneNumber
    case additionalInfo
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    userId = try container.decode(String.self, forKey: .userId)
    userName = try container.decodeIfPresent(String.self, forKey: .userName)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    additionalInfo = try container.decodeIfPresent(Dictionary<String, String>.self, forKey: .additionalInfo)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userId, forKey: .userId)
    try container.encodeIfPresent(userName, forKey: .userName)
    try container.encodeIfPresent(email, forKey: .email)
    try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
    try container.encodeIfPresent(additionalInfo, forKey: .additionalInfo)
  }
}

extension User: Equatable {}
public  func ==(lhs: User, rhs: User) -> Bool {
  return lhs.userId == rhs.userId &&
    lhs.userName == rhs.userName &&
    lhs.email == rhs.email //&&
    //lhs.additionalInfo == rhs.additionalInfo
}
