//
//  GameViewController.swift
//  HeroOne
//
//  Created by Drew Foster on 10/11/18.
//  Copyright © 2018 Drew Foster. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    
    
    var leftBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = true
        btn.setImage(UIImage(named: "right"), for: .normal)
        btn.tag = 0
        btn.addTarget(self, action: #selector(moveCharacter), for: .touchDown)
        btn.addTarget(self, action: #selector(stopCharacter), for: [.touchUpOutside, .touchUpInside])
        return btn
    }()

    var rightBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "left"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = true
        btn.tag = 1
        btn.addTarget(self, action: #selector(moveCharacter), for: .touchDown)
        btn.addTarget(self, action: #selector(stopCharacter), for: [.touchUpOutside, .touchUpInside])
        return btn
    }()
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(disable_movement), name: NSNotification.Name(rawValue: "disable_movement"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enable_movement), name: NSNotification.Name(rawValue: "enable_movement"), object: nil)

        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            self.view.addSubview(leftBtn)
            self.view.addSubview(rightBtn)
            
            
            view.ignoresSiblingOrder = true
            //view.showsPhysics = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            SetupConstraints()
        }
    }
    
    @objc func disable_movement() {
        leftBtn.isEnabled = false
        rightBtn.isEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            self.leftBtn.alpha = 0
            self.rightBtn.alpha = 0
        }
    }
    
    @objc func enable_movement() {
        leftBtn.isEnabled = true
        rightBtn.isEnabled = true
        
        UIView.animate(withDuration: 0.5) {
            self.leftBtn.alpha = 1
            self.rightBtn.alpha = 1
        }
    }

    @objc func moveCharacter(sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: String(sender.tag)), object: nil)
    }
    
    @objc func stopCharacter(sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "3"), object: nil)
    }
    
    func SetupConstraints() {
        leftBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        leftBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        leftBtn.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/5).isActive = true
        leftBtn.heightAnchor.constraint(equalTo: leftBtn.widthAnchor, multiplier: 0.845).isActive = true
        
        rightBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        rightBtn.leftAnchor.constraint(equalTo: leftBtn.rightAnchor, constant: 25).isActive = true
        rightBtn.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/5).isActive = true
        rightBtn.heightAnchor.constraint(equalTo: leftBtn.widthAnchor, multiplier: 0.845).isActive = true
    
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .landscape
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .landscape
//        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
