//
//  MyLibViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 4/2/2017.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

import Foundation
class MyLibViewController: UITableViewController {
    //UITableViewController  {
    var user: User?
    var profileDelegate: ProfileDelegate?
    var selectedImage: UIImage?

   // var dataSource: UserStatisticsDataSource?
    var dataSource: UserSelecting?
    var type: ProfileStatisticsType = .Following
   

   // override func viewDidLoad()
   // {
       // super.viewDidLoad()
       // self.configureView()
        
       // let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
       // activator.startAnimating()
        
       // self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
     //   UserConnector().get(nil, success:successGetUser, failure:successFailure)
   // }

    
    override func viewDidLoad() {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PeopleViewController") as! PeopleViewController
       // vc.user=user
        navigationController?.pushViewController(vc, animated:true)
        
    
    }

   // @IBOutlet var MyProfile : UIButton!
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
     //   if (segue.identifier == "MyProfile") {
         //   let playlistName = sender as! String
       //     let playlistVC = (segue.destinationViewController as? UserViewController)!
           // playlistVC.playlistName = playlistName
            //UserProfileViewController
        //}
    //}
    
   // @IBAction func MyProfilePressed(sender:AnyObject)
    //{
     //   self.performSegueWithIdentifier("MyProfile", sender:self)
   // }
    
    func successGetUser(user: User) {
        self.user = user
         }
    
    func successFailure(error: NSError) {
      //  handleError(error)
    }

    
    @IBAction func tapMyProfileButton(user:User)
    {
     
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
        
        
    }
    
   
}

