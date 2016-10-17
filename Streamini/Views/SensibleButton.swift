//
//  SensibleButton.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class SensibleButton: UIButton {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let margin: CGFloat = 20.0;
        let area = CGRectInset(self.bounds, -margin, -margin);
        return CGRectContainsPoint(area, point);
    }

}
