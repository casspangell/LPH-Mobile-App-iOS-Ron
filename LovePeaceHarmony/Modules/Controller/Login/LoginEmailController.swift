//
//  LoginEmailController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase

class LoginEmailController: BaseViewController, IndicatorInfoProvider, UITextFieldDelegate {
    
    // MARK: - Variables
    var loginControllerCallback: LoginControllerCallback?
    var splashDelegate: SplashDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initView() {
        super.initView()
//        textFieldEmail.autocorrectionType = .no
//        textFieldPassword.autocorrectionType = .no
//        if #available(iOS 11, *) {
//            // Disables the password autoFill accessory view.
//            textFieldEmail.textContentType = UITextContentType("")
//            textFieldPassword.textContentType = UITextContentType("")
//        }
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let yValue = textField.layer.frame.maxY + 15
        animateViewMoving(true, moveValue: yValue)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let yValue = textField.layer.frame.maxY + 15
        animateViewMoving(false, moveValue: yValue)
    }
    
    // MARK: - IBActions
    @IBAction func onTapBack(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        loginControllerCallback?.changeTab(index: 0)
    }
    
    @IBAction func onTapSignIn(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        do {
            try validateForm()
        } catch let error as LPHException<LoginError> {
            showToast(message: error.errorMessage)
        } catch {
            
        }
    }
    
    @IBAction func onTapCreateAccount(_ sender: UITapGestureRecognizer) {
        loginControllerCallback?.changeTab(index: 2)
    }
    
    
    // MARK: - Actions
    func animateViewMoving (_ up:Bool, moveValue :CGFloat) {
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        loginControllerCallback?.moveScreen(dx: 0, dy: movement)
    }
    
    private func validateForm() throws {
        guard let email = textFieldEmail.text, email != "" else {
            throw LPHException<LoginError>(controllerError: .emptyEmail)
        }
        
        if !LPHUtils.isValidEmail(email: email) {
            throw LPHException<LoginError>(controllerError: .invalidEmail)
        }
        
        guard let password = textFieldPassword.text, password != "" else {
            throw LPHException<LoginError>(controllerError: .emptyPassword)
        }
        
        try fireLoginApi(email, password, "")
    }
    
    private func processLoginResponse(fromServer response: LPHResponse<ProfileVo, LoginError>, password: String) {
        if response.isSuccess() {
            let loginVo = LPHUtils.getLoginVo()
            let profileVo = response.getResult()
            print(profileVo.name)
            loginVo.email = profileVo.email
            loginVo.fullName = profileVo.name
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.isLoggedIn = true
            loginVo.inviteCode = profileVo.inviteCode
            loginVo.password = password
            loginVo.loginType = .email
            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
            self.fireUpdateTokenApi()
            
        } else {
            showAlert(title: "", message: response.getServerMessage(), vc: self)
        }
        hideLoadingIndicator()
    }
    
    // MARK: - Apis
    private func fireLoginApi(_ email: String, _ password: String,_ deviceToken: String) throws {
        showLoadingIndicator()
        do {
            let lphService = try LPHServiceFactory<LoginError>.getLPHService()
            try lphService.fireLogin(email: email, password: password, deviceId: deviceToken, source: .email) { (parsedResponse) in
                self.processLoginResponse(fromServer: parsedResponse, password: password)
            }
        } catch let error {
            
        }
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
                self.splashDelegate?.isFromLoginEnable()
                self.dismiss(animated: true, completion: nil)
                self.navigateToHome()
            }
        } catch let error {
            
        }
    }
    
    
    
    // MARK: - Navigation
    private func navigateToHome() {
        let homeTabController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab)
        present(homeTabController, animated: true, completion: nil)
    }
    
}
