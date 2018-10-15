//
//  GameScene.swift
//  HeroOne
//
//  Created by Drew Foster on 10/11/18.
//  Copyright © 2018 Drew Foster. All rights reserved.
//

import SpriteKit
import GameplayKit



struct BitMasks {
    
}

class GameScene: SKScene {
    
    var user : SKSpriteNode!
    var floor : SKSpriteNode!
    var userSize : CGSize = CGSize(width: 55, height: 120)
    
    var leftBtn : SKSpriteNode!
    var rightBtn : SKSpriteNode!
    var upBtn : SKSpriteNode!
    
    var userLeft : Bool = false
    var userRight : Bool = false
    
    override func didMove(to view: SKView) {
        
        floor = childNode(withName: "floor") as? SKSpriteNode
        user = childNode(withName: "user") as? SKSpriteNode
        leftBtn = childNode(withName: "left") as? SKSpriteNode
        rightBtn = childNode(withName: "right") as? SKSpriteNode
        upBtn = childNode(withName: "up") as? SKSpriteNode
        
        SetupControls()
        SetupConstraints()
        SetupPhysicsBodies()
    }

    func SetupControls() {
      
    }
    
    func SetupConstraints() {
    
    }
    
    func SetupPhysicsBodies() {
        floor?.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = true
        floor.physicsBody?.pinned = true
        floor.physicsBody?.collisionBitMask = 0
        floor.physicsBody?.categoryBitMask = 1
        
        user.physicsBody = SKPhysicsBody(rectangleOf: user.size)
        user.physicsBody?.isDynamic = true
        user.physicsBody?.pinned = false
        user.physicsBody?.allowsRotation = false
        user.physicsBody?.affectedByGravity = true
        user.physicsBody?.collisionBitMask = 1
        user.physicsBody?.categoryBitMask = 0
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
     
    }
    
    func touchUp(atPoint pos : CGPoint) {
     
    }
    
    func updateUser(direction: String) {
        if direction == "left" {
            userLeft = true
            user.texture = SKTexture(imageNamed: "mage")
            user.size = userSize
            userRight = false
            runUser()
            print(user.size)
        }
        else if direction == "right" {
            userRight = true
            user.texture = SKTexture(imageNamed: "mageRight")
            //user.xScale = -1
            user.size = userSize
            userLeft = false
            runUser()
            print(user.size)
        }
    }
    
    
    func runUser() {
        //setup walkAnimation here
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) 
            let position = t.location(in: self)
            let touchedNode = self.atPoint(position)
            if let name = touchedNode.name {
                if name == "right" {
                    updateUser(direction: "right")
                } else if name == "left" {
                    updateUser(direction: "left")
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            cancelMovements()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            cancelMovements()
            
        }
    }
    
    
    func cancelMovements() {
        userLeft = false
        userRight = false
    }
    
    func moveUser() {
        if userLeft {
            user.position.x -= 2.0
        } else if userRight {
            user.position.x -= -2.0
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveUser()
    }
}
