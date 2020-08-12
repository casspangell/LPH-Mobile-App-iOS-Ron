//
//  LoginSocialNetworkController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase

class LoginSocialNetworkController: BaseViewController, IndicatorInfoProvider {
    
    // MARK: - Variables
    var loginControllerCallback: LoginControllerCallback?
    var splashDelegate: SplashDelegate?
    var loginEngine: SocialLoginEngine?
    
    // MARK: - IBOutets
    @IBOutlet weak var viewFBButtonContainer: UIView!
    @IBOutlet weak var buttonGoogleSignIn: GIDSignInButton!
    
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
    
    @IBAction func onTapGoogleSignIn(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .google)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    @IBAction func onTapSignInEmail(_ sender: UITapGestureRecognizer) {
        loginControllerCallback?.changeTab(index: 1)
    }
    
    @IBAction func onTapWithoutSignIn(_ sender: UITapGestureRecognizer) {
        let loginVo = LPHUtils.getLoginVo()
        loginVo.isLoggedIn = true
        loginVo.loginType = .withoutLogin
        LPHUtils.setLoginVo(loginVo: loginVo)
        navigateToHome()
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
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
    
    // MARK: - Navigation
    private func navigateToHome() {
        let homeTabController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab)
        present(homeTabController, animated: true, completion: nil)
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
                self.splashDelegate?.isFromLoginEnable()
                self.dismiss(animated: true, completion: nil)
            }
        } catch let error {
            
        }
    }
    
}
