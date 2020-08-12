//
//  ProfileLoginController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 05/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import Firebase

class ProfileLoginController: BaseViewController {
    
    // MARK: - Variables
    var loginCallback: ProfileLoginCallback?
    var loginEngine: SocialLoginEngine?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        loginEngine = SocialLoginEngine(self)
    }

    // MARK: - IBActions
    @IBAction func onTapFacebookLogin(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .facebook)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    @IBAction func onTapGoogleLogin(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .google)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    @IBAction func onTapEmailLogin(_ sender: UITapGestureRecognizer) {
        navigateToEmailLogin()
    }
    
    // MARK: - Actions
    private func initiateLogin(type: LoginType) {
        do {
            try loginEngine?.initiateLogin(type) { (lphResponse) in
                if lphResponse.isSuccess() {
                    let loginVo = lphResponse.getResult()
                    let firebaseDeviceToken = FIRInstanceID.instanceID().token()
                    self.fireSocialLoginRegisterApi(email: loginVo.email, password: loginVo.password, name: loginVo.fullName, profilePic: loginVo.profilePicUrl, source: type, deviceId: firebaseDeviceToken!)
                } else {
                    
                }
            }
        } catch let exception as LPHException<LoginError> {
            
        } catch {
            
        }
    }
    
    private func processLoginResponse(source loginType: LoginType, password: String, serverResponse response: LPHResponse<ProfileVo, LoginError>) {
        if response.isSuccess() {
            
            let profileVo = response.getResult()
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.email = profileVo.email
            loginVo.password = password
            loginVo.fullName = profileVo.name
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.loginType = loginType
            loginVo.inviteCode = profileVo.inviteCode
            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
            fireUpdateTokenApi()
        }
    }
    
    // MARK: - Apis
    private func fireSocialLoginRegisterApi(email: String,password: String, name: String, profilePic: String, source: LoginType, deviceId: String) {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<LoginError>.getLPHService()
            lphService.fireLoginRegister(email: email, password: password, name: name, profilePicUrl: profilePic, source: source, deviceId: deviceId) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.processLoginResponse(source: source, password: password, serverResponse: lphResponse)
                }
                self.hideLoadingIndicator()
            }
        } catch let error {
            
        }
    }
    
    private func fireUpdateTokenApi() {
        let deviceToken = FIRInstanceID.instanceID().token()!
        let deviceInfo = DEVICE_INFO
        showLoadingIndicator()
        do {
            let lphService = try LPHServiceFactory<LoginError>.getLPHService()
            try lphService.updateDeviceToken(token: deviceToken, info: deviceInfo) { (parsedResponse) in
                self.hideLoadingIndicator()
                self.loginCallback?.loginCallback()
            }
        } catch let error {
            
        }
    }
    
    // MARK: - Navigations
    private func navigateToEmailLogin() {
        let loginController = storyboard?.instantiateViewController(withIdentifier: ViewController.login) as! LoginController
        loginController.isFromProfileController = true
        present(loginController, animated: true, completion: nil)
    }
}
