//
//  LoginViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LoginViewController: BaseViewController
{
    @IBOutlet var usernameTxt:UITextField?
    @IBOutlet var passwordTxt:UITextField?
    @IBOutlet var usernameImageView:UIImageView?
    @IBOutlet var passwordImageView:UIImageView?
    @IBOutlet var usernameBackgroundView:UIView?
    @IBOutlet var passwordBackgroundView:UIView?
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        usernameImageView?.image=usernameImageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        passwordImageView?.image=passwordImageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        usernameImageView?.tintColor=UIColor.darkGrayColor()
        passwordImageView?.tintColor=UIColor.darkGrayColor()
        
        if let _=A0SimpleKeychain().stringForKey("PHPSESSID")
        {
            UserConnector().get(nil, success:successUser, failure:forgotFailure)
            
            let vc=storyBoard.instantiateViewControllerWithIdentifier("RootViewControllerId")
            navigationController?.pushViewController(vc, animated:false)
        }
    }
    
    
    
    @IBAction func wechat_login()
    {
        // WeChat: replace with your AppID
        //        WXApi.registerApp("wx68aa08d12b601234")
        let appID = "wx5bd67c93b16ab684"

        WXApi.registerApp(appID);
        
        
        //weixin login
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo" //Important that this is the same
        req.state = "com.uniprogy.dominic_wx_login" //This can be any random value
        WXApi.sendReq(req)
        
        
        
        //end login weixin
        

    }
    @IBAction func login()
    {
        let loginData=NSMutableDictionary()
        
        loginData["id"]=usernameTxt!.text!
        loginData["password"]=passwordTxt!.text!
        loginData["token"]="2"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(usernameTxt!.text!, forKey:"id")
        A0SimpleKeychain().setString(passwordTxt!.text!, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        
        if let deviceToken=(UIApplication.sharedApplication().delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        let connector=UserConnector()
        connector.login(loginData, success:loginSuccess, failure:forgotFailure)
    }
    
    func loginSuccess(session:String)
    {
        A0SimpleKeychain().setString(session, forKey:"PHPSESSID")
        
        UserConnector().get(nil, success:successUser, failure:forgotFailure)
        
        let vc=storyBoard.instantiateViewControllerWithIdentifier("RootViewControllerId")
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func successUser(user:User)
    {
        UserContainer.shared.setLogged(user)
    }
    
    @IBAction func forgotPassword()
    {
        if(usernameTxt?.text=="")
        {
            let alertView=UIAlertView.notAuthorizedAlert("Please enter your username")
            alertView.show()
        }
        else
        {
            let connector=UserConnector()
            connector.forgot(usernameTxt!.text!, success:forgotSuccess, failure:forgotFailure)
        }
    }
    
    func forgotSuccess()
    {
        let alertView=UIAlertView.notAuthorizedAlert("Password reset")
        alertView.show()
    }
    
    func forgotFailure(error:NSError)
    {
        handleError(error)
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField:UITextField)->Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField:UITextField)->Bool
    {
        if(textField==usernameTxt)
        {
            usernameBackgroundView?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            passwordBackgroundView?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            usernameImageView?.tintColor=UIColor.whiteColor()
            passwordImageView?.tintColor=UIColor.darkGrayColor()
        }
        else
        {
            passwordBackgroundView?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            usernameBackgroundView?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            usernameImageView?.tintColor=UIColor.darkGrayColor()
            passwordImageView?.tintColor=UIColor.whiteColor()
        }
        
        return true
    }
}
