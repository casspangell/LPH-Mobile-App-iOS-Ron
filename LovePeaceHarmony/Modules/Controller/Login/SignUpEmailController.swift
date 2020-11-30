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
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
        textFieldConfirmPassword.delegate = self
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        } else if textField == textFieldPassword {
            textFieldConfirmPassword.becomeFirstResponder()
        } else if textField == textFieldConfirmPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        let yValue = textField.layer.frame.maxY + 15
//        animateViewMoving(true, moveValue: yValue)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        let yValue = textField.layer.frame.maxY + 15
//        animateViewMoving(false, moveValue: yValue)
    }
    
    // MARK: - IBActions
    @IBAction func onTapBack(_ sender: UITapGestureRecognizer) {
        loginControllerCallback?.changeTab(index: 0)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        do {
            try validateForm()
        } catch let error as LPHException<LoginError> {
            showToast(message: error.errorMessage)
        } catch {
            
        }
    }
    
    // MARK: - Actions
    private func validateForm() throws {
        
        guard let email = textFieldEmail.text, email != "" else {
            throw LPHException<LoginError>(controllerError: .emptyEmail)
        }
        
        if !LPHUtils.isValidEmail(email: email) {
            throw LPHException<LoginError>(controllerError: .invalidEmail)
        }
        
        guard let passwordLength = textFieldPassword.text, passwordLength.count >= 6 else {
            throw LPHException<LoginError>(controllerError: .passwordLength)
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
            self.fireSocialLoginRegisterApi(email: email, password: password, deviceId: result.token)
         }
        }
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        loginControllerCallback?.moveScreen(dx: 0, dy: movement)
    }
    
//    private func processLoginResponse(serverResponse response: LPHResponse<ProfileVo, LoginError>, password: String) {
    private func processLoginResponse(email: String, password: String) {
//        if response.isSuccess() {
//            let profileVo = response.getResult()
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.email = email
            loginVo.password = password
//            loginVo.fullName = profileVo.name
//            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.loginType = .email
//            loginVo.inviteCode = profileVo.inviteCode
//            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
            self.fireUpdateTokenApi()
//        }
    }
    
    // MARK: - Apis
    private func fireSocialLoginRegisterApi(email: String,password: String, deviceId: String) {

    //Create New User
      Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in

          if let error = error {
            let authError = error as NSError
            self!.showAlert(title: "Error", message: authError.localizedDescription, vc: self!)
          }else{

            print("\(email) created")
            self?.processLoginResponse(email: email, password: password)
          }
        }
    }
    
    private func fireUpdateTokenApi() {
        self.showLoadingIndicator()
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            let deviceInfo = DEVICE_INFO
            do {
                self.hideLoadingIndicator()
                self.splashDelegate?.isFromLoginEnable()
                self.navigateToHome()
            } catch let error {
                self.hideLoadingIndicator()
            }
         }
        }
    }
    
    // MARK: - Navigation
    private func navigateToHome() {
        let homeTabController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab)
        present(homeTabController, animated: true, completion: nil)
    }
    
}
