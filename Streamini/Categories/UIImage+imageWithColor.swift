//
//  UIImage+imageWithColor.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 23.09.15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
        
    }
    
}
