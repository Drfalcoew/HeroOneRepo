//
//  HelpChatBox.swift
//  HeroOne
//
//  Created by Drew Foster on 4/9/22.
//  Copyright © 2022 Drew Foster. All rights reserved.
//

import Foundation
import UIKit

class HelpChatBox: UIView {
    
    let message_0 = "Oh! Please help me!"
    let message_1 = "The goblins are on their way to burn down my village!"
    let message_2 = "Hurry!!"
    
    let txtView : UITextView = {
        let view = UITextView()
        view.layer.masksToBounds = true
        view.textAlignment = .center
        view.isEditable = false
        view.layer.zPosition = 1
        return view
    }()
    
    let helpButton : UIButton = {
        let btn = UIButton()
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(helpButtonPressed), for: .touchUpInside)
        btn.tag = 0
        
        return btn
    }()
    
    let helpLabel : UILabel = {
        let lbl = UILabel()
        lbl.layer.masksToBounds = true
        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.2
        lbl.text = "Help!"
        lbl.layer.zPosition = 2
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 12
        self.backgroundColor = .blue
        
        setupViews()
        setupConstraints()
    }
    
    func setupConstraints() {
        helpButton.frame = self.frame
        txtView.frame = self.frame
        helpLabel.frame = self.frame
    }
    
    func setupViews() {
        self.addSubview(helpButton)
        self.helpButton.addSubview(helpLabel)
        self.helpButton.addSubview(txtView)
    }
    
    @objc func helpButtonPressed(sender: UIButton) {
        print(sender.tag)
        print("BTN pressed")
        switch tag {
        case 0:
            sender.tag += 1
            UIView.animate(withDuration: 0.2) {
                self.helpLabel.alpha = 0
            } completion: { (true) in
                self.helpLabel.removeFromSuperview()
            }
            break
        case 1:
            self.txtView.text = message_0
            sender.tag += 1
            break
        case 2:
            self.txtView.text = message_1
            sender.tag += 1
            break
        case 3:
            self.txtView.text = message_2
            sender.tag += 1
            break
        default:
            sender.tag += 0
            break
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
