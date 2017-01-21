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
        
        let swiftFont = CTFontCreateWithName("AvenirNext-UltraLight" as CFString?, 50, nil)
        let rocksFont = CTFontCreateWithName("Didot" as CFString?, 50, nil)
        let color = UIColor.gray.cgColor
        
        performStrokeAnimation(text: "SWIFT", font: swiftFont, inView: swiftBox)
        
        let charSpacing: CGFloat = 20
        let wordSpacing: CGFloat = 40
        
        performStrokeAnimation(text: "ROCKS",
            font: rocksFont,
            characterSpacing: charSpacing,
            wordSpacing: wordSpacing,
            duration: 4.0,
            borderWidth: 1.0,
            borderColor: color,
            inView: rocksBox)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

