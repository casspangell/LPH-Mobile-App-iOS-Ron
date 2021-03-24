//
//  LoginSocialNetworkController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Last Updated by Cass Pangell on 12/30/20.
//  Copyright © 2020 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import FBSDKLoginKit

class LoginSocialNetworkController: BaseViewController, IndicatorInfoProvider, LoginButtonDelegate {
    
    /** @var handle
        @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: AuthStateDidChangeListenerHandle?

    // MARK: - Variables
    var loginControllerCallback: LoginControllerCallback?
    var splashDelegate: SplashDelegate?
    var loginEngine: SocialLoginEngine?
    
    // MARK: - IBOutets
    
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        loginEngine = SocialLoginEngine(self)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    }
    
    
    @IBAction func loginWithEmailPressed(_ sender: Any) {
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
            self.showToast(message: "email/password can't be empty")
              return
            }
        
        self.showLoadingIndicator()
           
              Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in

                self?.hideLoadingIndicator()

                  if let error = error {
                    let authError = error as NSError
                    self?.showToast(message: error.localizedDescription)
                  } else {
                    //Login success
                    self!.navigateToHome()
                  }
                }
            
    }
    
    @IBAction func facebookLoginPressed(_ sender: Any) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .facebook)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    @IBAction func googleLoginPressed(_ sender: Any) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .google)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        loginControllerCallback?.changeTab(index: 2)
    }
    
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - Login Methods
    // Facebook Login
    //ARE THESE BEING USED?
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("Logged into Facebook")
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logged out of Facebook")
    }
    
    // ------
    
    private func initiateLogin(type: LoginType) {
        var firebaseDeviceToken = String()
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            firebaseDeviceToken = result.token
         }
        }

        do {
            try loginEngine?.initiateLogin(type) { (lphResponse) in
                if lphResponse.isSuccess() {
                    let loginVo = lphResponse.getResult()
    
                    self.processLoginResponse(source: type, password: loginVo.password, token: firebaseDeviceToken)
                } else {

                }
            }
        } catch let exception as LPHException<LoginError> {

        } catch {

        }
    }
    
    private func processLoginResponse(source loginType: LoginType, password: String, token: String) {
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.loginType = loginType
            loginVo.password = password
            loginVo.token = token
            LPHUtils.setLoginVo(loginVo: loginVo)
            
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
        
            self.navigateToHome()
    }
    
    //Original method with the API
//    private func processLoginResponse(source loginType: LoginType, password: String, serverResponse response: LPHResponse<ProfileVo, LoginError>) {
//        if response.isSuccess() {
//
//            let profileVo = response.getResult()
//            let loginVo = LPHUtils.getLoginVo()
//            loginVo.isLoggedIn = true
//
//            loginVo.email = profileVo.email
//            loginVo.password = password
//            loginVo.fullName = profileVo.name
//            loginVo.profilePicUrl = profileVo.profilePic
//            loginVo.loginType = loginType
//            loginVo.inviteCode = profileVo.inviteCode
//            loginVo.token = response.getMetadata() as! String
//            LPHUtils.setLoginVo(loginVo: loginVo)
//            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
//            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
//            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
//            fireUpdateTokenApi()
//        }
//    }
    
    // MARK: - Navigation
    private func navigateToHome() {
        let homeTabController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab)
        present(homeTabController, animated: true, completion: nil)
    }
    
    // MARK: - Apis
    private func fireSocialLoginRegisterApi(email: String,password: String, name: String, profilePic: String, source: LoginType, deviceId: String) {
//        showLoadingIndicator()
//        do {
//            let lphService: LPHService = try LPHServiceFactory<LoginError>.getLPHService()
//            lphService.fireLoginRegister(email: email, password: password, name: name, profilePicUrl: profilePic, source: source, deviceId: deviceId) { (lphResponse) in
//                if lphResponse.isSuccess() {
//                    self.processLoginResponse(source: source, password: password, serverResponse: lphResponse)
//                }
//                self.hideLoadingIndicator()
//            }
//        } catch let error {
//            print(error.localizedDescription)
//        }
    }
    
    private func fireUpdateTokenApi() {
        var deviceToken = String()
        let deviceInfo = DEVICE_INFO
        showLoadingIndicator()

        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            deviceToken = result.token
         }
        }

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
