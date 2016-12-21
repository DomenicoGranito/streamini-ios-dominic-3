//
//  ModalViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController
{
    override func viewDidLoad()
    {
        let effect=UIBlurEffect(style:.Light)
        let blurView=UIVisualEffectView(effect:effect)
        blurView.frame=view.bounds
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
    }    
}
