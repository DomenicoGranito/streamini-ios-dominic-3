//
//  ContainerViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class ContainerViewController: UIViewController {
    let kSegueIdentifierMain    = "embedMain"
    
   // let kSegueIdentifierMain    = "MainToJoinStream"
    let kSegueIdentifierPeople  = "embedPeople"
    
    //var currentSegueIdentifier  = "MainToJoinStream"
    var currentSegueIdentifier  = "embedMain"
    
    var parentController: RootViewController?

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegueWithIdentifier(kSegueIdentifierMain, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            let destinationController = segue.destinationViewController 
            
            if sid == kSegueIdentifierMain {
//                (destinationController as! HomeViewController).rootControllerDelegate = parentController!
//                parentController!.delegate = (destinationController as! HomeViewController)
                
                if self.childViewControllers.count > 0 {
                    swapFromViewController(childViewControllers[0] , toViewController: destinationController)
                } else {
                    self.addChildViewController(destinationController)
                    destinationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                    self.view.addSubview(destinationController.view)
                    segue.destinationViewController.didMoveToParentViewController(self)
                }
            } else if segue.identifier == kSegueIdentifierPeople {
                self.swapFromViewController(childViewControllers[0] , toViewController: destinationController)

            }
        }
    }
    
    // MARK: - Helpers
    
    func swapFromViewController(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: NSTimeInterval(1.0), options: UIViewAnimationOptions.TransitionNone, animations: nil) { (finished) -> Void in
            fromViewController.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
        }
    }
    
    func swapViewControllers() {
        self.currentSegueIdentifier = (self.currentSegueIdentifier == kSegueIdentifierMain) ? kSegueIdentifierPeople : kSegueIdentifierMain
        self.performSegueWithIdentifier(currentSegueIdentifier, sender: nil)
    }
    
    func mainViewController() {
        if currentSegueIdentifier == kSegueIdentifierPeople {
            swapViewControllers()
        }
    }
    
    func peopleViewController() {
        if currentSegueIdentifier == kSegueIdentifierMain {
            swapViewControllers()
        }
    }
}
