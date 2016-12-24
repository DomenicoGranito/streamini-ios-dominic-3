//
//  LegalViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 17/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

enum LegalViewControllerType {
    case TermsOfService
    case PrivacyPolicy
}

class LegalViewController: BaseViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    var type: LegalViewControllerType?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString: String
        switch type! {
        case .TermsOfService:
            urlString = Config.shared.legal().termsOfService
            self.title = NSLocalizedString("profile_terms", comment: "")
        case .PrivacyPolicy:
            urlString = Config.shared.legal().privacyPolicy
            self.title = NSLocalizedString("profile_privacy", comment: "")
        }
        
        let url = NSURL(string: urlString)!
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}
