//
//  ProfileTabController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 05/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit

class ProfileTabController: BaseViewController, SignOutCallback, ProfileLoginCallback {
    
    // MARK: - Variable
    var profileLoginController: ProfileLoginController?
    var previousLoginType: LoginType?
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginVo = LPHUtils.getLoginVo()
        previousLoginType = loginVo.loginType
        checkLoginAndPopulateView(loginVo.isLoggedIn, loginVo.loginType)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.loginType != previousLoginType && profileLoginController != nil {
            profileLoginController?.removeFromParentViewController()
            checkLoginAndPopulateView(true, loginVo.loginType)
        }
    }
    
    // MARK: - Actions
    private func checkLoginAndPopulateView(_ isLoggedIn: Bool, _ loginType: LoginType) {
        if isLoggedIn && loginType != .withoutLogin {
            let profileController = storyboard?.instantiateViewController(withIdentifier: ViewController.profile) as! ProfileController
            addChildViewController(profileController)
            profileController.view.frame = viewContainer.bounds
            viewContainer.addSubview(profileController.view)
            profileController.didMove(toParentViewController: self)
            profileLoginController = nil
        } else {
            profileLoginController = LPHUtils.getStoryboard(type: .login).instantiateViewController(withIdentifier: ViewController.profileLogin) as! ProfileLoginController
            profileLoginController?.loginCallback = self
            addChildViewController(profileLoginController!)
            profileLoginController?.view.frame = viewContainer.bounds
            viewContainer.addSubview((profileLoginController?.view)!)
            profileLoginController?.didMove(toParentViewController: self)
        }
        
    }
    
    // Callback
    func signOutCallback() {
//        checkLoginAndPopulateView()
    }
    
    func loginCallback() {
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.loginType != previousLoginType && profileLoginController != nil {
            profileLoginController?.removeFromParentViewController()
            checkLoginAndPopulateView(true, loginVo.loginType)
        }
    }
    

}

// MARK: - Protocol
protocol SignOutCallback {
    func signOutCallback()
}

protocol ProfileLoginCallback {
    func loginCallback()
}
