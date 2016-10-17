//
//  CALayerExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

extension CALayer {

    func addDarkGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds;
        gradient.colors = [ UIColor(white: 0.0, alpha: 0.75).CGColor, UIColor(white: 0.0, alpha: 0.25).CGColor ]
        gradient.startPoint = CGPointMake(0.5, 0.0)
        gradient.endPoint = CGPointMake(0.5, 1.0)
        self.addSublayer(gradient)
    }
    
    func setBorderUIColor(color: UIColor) {
        self.borderColor = color.CGColor
    }
    
    func borderUIColor() -> UIColor {
        return UIColor(CGColor: self.borderColor!)
    }    
}
