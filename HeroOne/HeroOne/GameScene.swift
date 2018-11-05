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
    static let user : UInt32 = 0x1 << 0
    static let floor : UInt32 = 0x1 << 1
    static let fire : UInt32 = 0x1 << 2
    static let enemy : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var user : SKSpriteNode!
    var floor : SKSpriteNode!
    
    
    var mtn0 : SKSpriteNode!
    var mtn1 : SKSpriteNode!
    var fog : SKSpriteNode!
    var sky : SKSpriteNode!
    var sun : SKSpriteNode!
    
    var one : SKShapeNode!
    var two : SKShapeNode!
    
    var userLeft : Bool = false
    var userRight : Bool = false
    
    var attackStart : CGPoint!
    var attack = false
    
    var fireball : SKSpriteNode!
    var fireballAtlas = SKTextureAtlas(named: "Fireball")
    var fireballArray = [SKTexture]()
    
    var tempNode : SKSpriteNode!
    
    var cam: SKCameraNode?
    
    override func didMove(to view: SKView) {
        
        floor = childNode(withName: "floor") as? SKSpriteNode
        user = childNode(withName: "user") as? SKSpriteNode
        mtn0 = childNode(withName: "mountains_1") as? SKSpriteNode
        mtn1 = childNode(withName: "mountains_0") as? SKSpriteNode
        sky = childNode(withName: "sky") as? SKSpriteNode
        sun = childNode(withName: "sun") as? SKSpriteNode
        fog = childNode(withName: "fog") as? SKSpriteNode
        
        
        
        one = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        two = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        
        one.fillColor = .red
        two.fillColor = .red
        
        one.position = CGPoint(x: scene!.frame.width / -4, y: scene!.frame.height / 4)
        two.position = CGPoint(x: scene!.frame.width / 4, y: scene!.frame.height / 4)
        
        
        
        
        self.addChild(one)
        self.addChild(two)
        
        self.physicsWorld.contactDelegate = self

        self.view?.isMultipleTouchEnabled = true
        
        cam = SKCameraNode()
        self.addChild(cam!)
        camera = cam
        
        
        
        SetupStart()
        SetupBackground()
        UpdateCamera()
        SetupNotifications()
        SetupWeaponType()
        SetupAnimations()
        SetupConstraints()
        SetupPhysicsBodies()
    }

    
    func SetupStart() {
        let sunTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sunAnimation), userInfo: nil, repeats: false)
        
        
    }
    
    
    @objc func sunAnimation() {
        print("IN SUN ANIMATION FUNC")
        
        sun.run(SKAction.move(by: CGVector(dx: 0, dy: (view?.frame.height)! / -4 * 3), duration: 5.0), withKey: "sun")
    }
    
    func SetupBackground() {
        fog.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: 500, y: 0, duration: 5.0), SKAction.moveBy(x: -500, y: 0, duration: 5.0)])), withKey: "fog")
    }
    
    func UpdateCamera() {
        if ((user.position.x < one.position.x) && (userLeft == true)) {
            sky?.position.x -= 3.5
            sun?.position.x -= 3.3
            mtn0?.position.x -= 3.3
            mtn1?.position.x -= 3.4
            fog?.position.x -= 3.4
            cam?.position.x -= 3.5
            one.position.x -= 3.5
            two.position.x -= 3.5
            one.fillColor = .green
            
        } else if ((user.position.x > two.position.x) && (userRight == true)) {
            cam?.position.x += 3.5
            sky.position.x += 3.5
            mtn0?.position.x += 3.3
            sun?.position.x += 3.3
            mtn1?.position.x += 3.4
            two.position.x += 3.5
            one.position.x += 3.5
            fog?.position.x += 3.4
            two.fillColor = .green
            
        } else {
            one.fillColor = .red
            two.fillColor = .red
        }
    }
    
    func SetupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.updateUserLeft), name: NSNotification.Name(rawValue: "0"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.updateUserRight), name: NSNotification.Name(rawValue: "1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.stopUser), name: NSNotification.Name("3"), object: nil)
    }
    
    func SetupWeaponType() {
        let fireballTexture = SKTexture(imageNamed: "1")
        fireball = SKSpriteNode(texture: fireballTexture, size: CGSize(width: user.size.height, height: user.size.height * 0.54))
    }
    
    func SetupAnimations() {
        for i in 1...fireballAtlas.textureNames.count {
            fireballArray.append(SKTexture(imageNamed: "\(i)"))
        }
    }
    
    func SetupConstraints() {
    
    }
    
    func SetupPhysicsBodies() {
        floor.physicsBody?.isDynamic = true
        floor.physicsBody?.pinned = true
        floor.physicsBody?.allowsRotation = false
        floor.physicsBody?.collisionBitMask = BitMasks.user
        floor.physicsBody?.categoryBitMask = BitMasks.floor
        floor.physicsBody?.contactTestBitMask = BitMasks.fire
        
        user.physicsBody = SKPhysicsBody(rectangleOf: user.size)
        user.physicsBody?.isDynamic = true
        user.physicsBody?.pinned = false
        user.physicsBody?.allowsRotation = false
        user.physicsBody?.affectedByGravity = true
        user.physicsBody?.collisionBitMask = BitMasks.floor
        user.physicsBody?.categoryBitMask = BitMasks.user
        
        fireball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "1"), size: fireball.size)
        fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.pinned = false
        fireball.physicsBody?.allowsRotation = true
        fireball.physicsBody?.affectedByGravity = true
        fireball.physicsBody?.collisionBitMask = BitMasks.enemy
        fireball.physicsBody?.categoryBitMask = BitMasks.fire
        fireball.physicsBody?.contactTestBitMask = BitMasks.enemy | BitMasks.floor
        fireball.physicsBody?.density = 2.4
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        var a: SKSpriteNode? = nil
        var b: SKSpriteNode? = nil
        //var x : Int
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == BitMasks.floor && secondBody.categoryBitMask == BitMasks.fire {
            a = firstBody.node as! SKSpriteNode?
            b = secondBody.node as! SKSpriteNode?
            
            b?.run(SKAction.fadeOut(withDuration: 0.1), completion: {
                b?.removeFromParent()
            })
            
            
        }
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
        
        var newX = dx
        var newY = dy
        let maxPower : CGFloat = 350
        
        if dx > 100 || dx < -100 || dy > 100 || dy < -100 {
            if newX > maxPower {
                newX = maxPower
            } else if newX < -maxPower {
                newX = -maxPower
            }
            if newY > maxPower {
                newY = maxPower
            }
            if let x = fireball {
                x.position = user.position
                tempNode = (x.copy() as! SKSpriteNode)
                tempNode?.physicsBody?.affectedByGravity = true
                tempNode?.name = "fireball"
                self.addChild(tempNode!)
                tempNode?.run(SKAction.fadeIn(withDuration: 0.25))
                
                if dx > 0 {
                    tempNode.physicsBody?.applyAngularImpulse(dy / -20000)
                } else {
                    
                    tempNode.xScale = -1
                    tempNode.physicsBody?.applyAngularImpulse(dy / 20000)
                }
                tempNode.physicsBody?.applyImpulse(CGVector(dx: newX, dy: newY))
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
            //Flipping user whether aim is facing left or right
            let position = t.location(in: self)
            if position.x > attackStart.x {
                user.texture = SKTexture(imageNamed: "mage")

            } else {
                user.texture = SKTexture(imageNamed: "mageRight")

            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            let dx = attackStart.x - t.location(in: self).x
            let dy = attackStart.y - t.location(in: self).y
            Fire(dx: dx, dy: dy)
            //If we made variable to track aimDirection, it would remove the large chance of unnecessary texture overrides
            if userRight == true {
                updateUserRight()
            } else if userLeft == true {
                updateUserLeft()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            
        }
    }
    
    func moveUser() {
        if userLeft {
            user.position.x -= 3.5
        } else if userRight {
            user.position.x -= -3.5
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveUser()
        UpdateCamera()
    }
}
