//
//  PasswordViewController.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 07.06.16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class PasswordViewController: BaseViewController {

    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        
        currentPassword.placeholder = NSLocalizedString("current_password", comment: "")
        newPassword.placeholder = NSLocalizedString("new_password", comment: "")
        confirmPassword.placeholder = NSLocalizedString("confirm_password", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currentPassword.text = ""
        newPassword.text = ""
        confirmPassword.text = ""
    }
    
    func doneButtonPressed(sender: AnyObject) {
        
        if let _ = A0SimpleKeychain().stringForKey("password") {
            if(A0SimpleKeychain().stringForKey("password") != currentPassword.text){
                let alertView = UIAlertView.notAuthorizedAlert(NSLocalizedString("current_password_wrong", comment: ""))
                alertView.show()
                return
            }
        }
        
        if(newPassword.text != confirmPassword.text || newPassword.text == "")
        {
            let alertView = UIAlertView.notAuthorizedAlert(NSLocalizedString("passwords_do_not_match", comment: ""))
            alertView.show()
            return
        }
        
        let text: String
        text = newPassword.text!
        
        
        UserConnector().password(text, success: passwordSuccess, failure: passwordFailure)
    }

    func passwordSuccess() {
        let alertView = UIAlertView.notAuthorizedAlert(NSLocalizedString("password_changed", comment: ""))
        alertView.show()
        A0SimpleKeychain().setString(newPassword.text!, forKey: "password")
    }
    
    func passwordFailure(error: NSError) {
        self.handleError(error)
    }
}
