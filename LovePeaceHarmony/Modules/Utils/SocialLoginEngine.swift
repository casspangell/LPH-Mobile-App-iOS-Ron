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
import FirebaseAuthUI
import AuthenticationServices
import CryptoKit

//class SocialLoginEngine: NSObject, GIDSignInUIDelegate, GIDSignInDelegate {
class SocialLoginEngine: NSObject, ASAuthorizationControllerDelegate, FUIAuthDelegate {
    
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
        if #available(iOS 13.0, *) {
            let nonce = randomNonceString()
            currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        
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
    
    //MARK: Apple Login In
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.uid) \(user.email ?? "")")
        }
    }
    
    @available(iOS 13.0, *)
    func getCredentialState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "USER_ID") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // Credential is valid
                // Continiue to show 'User's Profile' Screen
                break
            case .revoked:
                // Credential is revoked.
                // Show 'Sign In' Screen
                break
            case .notFound:
                // Credential not found.
                // Show 'Sign In' Screen
                break
            default:
                break
            }
        }
    }
    

}

//Apple login
extension SocialLoginEngine: ASAuthorizationControllerPresentationContextProviding {

    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    // For present window
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let presentingViewControllerWindow = (UIApplication.shared.windows.last?.rootViewController)!.view.window
        return presentingViewControllerWindow!
    }

    // Authorization Failed
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }

    // Authorization Succeeded
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let loginVo = LPHUtils.getLoginVo()
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Encountered an authorization error")
            return
        }
            // Get user data with Apple ID credentitial
            let userId = appleIDCredential.user
            print("User ID: \(userId)")
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
              print("Unable to fetch identity token")
              return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
              print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
              return
            }
            
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appleUserId, value: userId)
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appleNonce, value: nonce)
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appleTokenString, value: idTokenString)
            
            loginVo.isLoggedIn = true
            loginVo.loginType = .apple
            let golResponse = LPHResponse<LoginVo, LoginError>()
            golResponse.setResult(data: loginVo)
            self.callbackDelegate(golResponse)
            
    }
    
    private func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0)
            let charset: Array<Character> =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            var result = ""
            var remainingLength = length

            while remainingLength > 0 {
                let randoms: [UInt8] = (0 ..< 16).map { _ in
                    var random: UInt8 = 0
                    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                    if errorCode != errSecSuccess {
                        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                    }
                    return random
                }

                randoms.forEach { random in
                    if remainingLength == 0 {
                        return
                    }

                    if random < charset.count {
                        result.append(charset[Int(random)])
                        remainingLength -= 1
                    }
                }
            }
            return result
        }

}
