//
//  GameScene.swift
//  HeroOne
//
//  Created by Drew Foster on 10/11/18.
//  Copyright © 2018 Drew Foster. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation



struct BitMasks {
    static let user : UInt32 = 0x1 << 0
    static let floor : UInt32 = 0x1 << 1
    static let enemy : UInt32 = 0x1 << 2
    static let fire : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var user : SKSpriteNode!
    var floor : SKSpriteNode!
    var goblin : SKSpriteNode!
    
    var mtn0 : SKSpriteNode!
    var mtn1 : SKSpriteNode!
    var fog : SKSpriteNode!
    var fog1 : SKSpriteNode!
    var sky : SKSpriteNode!
    var sun : SKSpriteNode!
    
    
    var one : SKSpriteNode!
    var two : SKSpriteNode!
    
    var userLeft : Bool = false
    var userRight : Bool = false
    var jump : Bool = false
    
    var attackStart : CGPoint!
    var attack = false
    
    var fireball : SKSpriteNode!
    var fireballAtlas = SKTextureAtlas(named: "Fireball")
    var fireballArray = [SKTexture]()
    
    var userAtlas = SKTextureAtlas(named: "mageWalk")
    var userArray = [SKTexture]()
    
    var tempNode : SKSpriteNode!
    
    var cam: SKCameraNode?
    
    lazy var backgroundMusic : AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "bgMusic", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            print("Playing song")
            return player
        } catch {
            print("Error")
            return nil
        }
    }()
    
    
    
    override func didMove(to view: SKView) {
        
        user = childNode(withName: "user") as? SKSpriteNode
        mtn0 = childNode(withName: "mountains_1") as? SKSpriteNode
        mtn1 = childNode(withName: "mountains_0") as? SKSpriteNode
        sky = childNode(withName: "sky") as? SKSpriteNode
        sun = childNode(withName: "sun") as? SKSpriteNode
        fog = childNode(withName: "fog") as? SKSpriteNode
        fog1 = childNode(withName: "fog1") as? SKSpriteNode
        goblin = childNode(withName: "goblin") as? SKSpriteNode
        
        
        one = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        two = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))

        
        one.position = CGPoint(x: scene!.frame.width / -5.5, y: scene!.frame.height / 4)
        two.position = CGPoint(x: scene!.frame.width / 5.5, y: scene!.frame.height / 4)
        
        
        self.physicsWorld.contactDelegate = self

        //self.view?.isMultipleTouchEnabled = true
        
        cam = SKCameraNode()
        self.addChild(cam!)
        camera = cam
        
        self.addChild(one)
        self.addChild(two)
        
        
        
        SetupStart()
        SetupEnemies()
        SetupBackground()
        SetupNotifications()
        SetupAnimations()
        SetupConstraints()
    }

    func SetupEnemies() {
        goblin.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: -200, y: 0, duration: 4.0), SKAction.run {
                self.goblin.texture = SKTexture(imageNamed: "goblinRight")
            }, SKAction.moveBy(x: 200, y: 0, duration: 4.0), SKAction.run {
                self.goblin.texture = SKTexture(imageNamed: "goblin")
            }])))
        
        
    }
    
    func SetupStart() {
        let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sunAnimation), userInfo: nil, repeats: false)
        backgroundMusic?.play()
        
        
        SetupWeaponType()
        SetupPhysicsBodies()
        createGround()
        
    }
    
    
    @objc func sunAnimation() {
        print("IN SUN ANIMATION FUNC")
        
        sun.run(SKAction.move(by: CGVector(dx: 0, dy: (view?.frame.height)! / -4 * 3), duration: 10.0), withKey: "sun")
        sun.run(SKAction.move(by: CGVector(dx: 0, dy: -200), duration: 10.0)) {
            self.sun.run(SKAction.fadeOut(withDuration: 5.0), completion: {
                self.sun.removeFromParent()
            })
        }
    }
    
    func SetupBackground() {
        moveClouds()
    }
    
    
    
    func SetupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.updateUserLeft), name: NSNotification.Name(rawValue: "0"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.updateUserRight), name: NSNotification.Name(rawValue: "1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.stopUser), name: NSNotification.Name("3"), object: nil)
    }
    
    func SetupWeaponType() {
        let fireballTexture = SKTexture(imageNamed: "1")
        fireball = SKSpriteNode(texture: fireballTexture, size: CGSize(width: user.size.height / 2, height: user.size.height * 0.27))
    }
    
    func SetupAnimations() {
        for i in 1...fireballAtlas.textureNames.count {
            fireballArray.append(SKTexture(imageNamed: "\(i)"))
        }
        
        for i in 0...userAtlas.textureNames.count - 1 {
            let name = "mage_\(i).png"
            userArray.append(SKTexture(imageNamed: name))
        }
    }
    
    func SetupConstraints() {
    
    }
    
    func SetupPhysicsBodies() {
        goblin.physicsBody = SKPhysicsBody(rectangleOf: goblin.size)
        goblin.physicsBody?.isDynamic = true
        goblin.physicsBody?.allowsRotation = false
        goblin.physicsBody?.categoryBitMask = BitMasks.enemy
        goblin.physicsBody?.contactTestBitMask = BitMasks.user
        goblin.physicsBody?.collisionBitMask = BitMasks.floor
        
        
        floor = SKSpriteNode(imageNamed: "floor")
        floor.physicsBody?.isDynamic = true
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (self.scene?.size.width)!, height: self.frame.size.height / 3 - floor.frame.size.height * 0.07))
        floor.physicsBody?.pinned = true
        floor.physicsBody?.allowsRotation = false
        floor.physicsBody?.collisionBitMask = BitMasks.user
        floor.physicsBody?.categoryBitMask = BitMasks.floor
        floor.physicsBody?.contactTestBitMask = BitMasks.fire | BitMasks.user
        floor.physicsBody?.restitution = 0.0
        
        user.physicsBody = SKPhysicsBody(rectangleOf: user.size)
        user.physicsBody?.isDynamic = true
        user.physicsBody?.pinned = false
        user.physicsBody?.allowsRotation = false
        user.physicsBody?.affectedByGravity = true
        user.physicsBody?.collisionBitMask = BitMasks.floor
        user.physicsBody?.categoryBitMask = BitMasks.user
        user.physicsBody?.contactTestBitMask = BitMasks.floor
        user.physicsBody?.restitution = 0.0
        user.physicsBody?.density = 0.6

        
        fireball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "1"), size: fireball.size)
        //fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.pinned = false
        fireball.physicsBody?.allowsRotation = true
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody?.collisionBitMask = 0
        fireball.physicsBody?.categoryBitMask = BitMasks.fire
        fireball.physicsBody?.contactTestBitMask = BitMasks.enemy | BitMasks.floor
        fireball.physicsBody?.density = 1.0
        
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
            b = secondBody.node as! SKSpriteNode?
            
            b?.run(SKAction.fadeOut(withDuration: 0.1), completion: {
                b?.removeFromParent()
            })
        } else if firstBody.categoryBitMask == BitMasks.user && secondBody.categoryBitMask == BitMasks.floor {
            
            jump = false
            if userRight {
                runUser(leftRight: true)
            } else if userLeft {
                runUser(leftRight: false)
            } else {
                print("Reset texture to normal")
                user.texture = SKTexture(imageNamed: "mage")
            }
            
        } else if firstBody.categoryBitMask == BitMasks.enemy && secondBody.categoryBitMask == BitMasks.fire {
            a = firstBody.node as? SKSpriteNode
            b = secondBody.node as? SKSpriteNode
            
            b?.run(SKAction.fadeOut(withDuration: 0.1), completion: {
                b?.removeFromParent()
            })
            a?.removeAllActions()
            a?.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                a?.position = CGPoint(x: (self.view?.frame.width)! / 2, y: (self.view?.frame.height)!)
                a?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                a?.run(SKAction.fadeIn(withDuration: 0.5), completion: {
                    self.SetupEnemies()
                })
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
        user.removeAllActions()
        userRight = false
        userLeft = false
    }
    
    @objc func updateUserLeft() {
        userLeft = true
        //user.texture = SKTexture(imageNamed: "mage")
        user.xScale = abs(user.xScale) * 1.0
        userRight = false
        if !jump {
            runUser(leftRight: false)
        }
    }
    
    @objc func updateUserRight() {
        userRight = true
        //user.texture = SKTexture(imageNamed: "mageRight")
        user.xScale = abs(user.xScale) * -1.0
        userLeft = false
        if !jump {
            runUser(leftRight: true)
        }
    }
    
    func Jump() {
        user.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
        user.removeAllActions()
        user.texture = SKTexture(imageNamed: "mageJump")
        jump = true
    }
    
    func Fire(dx : CGFloat, dy : CGFloat) {
        
        var newX = dx
        var newY = dy
        let maxPower : CGFloat = 50
        
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
            tempNode?.physicsBody?.affectedByGravity = false
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
            tempNode.run(SKAction.fadeOut(withDuration: 2.5), completion: {
                self.tempNode.removeFromParent()
            })
            attack = false
        }
    }
    
    
    func runUser(leftRight : Bool) {
        //setup walkAnimation here
        if leftRight {
            user.xScale = abs(user.xScale) * -1.0
        } else {
            user.xScale = abs(user.xScale) * 1.0
        }
        user.run(SKAction.repeatForever(SKAction.animate(with: userArray, timePerFrame: 0.2)), withKey: "userRun")
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
            if position.x > attackStart.x + 50 {
                user.texture = SKTexture(imageNamed: "mage")

            } else if position.x < attackStart.x - 50 {
                user.texture = SKTexture(imageNamed: "mageRight")

            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            let dx = attackStart.x - t.location(in: self).x
            let dy = attackStart.y - t.location(in: self).y
            if dx > 100 || dx < -100 || dy > 100 || dy < -100 {
                Fire(dx: dx, dy: dy)
            } else {
                if !jump {
                    Jump()
                }
            }
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
    
    
    
    func moveClouds() {
        
        
        fog.run(SKAction.repeatForever((SKAction.sequence([SKAction.fadeOut(withDuration: 16.0), SKAction.fadeIn(withDuration: 18.0)]))))
        fog.run(SKAction.repeatForever((SKAction.sequence([SKAction.moveBy(x: -scene!.frame.size.width, y: 0, duration: 35), SKAction.run({
            self.fog.position.x = 0.0
        })]))))
       
        fog1.run(SKAction.repeatForever((SKAction.sequence([SKAction.fadeOut(withDuration: 13.0), SKAction.fadeIn(withDuration: 17.0)]))))
        fog1.run(SKAction.repeatForever((SKAction.sequence([SKAction.moveBy(x: -scene!.frame.size.width, y: 0, duration: 24), SKAction.run({
            self.fog.position.x = 0.0
        })]))))

    }
    
    func UpdateCamera() {
        if ((user.position.x < one.position.x) && (userLeft == true)) {
            //sky?.position.x -= 3.5
            //mtn1?.position.x -= 3.3
            cam?.position.x -= 3.5
            one.position.x -= 3.5
            two.position.x -= 3.5
            one.color = .green
        } else if ((user.position.x > two.position.x) && (userRight == true)) {
            //sky.position.x += 3.5
            //mtn1?.position.x += 3.3
            cam?.position.x += 3.5
            one.position.x += 3.5
            two.position.x += 3.5
            two.color = .green
        } else if one.color == .green || two.color == .green {
            one.color = .red
            two.color = .red
        }
    }
    

    func moveUser() {
        if userLeft {
            user.position.x -= 3.5
        } else if userRight {
            user.position.x -= -3.5
        }
    }

    func createGround() {

        for i in -1...1 {
            if let x = floor {
                tempNode = x.copy() as? SKSpriteNode
                tempNode.name = "floor\(i)"
                tempNode.zPosition = 10
                tempNode.size = CGSize(width: (self.scene?.size.width)!, height: self.frame.size.height / 3)
                tempNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                tempNode.position = CGPoint(x: CGFloat(i) * floor.size.width / 1.55, y: -(self.frame.size.height / 3))
                self.addChild(tempNode)
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveUser()
        UpdateCamera()
    }
}
