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
    
    
    var userLeft : Bool = false
    var userRight : Bool = false
    
    var attackStart : CGPoint!
    var attack = false
    
    var fireball : SKSpriteNode!
    var fireballAtlas = SKTextureAtlas(named: "Fireball")
    var fireballArray = [SKTexture]()
    
    var tempNode : SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        
        floor = childNode(withName: "floor") as? SKSpriteNode
        user = childNode(withName: "user") as? SKSpriteNode
        
       
        self.view?.isMultipleTouchEnabled = true
        
        SetupNotifications()
        SetupWeaponType()
        SetupAnimations()
        SetupConstraints()
        SetupPhysicsBodies()
    }

    
    func SetupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.updateUserLeft), name: NSNotification.Name(rawValue: "0"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.updateUserRight), name: NSNotification.Name(rawValue: "1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.stopUser), name: NSNotification.Name("3"), object: nil)
    }
    
    func SetupWeaponType() {
        let fireballTexture = SKTexture(imageNamed: "1")
        fireball = SKSpriteNode(texture: fireballTexture, size: CGSize(width: user.size.height, height: user.size.height * 0.384))
    }
    
    func SetupAnimations() {
        for i in 1...fireballAtlas.textureNames.count {
            fireballArray.append(SKTexture(imageNamed: "\(i)"))
        }
    }
    
    func SetupConstraints() {
    
    }
    
    func SetupPhysicsBodies() {
        floor?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: floor.frame.width, height: floor.frame.height - floor.frame.height * 0.26))
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
        
        fireball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "1"), size: fireball.size)
        fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.pinned = false
        fireball.physicsBody?.allowsRotation = true
        fireball.physicsBody?.affectedByGravity = true
        fireball.physicsBody?.collisionBitMask = 1
        fireball.physicsBody?.categoryBitMask = 2
        fireball.physicsBody?.density = 30
        
        
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
     
    }
    
    func touchUp(atPoint pos : CGPoint) {
     
    }
    
    @objc func stopUser() {
        userRight = false
        userLeft = false
    }
    
    @objc func updateUserLeft() {
        userLeft = true
        user.texture = SKTexture(imageNamed: "mage")
        userRight = false
        runUser()
    }
    
    @objc func updateUserRight() {
        userRight = true
        user.texture = SKTexture(imageNamed: "mageRight")
        //user.xScale = -1
        userLeft = false
        runUser()
    }
    
    
    func Fire(dx : CGFloat, dy : CGFloat) {
        print("In Fire Function")
        if dx > 100 || dx < -100 || dy > 100 || dy < -100 {
            if let x = fireball {
                x.position = user.position
                tempNode = (x.copy() as! SKSpriteNode)
                tempNode?.physicsBody?.affectedByGravity = false
                tempNode?.name = "fireball"
                self.addChild(tempNode!)
                tempNode?.run(SKAction.fadeIn(withDuration: 0.1))
                tempNode.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
                tempNode.run(SKAction.repeatForever(SKAction.animate(with: fireballArray, timePerFrame: 0.2)))
                attack = false
            }
        }
        
    }
    
    
    func runUser() {
        //setup walkAnimation here
    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))
            let position = t.location(in: self)
            attackStart = position
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self))
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            let dx = attackStart.x - t.location(in: self).x
            let dy = attackStart.y - t.location(in: self).y
            Fire(dx: dx, dy: dy)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            
        }
    }
    
    func moveUser() {
        if userLeft {
            user.position.x -= 2.5
        } else if userRight {
            user.position.x -= -2.5
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveUser()
    }
}
