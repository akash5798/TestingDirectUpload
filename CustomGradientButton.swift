//
//  CustomGradientButton.swift
//  Prayer Pulse
//
//  Created by mac on 04/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import QuartzCore


class CustomGradientButtonView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor(hex: "c00e22")     //red
    @IBInspectable var secondColor: UIColor = UIColor(hex: "ec4b37")    //orange
    @IBInspectable var thirdColor: UIColor = UIColor(hex: "ec4b37")     //orange
    @IBInspectable var fourthColor: UIColor = UIColor(hex: "c00e22")    //red
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [firstColor.cgColor, secondColor.cgColor, thirdColor.cgColor, fourthColor.cgColor]
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 00, y: 0.5)
        (layer as! CAGradientLayer).endPoint = CGPoint(x: 1.0, y: 0.5)
        
    }
}


class RoundImageView: UIImageView {
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
        clipsToBounds = true
    }
}
