//
//  StrokeAnimator.swift
//  DrawTextAnimationDemo
//
//  Created by Franklin Schrans on 30/08/2015.
//  Copyright (c) 2015 Franklin Schrans. All rights reserved.
//

import Foundation
import UIKit


func performStrokeAnimation(#text: String, #font: CTFont, inView view: UIView) {
    performStrokeAnimation(text: text, font: font, duration: 1.0, borderColor: UIColor.blackColor().CGColor, inView: view)
}

func performStrokeAnimation(#text: String, #font: CTFont, #duration: CFTimeInterval, #borderColor: CGColor, inView view: UIView) {
    var textGroups = split(text) { $0 == " "}
    var groupLayers: [CALayer] = []
    
    for textGroup in textGroups {
        groupLayers.append(getGroupLayer(textGroup, font))
    }
    
    var textView = createViewFromLayers(groupLayers)
    
    textView.frame.origin.x = (view.frame.width - textView.frame.size.width) / 2
    textView.frame.origin.y = (view.frame.height - textView.frame.size.height) / 2
    
    view.addSubview(textView)
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = duration
    animation.fromValue = 0
    animation.toValue = 1
    
    animateSublayers(textView.layer, animation)
}

func getGroupLayer(textGroup: String, font: CTFont) -> CALayer {
    var unichars = [UniChar](textGroup.utf16)
    var glyphs = [CGGlyph](count: unichars.count, repeatedValue: 0)
    let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
    var layers: [CALayer] = []
    if gotGlyphs {
        for i in 0..<glyphs.count {
            let cgpath = CTFontCreatePathForGlyph(font, glyphs[i], nil)
            
            var layer = CAShapeLayer()
            layer.path = cgpath
            layer.bounds = CGPathGetBoundingBox(cgpath)
            layer.geometryFlipped = true
            layer.strokeColor = UIColor.blackColor().CGColor
            layer.fillColor = UIColor.clearColor().CGColor
            layer.lineWidth = 1.0
            layers.append(layer)
        }
    }
    
    var groupLayer = CAShapeLayer()
    
    let letterHeight = getLetterHeight(font: font)
    
    for i in 0..<layers.count {
        let offset = i == 0 ? 0 : CGRectGetMaxX(layers[i-1].frame) + 20
        let yPos = letterHeight - layers[i].bounds.height
        layers[i].frame.origin = CGPoint(x: offset, y: yPos)
        groupLayer.addSublayer(layers[i])
    }
    groupLayer.bounds = CGRectMake(layers.first!.frame.origin.x, layers.first!.frame.origin.y, CGRectGetMaxX(layers.last!.frame), layers.first!.frame.size.height)
    
    groupLayer.frame.origin = CGPoint(x: 0, y: 0)
    
    return groupLayer
}

func createViewFromLayers(layers: [CALayer]) -> UIView {
    var textView = UIView()
    
    let digitHeight = layers.last!.frame.size.height
    
    for i in 0..<layers.count {
        let xPos = i == 0 ? 0 : CGRectGetMaxX(layers[i-1].frame) + 40
        layers[i].frame.origin.x = xPos
        layers[i].frame.origin.y = (digitHeight - layers[i].frame.height) / 2
        textView.layer.addSublayer(layers[i])
    }
    
    textView.frame = CGRectMake(0, 0, CGRectGetMaxX(layers.last!.frame), digitHeight)
    
    return textView
    
}

func animateSublayers(layer: CALayer, animation: CAAnimation) {
    if let sublayers = layer.sublayers as? [CALayer] {
        for sublayer in sublayers {
            if sublayer.sublayers != nil {
                animateSublayers(sublayer, animation)
            } else {
                sublayer.addAnimation(animation, forKey: "textAppear")
            }
        }
    }
}

func getLetterHeight(#font: CTFont) -> CGFloat {
    var unichars = [UniChar]("l".utf16)
    var glyphs = [CGGlyph](count: unichars.count, repeatedValue: 0)
    let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
    var layers: [CALayer] = []
    let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)
    
    return CGPathGetBoundingBox(cgpath).height
}