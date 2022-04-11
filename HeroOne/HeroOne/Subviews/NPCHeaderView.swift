//
//  NPCHeaderView.swift
//  HeroOne
//
//  Created by Drew Foster on 4/10/22.
//  Copyright © 2022 Drew Foster. All rights reserved.
//

import Foundation
import UIKit

class NPCHeaderView : UIView {
    
    let npc_icon : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.image = UIImage(named: "lady_icon")
        return image
    }()
    
    let npc_label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Villager"
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        self.addSubview(npc_icon)
        self.addSubview(npc_label)
    }
    
    func setupConstraints() {
        self.npc_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.npc_label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        self.npc_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9).isActive = true
        self.npc_label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        self.npc_icon.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        self.npc_icon.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.18).isActive = true
        self.npc_icon.heightAnchor.constraint(equalTo: self.npc_icon.widthAnchor, multiplier: 1).isActive = true
        self.npc_icon.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        
    }
    
}
