//
//  AppDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,WXApiDelegate{

    var window: UIWindow?
    var deviceToken: String?
    var notificationsDelegate = NotificationsDelegate()
    var bgTask: UIBackgroundTaskIdentifier?
    var closeStream: Bool = false

    
    
    //dominicg weixin login wx68aa08d12b601234 dgranito@gmail account
    //wx282a923ebe81d445 demo account
    //AppID：wx5bd67c93b16ab684 marie@cedricm.com account
    //wxa0bd27aed1120e15 testing account login
    
    private let appID = "wx5bd67c93b16ab684"
    private let appSecret = "1710a218426502adfbf7352fdd451c9b"
    
    private let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
    
    private func buildAccessTokenLink(withCode code: String) -> String {
        
        return accessTokenPrefix + "appid=" + appID + "&secret=" + appSecret + "&code=" + code + "&grant_type=authorization_code"
        
    }
    //end weixin login
    
    
    
    
    
    
    var documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    // this will be used when opening Webview from playlist
    var downloadTable : downloadTableViewControllerDelegate?
    var dataDownloader : DataDownloader?
    
    
    
    private func addCustomMenuItems() {
        
        let menuController = UIMenuController.sharedMenuController()
        var menuItems = menuController.menuItems ?? [UIMenuItem]()
        
        let copyLinkItem = UIMenuItem(title: "Copy Link", action: MenuAction.copyLink.selector())
        let saveVideoItem = UIMenuItem(title: "Save to Camera Roll", action: MenuAction.saveVideo.selector())
        
        menuItems.append(copyLinkItem)
        menuItems.append(saveVideoItem)
        menuController.menuItems = menuItems
    }
    
    func applicationWillResignActive(application: UIApplication) {
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
        //disable video tracks to allow background audio play
        NSNotificationCenter.defaultCenter().postNotificationName("enteredBackgroundID", object: nil)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
        //renable video tracks
        NSNotificationCenter.defaultCenter().postNotificationName("enteredForegroundID", object: nil)
    }
    
   
    
    func applicationWillTerminate(application: UIApplication) {
        
        //remove excess documents and data
        let cacheFolder = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        var dirsToClean : [String] = []
        
        dirsToClean += [(cacheFolder as NSString).stringByAppendingPathComponent("/com.uniprogy.dominic/fsCachedData/"),
                        (cacheFolder as NSString).stringByAppendingPathComponent("/com.apple.nsurlsessiond/"),
                        (cacheFolder as NSString).stringByAppendingString("/WebKit/"),
                        NSTemporaryDirectory()]
        
        for dir : String in dirsToClean{
            MiscFuncs.deleteFiles(dir)
        }
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Music_Player" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Music_Player", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Music_Player.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
            addCustomMenuItems()
           
              
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
        //UIApplication.sharedApplication().statusBarStyle = .LightContent
      //  UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.init(rawValue: <#T##Int#>)
       // UIApplication.sharedApplication().statusBarStyle = .Black
     //   UIApplication.sharedApplication().statusBarStyle = .Default
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

       // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
        
       // UINavigationBar.appearance().backgroundColor = UIColor.whiteColor()
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

   
   // func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //}

   // func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   // }

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

   // func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   // }

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
    
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func onReq(req: BaseReq!) {
        // do optional stuff
    }
    
    func onResp(resp: BaseResp!) {
        
        if let authResp = resp as? SendAuthResp {
            
            if authResp.code != nil {
                
                let dict = ["response": authResp.code]
                NSNotificationCenter.defaultCenter().postNotificationName("WeChatAuthCodeResp", object: nil, userInfo: dict)
                
            } else {
                
                let dict = ["response": "Fail"]
                NSNotificationCenter.defaultCenter().postNotificationName("WeChatAuthCodeResp", object: nil, userInfo: dict)
                
            }
            
        } else {
            
            let dict = ["response": "Fail"]
            NSNotificationCenter.defaultCenter().postNotificationName("WeChatAuthCodeResp", object: nil, userInfo: dict)
        }
    }

}
