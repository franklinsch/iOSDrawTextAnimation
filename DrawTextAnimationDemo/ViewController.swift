//
//  ViewController.swift
//  DrawTextAnimationDemo
//
//  Created by Franklin Schrans on 30/08/2015.
//  Copyright (c) 2015 Franklin Schrans. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var swiftLabel: UIStrokeAnimatedLabel!
  @IBOutlet weak var rocksLabel: UIStrokeAnimatedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      swiftLabel.animationDuration = 1.0
      rocksLabel.animationDuration = 2.0
      
      swiftLabel.strokeWidth = .relative(scale: 1.0)
      rocksLabel.strokeColor = .gray
      swiftLabel.characterSpacing = .absolute(value: 20.0)
      rocksLabel.wordSpacing = .relative(scale: 0.5)
      
      rocksLabel.disableAnimation = false
    }
  
}

