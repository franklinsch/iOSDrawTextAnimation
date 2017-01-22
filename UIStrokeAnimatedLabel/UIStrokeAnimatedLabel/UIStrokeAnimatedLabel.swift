//
//  StrokeAnimator2.swift
//  DrawTextAnimationDemo
//
//  Created by Franklin Schrans on 1/21/17.
//  Copyright © 2017 Franklin Schrans. All rights reserved.
//

import UIKit

public class UIStrokeAnimatedLabel: UILabel {
  
  // MARK: Properties
  
  /// Duration of the stroke animation.
  public var animationDuration = 1.0
  
  /// Disable the stroke animation.
  public var disableAnimation = false
  
  /// Color of the storke used to draw the label.
  public lazy var strokeColor: UIColor = {
    return self.textColor
  }()
  
  /** 
   Width of the stroke used to draw the label.
   Can be set absolutely or relatively to the `strokeWidthReferenceCharacter`'s width using the enum:
   
   ```
   enum StrokeWidth {
    case absolute(value: CGFloat)
    case relative(scale: CGFloat)
   }

   ```
   
   Default value is `.relative(scale: 0.2)`.
  */
  public var strokeWidth: StrokeWidth = .relative(scale: 0.2)
  
  /// Reference character to compute stroke width.
  /// Default is `l`.
  public var strokeWidthReferenceCharacter = "l"
  
  /**
    Spacing between characters of a word.
    Can be set absolutely or relatively to `spacingReferenceCharacter`'s width using the enum:
   
   ```
   enum CharacterSpacing {
    case absolute(value: CGFloat)
    case relative(scale: CGFloat)
   }
   
   ```
   
   Default value is `.relative(scale: 1.2)`.
  */
  public var characterSpacing: Spacing = .relative(scale: 0.2)

  /**
   Spacing between words.
   Can be set absolutely or relatively to `spacingReferenceCharacter`'s width using the enum:
   
   ```
   enum StrokeWidth {
    case absolute(value: CGFloat)
    case relative(scale: CGFloat)
   }
   
   ```
   
   Default value is `.relative(scale: 0.5)`.
   */
  public var wordSpacing: Spacing = .relative(scale: 0.5)
  
  /// Reference character to compute character spacing and word spacing.
  /// Default is `M`.
  public var spacingReferenceCharacter = "M"
  
  // MARK: UILabel
  
  /// Override `draw` to animate the label.
  public override func draw(_ rect: CGRect) {
    if disableAnimation {
      super.draw(rect)
    }
    
    performStrokeAnimation()
  }
  
  // MARK: Convenience
  
  /// Performs the stroke animation by adding and animating subviews.
  private func performStrokeAnimation() {
    guard let text = text else {
      return
    }
    
    let words = text.characters.split(separator: " ").map(String.init)
    let wordLayers: [CALayer] = words.flatMap({ layer(for: $0) })
    
    let textView = view(from: wordLayers)
    
    textView.frame.origin.x = (frame.width - textView.frame.size.width) / 2
    textView.frame.origin.y = (frame.height - textView.frame.size.height) / 2
    
    addSubview(textView)
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = animationDuration
    animation.fromValue = 0
    animation.toValue = 1
    
    animateSublayers(textView.layer, animation: animation)
  }
  
  /// Creates a `CALayer` representing `text` using the the label's properties.
  private func layer(for text: String) -> CALayer? {
    var unichars = [UniChar](text.utf16)
    var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
    
    guard CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count) else {
      return nil
    }
    
    let strokeWidthReferenceCharacterBoundingBox = self.boundingBox(for: strokeWidthReferenceCharacter, using: font)
    
    let strokeWidth: CGFloat
    
    switch self.strokeWidth {
      case .absolute(value: let value):
        strokeWidth = value
      case .relative(scale: let scale):
        strokeWidth = strokeWidthReferenceCharacterBoundingBox.width * scale
    }
    
    let layers: [CALayer] = glyphs.flatMap({ glyph in
      guard let path = CTFontCreatePathForGlyph(font, glyph, nil) else {
        return nil
      }
      
      let layer = CAShapeLayer()
      layer.path = path
      layer.bounds = path.boundingBox
      layer.isGeometryFlipped = true
      layer.strokeColor = strokeColor.cgColor
      layer.fillColor = UIColor.clear.cgColor
      layer.lineWidth = strokeWidth

      return layer
    })

    let groupLayer = CAShapeLayer()
    
    let letterHeight = strokeWidthReferenceCharacterBoundingBox.height
    
    var offset = CGFloat(0)
    
    let spacingReferenceCharacterBoundingBox = self.boundingBox(for: spacingReferenceCharacter, using: font)
    
    for layer in layers {
      let yOrigin = letterHeight - layer.bounds.height
      layer.frame.origin = CGPoint(x: offset, y: yOrigin)
      
      let characterSpacing: CGFloat
      
      switch self.characterSpacing {
        case .absolute(value: let value):
          characterSpacing = value
        case .relative(scale: let scale):
          characterSpacing = spacingReferenceCharacterBoundingBox.width * scale
      }
      
      offset = layer.frame.maxX + characterSpacing
      groupLayer.addSublayer(layer)
    }
    
    groupLayer.bounds = CGRect(x: layers.first!.frame.origin.x, y: layers.first!.frame.origin.y, width: layers.last!.frame.maxX, height: layers.first!.frame.size.height)
    
    groupLayer.frame.origin = CGPoint(x: 0, y: 0)
    
    return groupLayer
  }
  
  private func view(from layers: [CALayer]) -> UIView {
    let textView = UIView()
    
    let wordSpacing: CGFloat
    
    switch self.wordSpacing {
      case .absolute(value: let value):
        wordSpacing = value
      case .relative(scale: let scale):
        wordSpacing = boundingBox(for: spacingReferenceCharacter, using: font).width * scale
    }
    
    let digitHeight = layers.first!.frame.size.height
    
    for i in 0..<layers.count {
      let xPos = i == 0 ? 0 : layers[i-1].frame.maxX + wordSpacing
      layers[i].frame.origin.x = xPos
      layers[i].bounds.origin.y = 0
      textView.layer.addSublayer(layers[i])
    }
    
    textView.frame = CGRect(x: 0, y: 0, width: layers.last!.frame.maxX, height: digitHeight)
    
    return textView
    
  }
  
  private func animateSublayers(_ layer: CALayer, animation: CAAnimation) {
    let sublayers = layer.sublayers!
    for sublayer in sublayers {
      if sublayer.sublayers != nil {
        animateSublayers(sublayer, animation: animation)
      } else {
        sublayer.add(animation, forKey: "textAppear")
      }
    }
  }
  
  private func boundingBox(for letter: String, using font: UIFont) -> CGRect {
    var unichars = [UniChar](letter.utf16)
    var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
    _ = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
    let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)
    
    return cgpath!.boundingBox
  }
  
  // MARK: Enumerations

  /// Enum describing a stroke width, which can be set absolutely, or relatively to `strokeWidthReferenceCharacter`'s width.
  public enum StrokeWidth {
    
    /// Set the same stroke width between every character of a word.
    case absolute(value: CGFloat)
    
    /// Set the stroke width relative to the `strokeWidthReferenceCharacter`'s width, by specifying a scale factor.
    case relative(scale: CGFloat)
  }
  
  /// Enum describing spacing between characters or words, which can be set absolutely, or relatively to `spacingReferenceCharacter`'s width.
  public enum Spacing {
    
    /// Set the same character spacing between every character of a word.
    case absolute(value: CGFloat)
    
    /// Set the character spacing relative to `spacingReferenceCharacter`'s width, by specifying a scale factor.
    case relative(scale: CGFloat)
  }
  
}
