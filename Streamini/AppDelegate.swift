//
//  AppDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: String?
    var notificationsDelegate = NotificationsDelegate()
    var bgTask: UIBackgroundTaskIdentifier?
    var closeStream: Bool = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        UITextField.appearance().tintColor=UIColor(colorLiteralRed:43/255, green:185/255, blue:86/255, alpha:1)
        UITextField.appearance().keyboardAppearance = .Dark
        
        //let twitter = Twitter()
        //let (consumerKey, consumerSecret, _) = Config.shared.twitter()
        //twitter.startWithConsumerKey(consumerKey, consumerSecret: consumerSecret)
        
        RestKitObjC.setupLog()
        //Fabric.with([twitter])
        registerForNotification()
        
        // Setup Amazon S3
        AmazonTool.shared
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
        /*UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "nav-background"), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage(named: "nav-border")
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]*/
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isGlobalStreamsInMain")
        
        //Clear keychain on first run in case of reinstallation
        if !NSUserDefaults.standardUserDefaults().boolForKey("RegularRun") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "RegularRun")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if let _ = A0SimpleKeychain().stringForKey("PHPSESSID") {
                A0SimpleKeychain().deleteEntryForKey("PHPSESSID")
            }
            if let _ = A0SimpleKeychain().stringForKey("id") {
                A0SimpleKeychain().deleteEntryForKey("id")
            }
            if let _ = A0SimpleKeychain().stringForKey("password") {
                A0SimpleKeychain().deleteEntryForKey("password")
            }
            if let _ = A0SimpleKeychain().stringForKey("type") {
                A0SimpleKeychain().deleteEntryForKey("type")
            }
        }
        
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        if(closeStream)
        {
            // Post notifications to current controllers
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "Close/Leave", object: nil))
            
            // Dismiss all view controllers behind MainViewController
            let root = UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
            
            if root.topViewController!.presentedViewController != nil {
                root.topViewController!.presentedViewController!.dismissViewControllerAnimated(false, completion: nil)
            }
            
            let controllers = root.viewControllers.filter({ ($0 is LoginViewController) || ($0 is RootViewController) })
            root.setViewControllers(controllers, animated: false)
            
            self.bgTask = application.beginBackgroundTaskWithName("Disconnect Live Stream", expirationHandler: { () -> Void in
                application.endBackgroundTask(self.bgTask!)
                self.bgTask = UIBackgroundTaskInvalid
            })
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let task = self.bgTask {
            if (task != UIBackgroundTaskInvalid)
            {
                UIApplication.sharedApplication().endBackgroundTask(task)
                self.bgTask = UIBackgroundTaskInvalid;
            }
        }
        
        // Post notifications to current controllers
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "Open", object: nil))
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Notifications
    
    func registerForNotification() {
        let application = UIApplication.sharedApplication()
        
        if #available(iOS 8.0, *) {
                let types:UIUserNotificationType = ([.Alert, .Badge, .Sound])
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.NoData)
        
        if !UserContainer.shared.isLogged() {
            return
        }
        
        let uid = userInfo["uni-rcpt"] as! UInt
        if uid != UserContainer.shared.logged().id {
            return
        }
        
        let type = userInfo["uni-type"] as! UInt
        
        let name =
        (((userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)["loc-args"] as! NSArray)[0] as! String
        
        if type == 1 && name == UserContainer.shared.logged().name {
            return
        }
        
        notificationsDelegate.streamId = userInfo["uni-id"] as? UInt
        UIAlertView.notificationAlert(notificationsDelegate, userInfo: userInfo).show()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        /* Each byte in the data will be translated to its hex value like 0x01 or
        0xAB excluding the 0x part, so for 1 byte, we will need 2 characters to
        represent that byte, hence the * 2 */
        let tokenAsString = NSMutableString()
        
        /* Create a buffer of UInt8 values and then get the raw bytes
        of the device token into this buffer */
        var byteBuffer = [UInt8](count: deviceToken.length, repeatedValue: 0x00)
        deviceToken.getBytes(&byteBuffer)
        
        /* Now convert the bytes into their hex equivalent */
        for byte in byteBuffer {
            tokenAsString.appendFormat("%02hhX", byte)
        }
        
        self.deviceToken = tokenAsString as String
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        NSLog("%@",error.localizedDescription)
    }
}
