//
//  SignUpEmailController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase

class SignUpEmailController: BaseViewController, IndicatorInfoProvider, UITextFieldDelegate {
    
    // MARK: - Variables
    var loginControllerCallback: LoginControllerCallback?
    var splashDelegate: SplashDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldName.delegate = self
        textFieldName.autocorrectionType = .no
        
        textFieldEmail.delegate = self
        textFieldEmail.autocorrectionType = .no
        
        textFieldPassword.delegate = self
        textFieldPassword.autocorrectionType = .no
        
        textFieldConfirmPassword.delegate = self
        textFieldConfirmPassword.autocorrectionType = .no
        
        if #available(iOS 11, *) {
            // Disables the password autoFill accessory view.
            textFieldName.textContentType = UITextContentType("")
            textFieldEmail.textContentType = UITextContentType("")
            textFieldPassword.textContentType = UITextContentType("")
            textFieldConfirmPassword.textContentType = UITextContentType("")
        }
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldName {
            textFieldEmail.becomeFirstResponder()
        } else if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        } else if textField == textFieldPassword {
            textFieldConfirmPassword.becomeFirstResponder()
        } else if textField == textFieldConfirmPassword {
            textField.resignFirstResponder()
        }
        return true
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
        loginControllerCallback?.changeTab(index: 1)
    }
    
    @IBAction func onTapCreateAccount(_ sender: UITapGestureRecognizer) {
        do {
            try validateForm()
        } catch let error as LPHException<LoginError> {
            showToast(message: error.errorMessage)
        } catch {
            
        }
    }
    
    // MARK: - Actions
    private func validateForm() throws {
        guard let name = textFieldName.text, name != "" else {
            throw LPHException<LoginError>(controllerError: .emptyName)
        }
        
        guard let email = textFieldEmail.text, email != "" else {
            throw LPHException<LoginError>(controllerError: .emptyEmail)
        }
        
        if !LPHUtils.isValidEmail(email: email) {
            throw LPHException<LoginError>(controllerError: .invalidEmail)
        }
        
        guard let password = textFieldPassword.text, password != "" else {
            throw LPHException<LoginError>(controllerError: .emptyPassword)
        }
        
        guard let confirmPassword = textFieldConfirmPassword.text, confirmPassword != "" else {
            throw LPHException<LoginError>(controllerError: .emptyConfirmPassword)
        }
        
        if password != confirmPassword {
            throw LPHException<LoginError>(controllerError: .passwordDoNotMatch)
        }
      
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            self.fireSocialLoginRegisterApi(email: email, password: password, name: name, deviceId: result.token)
         }
        }
        
        
        
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        loginControllerCallback?.moveScreen(dx: 0, dy: movement)
    }
    
    private func processLoginResponse(serverResponse response: LPHResponse<ProfileVo, LoginError>, password: String) {
        if response.isSuccess() {
            let profileVo = response.getResult()
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.email = profileVo.email
            loginVo.password = password
            loginVo.fullName = profileVo.name
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.loginType = .email
            loginVo.inviteCode = profileVo.inviteCode
            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
            self.fireUpdateTokenApi()
        }
    }
    
    // MARK: - Apis
    private func fireSocialLoginRegisterApi(email: String,password: String, name: String, deviceId: String) {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<LoginError>.getLPHService()
            lphService.fireLoginRegister(email: email, password: password, name: name, profilePicUrl: "", source: .email, deviceId: deviceId) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.processLoginResponse(serverResponse: lphResponse, password: password)
                }
                self.hideLoadingIndicator()
            }
        } catch let error {
            
        }
    }
    
    private func fireUpdateTokenApi() {
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            let deviceInfo = DEVICE_INFO
            self.showLoadingIndicator()
            do {
                let lphService = try LPHServiceFactory<LoginError>.getLPHService()
                try lphService.updateDeviceToken(token: result.token, info: deviceInfo) { (parsedResponse) in
                    self.splashDelegate?.isFromLoginEnable()
                    self.dismiss(animated: true, completion: nil)
                }
            } catch let error {
                
            }
         }
        }

    }
    
}
