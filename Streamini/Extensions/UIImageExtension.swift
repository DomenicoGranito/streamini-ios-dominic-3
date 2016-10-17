//
//  UIImageExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 20/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

extension UIImage {
    
    func cropCenterSquare() -> UIImage {
        let originalWidth  = Float(self.size.width * self.scale)
        let originalHeight = Float(self.size.height * self.scale)
        let edge = fminf(originalWidth, originalHeight)
        let posX = (originalWidth - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        var cropSquare: CGRect
        if(self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == UIImageOrientation.Right) {
            cropSquare = CGRectMake(CGFloat(posY), CGFloat(posX), CGFloat(edge), CGFloat(edge))
            
        } else {
            cropSquare = CGRectMake(CGFloat(posX), CGFloat(posY), CGFloat(edge), CGFloat(edge))
        }
        
        let imageRef = CGImageCreateWithImageInRect(self.CGImage!, cropSquare);
        let cropped = UIImage(CGImage: imageRef!, scale: 1.0, orientation: self.imageOrientation)
        
        return cropped
    }
    
    func imageScaledToSize(newSize: CGSize, inRect rect:CGRect) -> UIImage {
        let scale = UIScreen.mainScreen().scale
        
        if scale == 2.0 || scale == 3.0 {
            UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
        } else {
            UIGraphicsBeginImageContext(newSize)
        }
        
        //Draw image in provided rect
        self.drawInRect(rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageScaledToFitToSize(newSize: CGSize) -> UIImage {
        if self.size.width < newSize.width && self.size.height < newSize.height {
            return self.copy() as! UIImage
        }
        
        let widthScale: CGFloat = newSize.width/self.size.width;
        let heightScale: CGFloat = newSize.height/self.size.height;
        
        let scaleFactor: CGFloat
        
        //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
        widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
        let scaledSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
        
        return imageScaledToSize(scaledSize, inRect: CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height))
    }
    
    func fixOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransformIdentity;
        
        switch self.imageOrientation {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default: ()
        }
        
        switch self.imageOrientation {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1)
        default: ()
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage!), 0,
            CGImageGetColorSpace(self.CGImage!)!,
            CGImageGetBitmapInfo(self.CGImage!).rawValue)
        
        CGContextConcatCTM(ctx!, transform)
        
        switch self.imageOrientation {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            // Grr...
            CGContextDrawImage(ctx!, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage!)
        default:
            CGContextDrawImage(ctx!, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage!)
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = CGBitmapContextCreateImage(ctx!);
        return UIImage(CGImage: cgimg!)
    }
}
