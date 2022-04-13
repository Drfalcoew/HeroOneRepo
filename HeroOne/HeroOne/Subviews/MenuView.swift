//
//  MenuView.swift
//  HeroOne
//
//  Created by Drew Foster on 4/10/22.
//  Copyright © 2022 Drew Foster. All rights reserved.
//

import UIKit

class ShowMenu: NSObject, UIGestureRecognizerDelegate {
    
    let characters : [String: [String]] = ["lady" : ["Please help me, traveler!", "The goblins are on their way to burn down my village!", "Will you help me, please?"],
                      "brute" : ["Grub zum gomlok füz roklogm!", "Roklothe der zug zug brahzulk.", "ARGH, chehk barg!!"]]
    
    let character_lines : [String : Int] = ["lady": 3, "brute": 3]
    
    var selected_char : String?
    
    let blackView = UIView()
    var tap : UITapGestureRecognizer?
    
    let npc_label = NPCHeaderView()
    var tag = 0
    
    let menuView : UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.layer.zPosition = 1
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }()
    
    let title : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.layer.masksToBounds = true
        lbl.text = ""
        lbl.font = UIFont(name: "Helvetica Neue", size: 18)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.numberOfLines = 0
        lbl.tag = 0
        //lbl.textColor = UIColor(r: 75, g: 80, b: 120)
        return lbl
    }()
    
    let tap_to_continue : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .center
        lbl.text = "(tap to continue)"
        lbl.font = UIFont(name: "Helvetica Neue", size: 16)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.textColor = UIColor.black
        lbl.alpha = 0.5
        return lbl
    }()
    
    @objc func Settings(character char: String) {
        
        self.selected_char = char
        
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = .black
            blackView.alpha = 0
            window.addSubview(blackView)
            window.addSubview(menuView)
            menuView.addSubview(npc_label)
            menuView.addSubview(title)
            menuView.addSubview(tap_to_continue)
            
            setupConstraints()
            setupViews(char: char)
            
            let x = window.frame.width / -2.5
            let y = UIApplication.shared.statusBarFrame.height
            self.blackView.frame = window.frame
            self.menuView.frame = CGRect(x: x - 5, y: y, width: window.frame.width / 2.5, height: window.frame.height)
            
            self.menuView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(continueText)))
            
            self.blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSettings)))
            
            
            UIView.animate(withDuration: 0.35, delay: 0.01, options: .curveEaseOut, animations: {
                self.blackView.alpha = 0.5
                self.menuView.frame = CGRect(x: 0, y: y, width: window.frame.width / 2.5, height: window.frame.height)
                self.menuView.alpha = 1.0
            }, completion: { (true) in
                self.continueText()
            })
        }
    }
    
    func setupViews(char : String){
        npc_label.npc_icon.image = UIImage(named: "\(char)_icon")
        if char == "lady" {
            npc_label.npc_label.text = "Villager"
            return
        }
        npc_label.npc_label.text = char
    }
    
    
    @objc func continueText(){
        guard let char = self.selected_char else { dismissSettings(); return }
        guard let num_lines = character_lines[char] else { dismissSettings(); return}
        guard let _lines = characters[char] else { dismissSettings(); return}
        
        self.title.text = ""
                
        switch title.tag {
        case 0..<num_lines:
            title.setTextWithTypeAnimation(typedText: _lines[title.tag])
            title.tag += 1
            break
        default:
            dismissSettings()
            title.tag = 0
            selected_char = nil
        }
    }
    
    @objc func dismissSettings() {
        if let window = UIApplication.shared.keyWindow {
            let x = window.frame.width / -2.5
            let y = UIApplication.shared.statusBarFrame.height
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 0.0
                self.menuView.alpha = 0.0
                self.menuView.frame = CGRect(x: x, y: y, width: window.frame.width / 2.5, height: window.frame.height)
            }) { (true) in
                self.menuView.removeFromSuperview()
                self.blackView.removeFromSuperview()
            }
        }
    }
    
        
    
    override init() {
        super.init()
        
        
        menuView.addSubview(title)
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.npc_label.topAnchor.constraint(equalTo: self.menuView.topAnchor, constant: 10),
            self.npc_label.widthAnchor.constraint(equalTo: self.menuView.widthAnchor, multiplier: 0.8),
            self.npc_label.heightAnchor.constraint(equalToConstant: 80),
            self.npc_label.centerXAnchor.constraint(equalTo: self.menuView.centerXAnchor, constant: 0),
            
            
            self.tap_to_continue.centerXAnchor.constraint(equalTo: self.menuView.centerXAnchor, constant: 0),
            self.tap_to_continue.bottomAnchor.constraint(equalTo: self.menuView.bottomAnchor, constant: -10),
            self.tap_to_continue.widthAnchor.constraint(equalTo: self.menuView.widthAnchor, multiplier: 0.8),
            self.tap_to_continue.heightAnchor.constraint(equalToConstant: 50),
            
            
            self.title.centerXAnchor.constraint(equalTo: self.menuView.centerXAnchor, constant: 0),
            self.title.widthAnchor.constraint(equalTo: self.menuView.widthAnchor, multiplier: 0.7),
            self.title.bottomAnchor.constraint(equalTo: self.tap_to_continue.topAnchor, constant: -30),
            self.title.topAnchor.constraint(equalTo: self.npc_label.bottomAnchor, constant: 15)
        ])
        
    }
}



extension UILabel {
    func setTextWithTypeAnimation(typedText: String, characterDelay: TimeInterval = 3.5) {
        text = ""
        var writingTask: DispatchWorkItem?
        writingTask = DispatchWorkItem { [weak weakSelf = self] in
            
            for character in typedText {
                DispatchQueue.main.async {
                    weakSelf?.text!.append(character)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        if let task = writingTask {
            let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
    }
    
}
