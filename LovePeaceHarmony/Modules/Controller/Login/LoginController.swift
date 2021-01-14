//
//  ViewController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDynamicLinks

class LoginController: ButtonBarPagerTabStripViewController, LoginControllerCallback, UIGestureRecognizerDelegate {

    // MARK: - Variables
    var viewControllerList = [UIViewController]()
    var isFromProfileController = false
    var splashDelegate: SplashDelegate?
    
    // MARK: - IBProperties
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var imageViewCover: UIImageView!
    
    // MARK: -View
    override func viewDidLoad() {
//        checkForUserInvite()
        imageViewCover.contentMode = UIViewContentMode.scaleAspectFill
        self.view.isUserInteractionEnabled = true
        scrollViewContainer.isScrollEnabled = false
        containerView = scrollViewContainer
        settings.style.buttonBarHeight = 0
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        tap.cancelsTouchesInView = true
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    
    
    // MARK: -
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var returnSuccess = true
        if touch.view is GIDSignInButton {
            returnSuccess = false
        }
        return returnSuccess
    }
    
    // MARK: - XLPagerTabStrip
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return generateTabs()
    }
    
    //MARK: - IBActions

    
    
    // MARK: - Actions
    private func generateTabs() -> [UIViewController] {
        
        if !isFromProfileController {
            let socialNetworkController = storyboard?.instantiateViewController(withIdentifier: ViewController.loginSocialNetwork) as! LoginSocialNetworkController
            socialNetworkController.loginControllerCallback = self
            socialNetworkController.splashDelegate = splashDelegate
            viewControllerList.append(socialNetworkController)
        }
        
        let emailLoginController = storyboard?.instantiateViewController(withIdentifier: ViewController.loginEmail) as! LoginEmailController
        emailLoginController.loginControllerCallback = self
        emailLoginController.splashDelegate = splashDelegate
        
        let signUpEmailController = storyboard?.instantiateViewController(withIdentifier: ViewController.signUp) as! SignUpEmailController
        signUpEmailController.loginControllerCallback = self
        signUpEmailController.splashDelegate = splashDelegate
        
        viewControllerList.append(contentsOf: [emailLoginController, signUpEmailController])
        return viewControllerList
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func checkForUserInvite() {
        
//        let link = LPHUrl.INVITE_LINK + 
        
        
        
        /*print("------------------------123")
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            print("returning")
            return
        }
        let link = LPHUrl.INVITE_LINK + uid
        let referralLink = FIRDynamicLinkComponents(link: URL(string: link)!, domain: DYNAMIC_LINK_DOMAIN)
        referralLink.iOSParameters = FIRDynamicLinkIOSParameters(bundleID: LPH_IOS_BUNDLE_ID)
        referralLink.iOSParameters?.minimumAppVersion = "1.0"
        referralLink.iOSParameters?.appStoreID = "123456789"
        
        referralLink.androidParameters = FIRDynamicLinkAndroidParameters(packageName: LPH_ANDROID_BUNDLE_ID)
        referralLink.androidParameters?.minimumVersion = 1
        print("here")
        referralLink.shorten { (shortURL, warnings, error) in
            print("inside")
            if let error = error {
                print("returning")
                print(error.localizedDescription)
                return
            }
            print("invitation link: \(shortURL)")
        }
        print("completed")
        */
    }
    
    private func generateInvite() {
        /*guard let referrerName = Auth.auth().currentUser?.displayName else { return }
        let subject = "\(referrerName) wants you to play MyExampleGame!"
        let invitationLink = invitationUrl?.absoluteString
        let msg = "<p>Let's play MyExampleGame together! Use my <a href=\"\(invitationLink)\">referrer link</a>!</p>"
        
        if !MFMailComposeViewController.canSendMail() {
            // Device can't send email
            return
        }
        let mailer = MFMailComposeViewController()
        mailer.mailComposeDelegate = self
        mailer.setSubject(subject)
        mailer.setMessageBody(msg, isHTML: true)
        myView.present(mailer, animated: true, completion: nil)*/
    }
    
    // MARK: - Api
    private func initLoginApi() {
        
        
    }
    
    // MARK: - Callback
    func changeTab(index: Int) {
        print(index)
        print(currentIndex)
        if isFromProfileController {
            if index == 0 && currentIndex == 0 {
                dismiss(animated: true, completion: nil)
            } else {
                if index == 2 && currentIndex == 0 {
                    moveToViewController(at: 1)
                } else {
                    moveToViewController(at: 0)
                }
            }
        } else {
            moveToViewController(at: index)
        }
        
    }
    
    func moveScreen(dx: CGFloat, dy: CGFloat) {
        let movementDuration:TimeInterval = 0.3
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: dx, dy: dy)
        UIView.commitAnimations()
    }

}

// MARK: Protocol
protocol LoginControllerCallback {
    func changeTab(index: Int)
    func moveScreen(dx: CGFloat, dy: CGFloat)
}

// MARK: Enum
public enum LoginType: Int {
    case none = 0
    case email
    case facebook
    case google
    case withoutLogin
}
