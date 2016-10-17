//
//  SelectorView.swift
//  Streamini
//
//  Created by Vasily Evreinov on 18/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class SelectorView: UIView {
    let kTotalSections: CGFloat = 3.0
    let kPadding: CGFloat       = 200.0
    let kLineWidth: CGFloat     = 1.0
    let kOffsets: [CGFloat]     = [-5.0, 0.0, 5.0]
    let kTriangleSize: CGSize   = CGSizeMake(10, 8)
    let bottomBackgroundColor   = UIColor(white: 0.9, alpha: 1.0)
    let strokeColor             = UIColor(white: 0.8, alpha: 1.0)
    
    var shapeLayer = CAShapeLayer()
    var setupDone  = false
    
    func selectSection(index: UInt) {
        assert(index <= UInt(kTotalSections)-1, "Index is out of kTotalSections bounds")
        setup()
        
        let sectionWidth: CGFloat  = self.bounds.width / kTotalSections
        let x = ( -(kTotalSections - 1.0 - CGFloat(index)) * sectionWidth ) + kOffsets[Int(index)]
        
        shapeLayer.frame = CGRectMake(x, 0, shapeLayer.frame.width, shapeLayer.frame.height)
    }
    
    private func setup() {
        if setupDone {
            return
        }
        setupDone = true
        
        shapeLayer.frame        = calculateLayerFrame()
        shapeLayer.path         = createPath()
        shapeLayer.fillColor    = bottomBackgroundColor.CGColor
        shapeLayer.strokeColor  = strokeColor.CGColor
        shapeLayer.lineWidth    = kLineWidth
        
        self.layer.addSublayer(shapeLayer)
    }
    
    private func calculateLayerFrame() -> CGRect {
        let sectionWidth: CGFloat  = self.bounds.width / kTotalSections
        let frameWidth = (kTotalSections + kTotalSections - 1) * sectionWidth
        let frameHeight = self.bounds.height
        
        return CGRectMake(0, 0, frameWidth, frameHeight)
    }
    
    private func createPath() -> CGPath {
        let sectionCenter: CGFloat = shapeLayer.frame.width / 2
        
        let path = CGPathCreateMutable()
        var x: CGFloat
        var y: CGFloat
        
        x = 0 - kPadding
        y = shapeLayer.frame.height
        CGPathMoveToPoint(path, nil, x, y)
        
        x = 0 - kPadding
        y = shapeLayer.frame.height / 2
        CGPathAddLineToPoint(path, nil, x, y)
        
        x = sectionCenter - kTriangleSize.width / 2.0
        y = shapeLayer.frame.height / 2
        CGPathAddLineToPoint(path, nil, x, y)
        
        x = sectionCenter
        y = shapeLayer.frame.height / 2 - kTriangleSize.height
        CGPathAddLineToPoint(path, nil, x, y)
        
        x = sectionCenter + kTriangleSize.width / 2.0
        y = shapeLayer.frame.height / 2
        CGPathAddLineToPoint(path, nil, x, y)
        
        x = shapeLayer.frame.width + kPadding
        y = shapeLayer.frame.height / 2
        CGPathAddLineToPoint(path, nil, x, y)
        
        x = shapeLayer.frame.width + kPadding
        y = shapeLayer.frame.height
        CGPathAddLineToPoint(path, nil, x, y)
        
        x = 0 - kPadding
        y = shapeLayer.frame.height
        CGPathAddLineToPoint(path, nil, x, y)
        
        return path
    }
    
}
