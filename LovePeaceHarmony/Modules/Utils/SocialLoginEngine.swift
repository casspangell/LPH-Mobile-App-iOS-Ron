//
//  SocialLoginUtils.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 27/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import FirebaseAuth

class SocialLoginEngine: NSObject, GIDSignInUIDelegate, GIDSignInDelegate {
    
    // MARK: - Variables
    var presentingViewController: UIViewController?
    var callbackDelegate: (LPHResponse<LoginVo, LoginError>) -> ()?
    
    init(_ viewController: UIViewController) {
        self.presentingViewController = viewController
        self.callbackDelegate = {_ in
            return nil
        }
        super.init()
        initGoogleDelegation()
    }
    
    func initiateLogin(_ loginType: LoginType,_ loginResponse: @escaping (LPHResponse<LoginVo, LoginError>) -> Void) throws {
        callbackDelegate = loginResponse
        do {
            if loginType == .google {
                initiateGoogleLogin()
            } else if loginType == .facebook {
                initiateFacebookLogin()
            }
        } catch _ as LPHException<LoginError> {
            throw LPHException<LoginError>(controllerError: .invalidCredentials)
        } catch {
            
        }
    }
    
    func initGoogleDelegation() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    private func initiateGoogleLogin() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func initiateFacebookLogin() {
        let loginManager = LoginManager()
//        loginManager.logIn(permissions: [.email], viewController: presentingViewController) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                print("Logged in!")
        
        if let _ = AccessToken.current { //user is already logged in
            print("Facebook logged out!")
            loginManager.logOut()
        } else { //user is logged out
            loginManager.logIn(permissions: [], from: presentingViewController) { (result, error) in
                // Check for error
                guard error == nil else {
                    // Error occurred
                    print(error!.localizedDescription)
                    return
                }
                //Check for cancel
                guard let result = result, !result.isCancelled else {
                    print("Facebook user cancelled login")
                    return
                }
                
                //Successful login
                print("Facebook logged in!")

                // User is signed in
                //Facebook Graph API
                let graphRequest:GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"first_name,last_name,email,picture.type(large)"])
                graphRequest.start(completionHandler: { (connection, result, error) -> Void in

                    if ((error) != nil) {
                        print("Error: \(error)")
                    } else {
                        let loginVo = LPHParser.parseFBLoginResponse(rawResponse: result!)
                        let golResponse = LPHResponse<LoginVo, LoginError>()
                        golResponse.setResult(data: loginVo)
                        self.callbackDelegate(golResponse)
                    }
                })
            } 
        }
 
        
//        loginManager.logIn(permissions: [.email], viewController: presentingViewController) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                print("Logged in!")
//                let graphRequest:GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"first_name,last_name,email,picture.type(large)"])
//
//                graphRequest.start(completionHandler: { (connection, result, error) -> Void in
//
//                    if ((error) != nil) {
//                        print("Error: \(error)")
//                    } else {
//                        let loginVo = LPHParser.parseFBLoginResponse(rawResponse: result!)
//                        let golResponse = LPHResponse<LoginVo, LoginError>()
//                        golResponse.setResult(data: loginVo)
//                        self.callbackDelegate(golResponse)
//                    }
//                })
//
//            }
//        }
    }
    
    // MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            let userId = user.userID                  // For client-side use only!
            let fullName = user.profile.name
            let email = user.profile.email
            let profilePicUrl = user.profile.imageURL(withDimension: 100).absoluteString
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.fullName = fullName!
            loginVo.password = userId!
            loginVo.profilePicUrl = profilePicUrl
            loginVo.loginType = .google
            loginVo.email = email!
            let response = LPHResponse<LoginVo, LoginError>()
            response.setResult(data: loginVo)
            callbackDelegate(response)
        } else {
            print(error.localizedDescription)
        }
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        presentingViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
