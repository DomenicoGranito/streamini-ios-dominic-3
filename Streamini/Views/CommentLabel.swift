//
//  CommentLabel.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CommentLabel: UILabel {
    var edgeInsets: UIEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 5)
    
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = edgeInsets.apply(bounds)
        rect = super.textRectForBounds(rect, limitedToNumberOfLines: numberOfLines)
        return edgeInsets.inverse.apply(rect)
    }
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(edgeInsets.apply(rect))
    }
}