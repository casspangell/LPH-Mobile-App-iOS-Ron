//
//  SplashController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import Firebase

class SplashController: BaseViewController, SplashDelegate {

    // MARK: - Variable
    var navigationFromLogin = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageViewChant: UIImageView!
    
    // MARK: - View
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageViewChant.contentMode = UIViewContentMode.scaleAspectFill
        checkLogin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        hideLoadingIndicator()
    }
    
    
    // MARK: - Actions
    private func checkLogin() {
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.isLoggedIn {
            if navigationFromLogin || !LPHUtils.isConnectedToNetwork(showAlert: false, vc: self) || loginVo.loginType == .withoutLogin {
                navigationFromLogin = false
                navigateToHome()
            } else {
                fireLoginApi(savedLoginDetails: loginVo)
            }
        } else {
            navigateToLogin()
        }
    }
    
    private func processLoginResponse(fromServer response: LPHResponse<ProfileVo, LoginError>, password: String) {
        if response.isSuccess() {
            let loginVo = LPHUtils.getLoginVo()
            let profileVo = response.getResult()
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.isLoggedIn = true
            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            navigateToHome()
        } else {
            showAlert(title: "", message: response.getServerMessage(), vc: self)
        }
        hideLoadingIndicator()
    }
    
    // MARK: - SplashDelegate
    func isFromLoginEnable() {
        navigationFromLogin = true
    }
    
    // MARK: - Apis
    private func fireLoginApi(savedLoginDetails: LoginVo) {
        let email = savedLoginDetails.email
        let password = savedLoginDetails.password
        
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            do {
                let lphService = try LPHServiceFactory<LoginError>.getLPHService()
                try lphService.fireLogin(email: email, password: password, deviceId: result.token, source: savedLoginDetails.loginType) { (parsedResponse) in
                    self.processLoginResponse(fromServer: parsedResponse, password: password)
                }
            } catch let error {
                
            }
         }
        }
        

    }

    // MARK: - Navigation
    private func navigateToLogin() {
        let loginController = storyboard?.instantiateViewController(withIdentifier: ViewController.login) as! LoginController
        loginController.splashDelegate = self
        present(loginController, animated: true, completion: nil)
    }
    
    private func navigateToHome() {
        let homeController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab) as! HomeTabController
        present(homeController, animated: true, completion: nil)
    }
}

// MARK: - Protocol
protocol SplashDelegate {
    func isFromLoginEnable()
}
