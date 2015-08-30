//
//  ViewController.swift
//  DrawTextAnimationDemo
//
//  Created by Franklin Schrans on 30/08/2015.
//  Copyright (c) 2015 Franklin Schrans. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var swiftBox: UIView!
    @IBOutlet weak var rocksBox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rocksFont = CTFontCreateWithName("Didot", 50, nil)
        let swiftFont = CTFontCreateWithName("AvenirNext-UltraLight", 50, nil)
        let color = UIColor.grayColor().CGColor
        
        performStrokeAnimation(text: "SWIFT", font: swiftFont, duration: 1.0, borderColor: color, inView: swiftBox)
        performStrokeAnimation(text: "ROCKS", font: rocksFont, duration: 1.0, borderColor: color, inView: rocksBox)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

