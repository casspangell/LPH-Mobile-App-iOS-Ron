//
//  ProfileLoginController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 05/12/17.
//  Updated by Cass Pangell on 3/23/20.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import Firebase

class ProfileLoginController: BaseViewController {
    
    // MARK: - Variables
    var loginCallback: ProfileLoginCallback?
//    var loginEngine: SocialLoginEngine?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
//        loginEngine = SocialLoginEngine(self)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        showLoadingIndicator()
        
        do {
          try firebaseAuth.signOut()
       
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        self.hideLoadingIndicator()
        self.navigateToHome()
    }
    


    
    // MARK: - Apis
//    private func fireSocialLoginRegisterApi(email: String,password: String, name: String, profilePic: String, source: LoginType, deviceId: String) {
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
//
//        }
//    }
    
//    private func fireUpdateTokenApi() {
//
//        InstanceID.instanceID().instanceID { (result, error) in
//        if let error = error {
//        print("Error fetching remote instange ID: \(error)")
//        } else if let result = result {
//        print("Remote instance ID token: \(result.token)")
//            let deviceInfo = DEVICE_INFO
//            self.showLoadingIndicator()
//            do {
//                let lphService = try LPHServiceFactory<LoginError>.getLPHService()
//                try lphService.updateDeviceToken(token: result.token, info: deviceInfo) { (parsedResponse) in
//                    self.hideLoadingIndicator()
//                    self.loginCallback?.loginCallback()
//                }
//            } catch let error {
//
//            }
//         }
//        }
//
//
//    }
//
//    // MARK: - Navigations
//    private func navigateToEmailLogin() {
//        let loginController = storyboard?.instantiateViewController(withIdentifier: ViewController.login) as! LoginController
//        loginController.isFromProfileController = true
//        present(loginController, animated: true, completion: nil)
//    }
    
    // MARK: - Navigation
    private func navigateToHome() {
        let homeTabController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab)
        present(homeTabController, animated: true, completion: nil)
    }
}
