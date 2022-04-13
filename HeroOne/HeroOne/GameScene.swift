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
    static let lady : UInt32 = 0x1 << 4
    static let brute_node : UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var user : SKSpriteNode!
    var floor : SKSpriteNode!
    var goblin : SKSpriteNode!
    var lady : SKSpriteNode!
    var brute_0 : SKSpriteNode!
    var brute_1 : SKSpriteNode!
    
    var mtn0 : SKSpriteNode!
    var mtn1 : SKSpriteNode!
    var fog : SKSpriteNode!
    var fog1 : SKSpriteNode!
    var sky : SKSpriteNode!
    var sun : SKSpriteNode!
    
    var helpNode : SKSpriteNode!
    var brute_node : SKSpriteNode!
    var brute_cam = false
    
    var one : SKSpriteNode!
    var two : SKSpriteNode!
    
    var userLeft : Bool = false
    var userRight : Bool = false
    var jump : Bool = false
    
    var attackStart : CGPoint!
    var attack = false
    
    var fireball : SKSpriteNode!
    //var fireballAtlas = SKTextureAtlas(named: "Fireball")
    //var fireballArray = [SKTexture]()
    
    var enemyAtlas = SKTextureAtlas(named: "brute_attack")
    var enemyArray = [SKTexture]()
    
    var userAtlas = SKTextureAtlas(named: "mageWalk")
    var userArray = [SKTexture]()
    
    var tempNode : SKSpriteNode!
    
    var cam: SKCameraNode?
    var facingLeft: Bool?
    var facingRight: Bool?
 
    
    lazy var showMenu : ShowMenu = {
        let showMenu = ShowMenu()
        //showMenu.viewController = self
        return showMenu
    }()

    
    lazy var backgroundMusic : AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "bgMusic", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
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
        lady = childNode(withName: "lady") as? SKSpriteNode
        helpNode = childNode(withName: "help") as? SKSpriteNode
        brute_0 = childNode(withName: "brute_0") as? SKSpriteNode
        brute_1 = childNode(withName: "brute_1") as? SKSpriteNode
        brute_node = childNode(withName: "brute_node") as? SKSpriteNode
        
        
        one = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 50))
        two = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 50))

        
        one.position = CGPoint(x: scene!.frame.width / -7.5, y: scene!.frame.height / 4)
        two.position = CGPoint(x: scene!.frame.width / 7.5, y: scene!.frame.height / 4)
        
        
        self.physicsWorld.contactDelegate = self

        //self.view?.isMultipleTouchEnabled = true
        
        cam = SKCameraNode()
        self.addChild(cam!)
        camera = cam
        
        self.addChild(one)
        self.addChild(two)
        
        SetupStart()
        SetupEnemies()
        SetupLady()
        SetupBackground()
        SetupNotifications()
        SetupAnimations()
        SetupConstraints()
    }

    func SetupEnemies() {
        goblin.name = "5"
        goblin.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: -200, y: 0, duration: 4.0), SKAction.run {
                self.goblin.texture = SKTexture(imageNamed: "goblinRight")
            }, SKAction.moveBy(x: 200, y: 0, duration: 4.0), SKAction.run {
                self.goblin.texture = SKTexture(imageNamed: "goblin")
            }])))
    }
  
    
    func SetupLady() {
        lady.run(SKAction.repeatForever(SKAction.sequence(
                                            [SKAction.moveBy(x: -50, y: 0, duration: 1.0), SKAction.run {
                                                self.lady.xScale = abs(self.lady.xScale) * -1.0
                                            }, SKAction.moveBy(x: 50, y: 0, duration: 1.0),
                                            SKAction.run {
                                                self.lady.xScale = abs(self.lady.xScale) * 1.0
                                            }])))
        
        helpNode.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: -50, y: 0, duration: 1.0), SKAction.moveBy(x: 50, y: 0, duration: 1.0)])))
        
    }
    
    func SetupStart() {
        let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sunAnimation), userInfo: nil, repeats: false)
        //backgroundMusic?.play() music
        
        SetupWeaponType()
        SetupPhysicsBodies()
        createGround()
    }
       
    
    
    @objc func sunAnimation() {
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
        let fireballTexture = SKTexture(imageNamed: "fireball")
        fireball = SKSpriteNode(texture: fireballTexture, size: CGSize(width: user.size.height * 0.75, height: user.size.height * 0.4875))
    }
    
    func SetupAnimations() {
        /*for i in 1...fireballAtlas.textureNames.count {
            fireballArray.append(SKTexture(imageNamed: "\(i)"))
        }*/
        
        for i in 0...userAtlas.textureNames.count - 1 {
            let name = "mage_\(i).png"
            userArray.append(SKTexture(imageNamed: name))
        }
        
        for i in 0...enemyAtlas.textureNames.count - 1 {
            let name = "brute_with_sword_\(i)"
            enemyArray.append(SKTexture(imageNamed: name))
        }
    }
    
    func SetupConstraints() {
    
    }
    
    func SetupPhysicsBodies() {
        brute_node.physicsBody = SKPhysicsBody(rectangleOf: brute_node.size)
        brute_node.physicsBody?.categoryBitMask = BitMasks.brute_node
        brute_node.physicsBody?.contactTestBitMask = BitMasks.user
        
        
        goblin.physicsBody = SKPhysicsBody(rectangleOf: goblin.size)
        goblin.physicsBody?.isDynamic = true
        goblin.physicsBody?.allowsRotation = false
        goblin.physicsBody?.categoryBitMask = BitMasks.enemy
        goblin.physicsBody?.contactTestBitMask = BitMasks.user
        goblin.physicsBody?.collisionBitMask = BitMasks.floor
        
        brute_1.physicsBody = SKPhysicsBody(rectangleOf: brute_1.size)
        brute_1.physicsBody?.isDynamic = true
        brute_1.physicsBody?.allowsRotation = false
        brute_1.physicsBody?.categoryBitMask = BitMasks.enemy
        brute_1.physicsBody?.contactTestBitMask = BitMasks.user
        brute_1.physicsBody?.collisionBitMask = BitMasks.floor
        
        brute_0.physicsBody = SKPhysicsBody(rectangleOf: brute_0.size)
        brute_0.physicsBody?.isDynamic = true
        brute_0.physicsBody?.allowsRotation = false
        brute_0.physicsBody?.categoryBitMask = BitMasks.enemy
        brute_0.physicsBody?.contactTestBitMask = BitMasks.user
        brute_0.physicsBody?.collisionBitMask = BitMasks.floor
        
        lady.physicsBody = SKPhysicsBody(rectangleOf: lady.size)
        lady.physicsBody?.isDynamic = true
        lady.physicsBody?.allowsRotation = false
        lady.physicsBody?.categoryBitMask = BitMasks.lady
        lady.physicsBody?.collisionBitMask = BitMasks.floor
        
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

        
        fireball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "fireball"), size: fireball.size)
        //fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.pinned = false
        fireball.physicsBody?.allowsRotation = true
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody?.collisionBitMask = 0
        fireball.physicsBody?.categoryBitMask = BitMasks.fire
        fireball.physicsBody?.contactTestBitMask = BitMasks.enemy | BitMasks.floor
        fireball.physicsBody?.density = 3.0
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
                user.texture = SKTexture(imageNamed: "mage")
            }
            
        } else if firstBody.categoryBitMask == BitMasks.enemy && secondBody.categoryBitMask == BitMasks.fire {
            a = firstBody.node as? SKSpriteNode
            b = secondBody.node as? SKSpriteNode
            
            let name = goblin.name!
            let x = Int(name)
            if x == 1 {
                goblin.name = "5"
            
            
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
                    
            } else {
                goblin.name = "\(x!-1)"
                a?.run(SKAction.applyImpulse(CGVector(dx: 10, dy: 10), at: CGPoint(x: 0.5, y: 0.5), duration: 2.0))
                
                a?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25), SKAction.fadeIn(withDuration: 0.25)]))
                
            }
        } else if firstBody.categoryBitMask == BitMasks.user && secondBody.categoryBitMask == BitMasks.brute_node {
            if brute_cam == false {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disable_movement"), object: nil)
                stopUser()

                cam?.run(SKAction.move(by: CGVector(dx: (self.view?.frame.width)!, dy: 0), duration: 1.5), completion: { [self] in
                    one.run(SKAction.move(by: CGVector(dx: (self.view?.frame.width)!, dy: 0), duration: 0.1))
                    two.run(SKAction.move(by: CGVector(dx: (self.view?.frame.width)!, dy: 0), duration: 0.1))
                    // goblin chat box
                    goblin_chat()
                })                
                brute_cam = true
            }
        }
    }
  
        
    func goblin_chat() {
        // enable movement after continue chat.
        //self.showMenu.Settings(character: "brute")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enable_movement"), object: nil)
        
        brute_0.xScale = abs(brute_0.xScale) * 1.0
        
        

        let duration = TimeInterval(Int.max) //want the action to run infinitely
        
        let followPlayer = SKAction.customAction(withDuration: duration) { (node, time) in
            var dx = self.user.position.x - self.brute_0.position.x
            
            if dx < 0 {
                dx -= 300
            } else {
                dx += 300
            }
            
            let angle = atan2(dx,0)
            node.position.x += sin(angle) * 0.7
        }
        
        brute_0.run(followPlayer)

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
        facingLeft = true
        //user.texture = SKTexture(imageNamed: "mage")
        user.xScale = abs(user.xScale) * 1.0
        userRight = false
        facingRight = false
        if !jump {
            runUser(leftRight: false)
        }
    }
    
    @objc func updateUserRight() {
        userRight = true
        facingRight = true
        //user.texture = SKTexture(imageNamed: "mageRight")
        user.xScale = abs(user.xScale) * -1.0
        userLeft = false
        facingLeft = false
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
        
        let angle = atan2(dx,dy)
        
        var newX = dx
        var newY = dy
        let maxPower : CGFloat = 100

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
           
           if angle > 0 {
               tempNode.physicsBody?.applyAngularImpulse(angle / -200)
           } else {
               
               tempNode.xScale = -1
               tempNode.physicsBody?.applyAngularImpulse(angle / 200)
           }
           tempNode.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
           attack = false
        }
        
        
        user.run(SKAction.animate(with: userArray, timePerFrame: 0.1), withKey: "userFire")

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
            if position.x > attackStart.x + 25 {
                if facingRight != nil && facingRight == true {
                    user.xScale = abs(user.xScale) * 1.0
                } else {
                    user.texture = SKTexture(imageNamed: "mage")
                }
                facingLeft = false
                facingRight = true
            } else if position.x < attackStart.x - 25 {
                if facingRight != nil && facingRight == true {
                    user.xScale = abs(user.xScale) * -1.0
                } else {
                    user.texture = SKTexture(imageNamed: "mageRight")
                }
            }
            
        }
    }
    
    func updateLadyDirection() {
        self.lady.removeAllActions()
        self.helpNode.removeAllActions()
        
        
        
        let diff = self.user.position.x - self.lady.position.x
        if diff > 0 { // lady on the left of user
            if (self.lady.xScale > 0) {
                lady.xScale = abs(lady.xScale) * -1.0
            }
            self.helpNode.run(SKAction.moveTo(x: self.user.position.x - 100, duration: 2.0))
            self.lady.run(SKAction.moveTo(x: self.user.position.x - 100, duration: 2.0))
        } else { // lady on the right of user
            if (self.lady.xScale < 0) {
                lady.xScale = abs(lady.xScale) * 1.0
            }
            self.helpNode.run(SKAction.moveTo(x: self.user.position.x + 100, duration: 2.0))
            self.lady.run(SKAction.moveTo(x: self.user.position.x + 100, duration: 2.0))
        }
        
        self.helpNode.run(SKAction.fadeOut(withDuration: 0.5)) {
            self.helpNode.removeFromParent()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.showMenu.Settings(character: "lady")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            let loc = t.location(in: self)

            let dx = attackStart.x - t.location(in: self).x
            let dy = attackStart.y - t.location(in: self).y
            if dx > 50 || dx < -50 || dy > 50 || dy < -50 {
                Fire(dx: dx, dy: dy)
            } else if atPoint(loc).name == "help" || atPoint(loc).name == "help_label" {
                // DON'T JUMP
                updateLadyDirection()
                
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
    
    func pause_user(_ seconds: Double) {
        
    }
    
    func UpdateCamera() {
        if ((user.position.x < one.position.x) && (userLeft == true)) {
            //sky?.position.x -= 3.5
            //mtn1?.position.x -= 3.3
            cam?.position.x -= 3.5
            one.position.x -= 3.5
            two.position.x -= 3.5
        } else if ((user.position.x > two.position.x) && (userRight == true)) {
            //sky.position.x += 3.5
            //mtn1?.position.x += 3.3
            cam?.position.x += 3.5
            one.position.x += 3.5
            two.position.x += 3.5
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

        for i in -1...3 {
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
