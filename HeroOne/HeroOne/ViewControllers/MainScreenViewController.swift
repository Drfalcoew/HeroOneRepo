//
//  MainScreenViewController.swift
//  HeroOne
//
//  Created by Drew Foster on 10/11/18.
//  Copyright © 2018 Drew Foster. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {
    
    
    var warrior : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(StartButton), for: .touchUpInside)
        return btn
    }()
    
    var button : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(StartButton), for: .touchUpInside)
        return btn
    }()
    
    var archer : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .green
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(StartButton), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white;
        
        
        view.addSubview(button)
        
        SetupUI()
    }
    
    @objc func StartButton() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.alpha = 0
        }) { (true) in
            self.navigationController?.pushViewController(GameViewController(), animated: false)
        }
    }
    
    func SetupUI() {
        button.frame = CGRect(x: view.frame.width / 4 + button.frame.width , y: view.frame.height / 7 * 4, width: view.frame.width / 6, height: view.frame.height / 8)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
