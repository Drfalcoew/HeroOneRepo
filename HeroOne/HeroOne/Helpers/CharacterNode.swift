//
//  CharacterNode.swift
//  HeroOne
//
//  Created by Drew Foster on 10/14/18.
//  Copyright © 2018 Drew Foster. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit
import GameplayKit

class CharacterNode: SKSpriteNode {
   
    var left = false
    var right = false
    
    var hSpeed : CGFloat = 0.0
    
    var walkSpeed : CGFloat = 2.0
    
    
    var stateMachine : GKStateMachine?
    
    func SetupStateMachine() {
        let normalState = NormalState(with: self)
        stateMachine = GKStateMachine(states: [normalState])
        stateMachine?.enter(NormalState.self)
    }
}
