//
//  AppEvent.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 27/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import Foundation
import UIKit


class AppEvent: BaseEvent {
  enum State: String, Codable { // need so that the codable will return string
    case active
    case inactive
    case background
    
    init(state: UIApplicationState) {
      switch state {
      case .active:
        self = .active
      case .inactive:
        self = .inactive
      case .background:
        self = .background
      }
    }
  }
  
  enum Orientation: String, Codable { // need so that the codable will return string
    case unknown
    case portrait
    case portraitUpsideDown
    case landscapeRight
    case landscapeLeft
    
    init(orientation: UIInterfaceOrientation) {
      switch orientation {
      case .unknown:
        self = .unknown
      case .portrait:
        self = .portrait
      case .portraitUpsideDown:
        self = .portraitUpsideDown
      case .landscapeLeft:
        self = .landscapeLeft
      case .landscapeRight:
        self = .landscapeRight
      }
    }
  }
  
  var event: String
  var state: State
  var orientation: Orientation
  
  init(event: String, state: UIApplicationState, orientation: UIInterfaceOrientation) {
    self.event = event
    self.state = State(state: state)
    self.orientation = Orientation(orientation: orientation)
    super.init(type: "appEvent")
  }
  
  enum CodingKeys: String, CodingKey {
    case event
    case state
    case orientation
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.event = try container.decode(String.self, forKey: .event)
    self.state = try container.decode(State.self, forKey: .state)
    self.orientation = try container.decode(Orientation.self, forKey: .orientation)
    try super.init(from: decoder)
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(event, forKey: .event)
    try container.encode(state, forKey: .state)
    try container.encode(orientation, forKey: .orientation)
    try super.encode(to: encoder)
  }
}