//
//  SocialLoginUtils.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 27/12/17.
//  Updated by Cass Pangell on 8/28/2021.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import FirebaseAuth
import Firebase

//class SocialLoginEngine: NSObject, GIDSignInUIDelegate, GIDSignInDelegate {
class SocialLoginEngine: NSObject {
    
    // MARK: - Variables
    var presentingViewController: UIViewController?
    var callbackDelegate: (LPHResponse<LoginVo, LoginError>) -> ()?
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    init(_ viewController: UIViewController) {
        self.presentingViewController = viewController
        self.callbackDelegate = {_ in
            return nil
        }
        super.init()
//        initGoogleDelegation()
    }
    
    func initiateLogin(_ loginType: LoginType,_ loginResponse: @escaping (LPHResponse<LoginVo, LoginError>) -> Void) throws {
        callbackDelegate = loginResponse
        do {
            if loginType == .google {
                initiateGoogleLogin()
            } else if loginType == .facebook {
                initiateFacebookLogin()
            } else if loginType == .apple {
                initiateAppleLogin()
            }
        } catch _ as LPHException<LoginError> {
            throw LPHException<LoginError>(controllerError: .invalidCredentials)
        } catch {
            
        }
    }
    
    
    private func initiateAppleLogin() {
        
        
    }
    
    private func initiateGoogleLogin() {

        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let presentingViewController = (UIApplication.shared.windows.last?.rootViewController)!
        
        // Create Google Sign In configuration object.
        let signInConfig = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: presentingViewController) { user, error in
            if let error = error {
                print(error.localizedDescription)
              return
            }

            guard
              let authentication = user?.authentication,
              let idToken = authentication.idToken
            else {
              return
            }
            
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.googleToken, value: idToken)
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.googleAuth, value: authentication.accessToken)
            
            guard let user = user else { return }
            let loginVo = LPHParser.parseGoogleLogin(response: user)
            let golResponse = LPHResponse<LoginVo, LoginError>()
            golResponse.setResult(data: loginVo)
            self.callbackDelegate(golResponse)

            
        }
  
    }
    
    private func initiateFacebookLogin() {
        let loginManager = LoginManager()

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
//            let fullName = user.profile.name
//            let email = user.profile.email
//            let profilePicUrl = user.profile.imageURL(withDimension: 100).absoluteString
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
//            loginVo.fullName = fullName!
            loginVo.password = userId!
//            loginVo.profilePicUrl = profilePicUrl
            loginVo.loginType = .google
//            loginVo.email = email!
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
