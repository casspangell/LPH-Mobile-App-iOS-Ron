//
//  LoginSocialNetworkController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 29/11/17.
//  Last Updated by Cass Pangell on 08/22/21.
//  Copyright © 2020 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuthUI
import AuthenticationServices


class LoginSocialNetworkController: BaseViewController, IndicatorInfoProvider, UITextFieldDelegate, FUIAuthDelegate, ASAuthorizationControllerDelegate {

    
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
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var noAccountButton: UIButton!
    @IBOutlet weak var noAccountLabel: UILabel!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        loginEngine = SocialLoginEngine(self)
        
        //Set up UI labels for translation
        appleLoginButton.setTitle(NSLocalizedString("Connect with Apple", comment: ""), for: .normal)
        googleLoginButton.setTitle(NSLocalizedString("Connect with Google", comment: ""), for: .normal)
        facebookLoginButton.setTitle(NSLocalizedString("Connect with Facebook", comment: ""), for: .normal)
        loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)

        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        noAccountLabel.text = NSLocalizedString("Don't have an account? Sign Up", comment: "")
        
//        emailTextField.delegate = self
//        passwordTextField.delegate = self
        
//        setupSignInWithAppleButton()
    
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("editing begin")
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("editing end")
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()

        return true
    }
    
//    private func setupSignInWithAppleButton() {
//        let signInWithAppleButton = ASAuthorizationAppleIDButton()
//        signInWithAppleButton.addTarget(self, action: #selector(handleSignInWithApple), for: .touchUpInside)
//        stackView.addArrangedSubview(signInWithAppleButton)
//    }
    
//    @objc
//    private func handleSignInWithApple() {
//        let authorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = authorizationAppleIDProvider.createRequest()
//        request.requestedScopes = [.email, .fullName]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.presentationContextProvider = self
//        authorizationController.delegate = self
//        authorizationController.performRequests()
//    }
    
    @IBAction func loginWithEmailPressed(_ sender: Any) {
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
            self.showToast(message: NSLocalizedString("email/password can't be empty", comment: ""))
              return
            }
        
        self.showLoadingIndicator()
           
      //Firebase Email Login
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
    
    @IBAction func appleLoginPressed(_ sender: Any) {
//        if LPHUtils.checkNetworkConnection() {
//            initiateLogin(type: .apple)
//        } else {
//            showToast(message: NSLocalizedString("Please check your internet connection", comment: ""))
//        }
        
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }

    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.uid) \(user.email ?? "")")
        }
    }
    
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

    @objc func actionHandleAppleSignin() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailseg" {
//            let DestView = segue.destination as! DetailsViewController
//            DestView.userid = self.userId
//            DestView.firstname = self.firstName
//            DestView.lastname = self.lastName
//            DestView.email = self.email
        }
    }
    
    //-----------
    
    
    @IBAction func facebookLoginPressed(_ sender: Any) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .facebook)
        } else {
            showToast(message: NSLocalizedString("Please check your internet connection", comment: ""))
        }
    }
    
    @IBAction func googleLoginPressed(_ sender: Any) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .google)
        } else {
            showToast(message: NSLocalizedString("Please check your internet connection", comment: ""))
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
//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//        print("Logged into Facebook")
//        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
//    }
//
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//        print("Logged out of Facebook")
//    }
    
    // ------
    
    private func initiateLogin(type: LoginType) {
        var firebaseDeviceToken = String()
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            firebaseDeviceToken = token
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
        
        let isFirstRun = LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.isFirstRun)
        
        if isFirstRun == 0 {
                
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.loginType = loginType
            loginVo.password = password
            loginVo.token = token
            LPHUtils.setLoginVo(loginVo: loginVo)
            
            let user = LPHUtils.getCurrentUserID()
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindi_SL_EnglishOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isSpanishOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isMandarinEnglishGermanOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isFrenchOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isfrenchAntilleanCreoleOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isKawehiHawOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isShaEngOn, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isShaLulaEngKaHawOn, value: false)
            LPHUtils.setUserDefaultsString(key: "\(user):\(UserDefaults.Keys.chantCurrentStreak)", value: "0")
            LPHUtils.setUserDefaultsString(key: "\(user):\(UserDefaults.Keys.chantLongestStreak)", value: "0")
            LPHUtils.setUserDefaultsString(key: "\(user):\(UserDefaults.Keys.chantTimestamp)", value: "0:00")
            
//            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.isFirstRun, value: 1)
        }
        
        //Firebase Handling after user logs in with Facebook or Google
        switch loginType {
        case .apple:
            
            break
        case .facebook:
            let credential = FacebookAuthProvider
                  .credential(withAccessToken: AccessToken.current!.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  let _ = error as NSError
                    self.showToast(message: error.localizedDescription)
                    print(error.localizedDescription)
                    return
                  }

                //Login Success
                self.navigateToHome()
                  return
                }
            break

        case .google:
            let idToken = LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.googleToken)
            let authToken = LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.googleAuth)
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  let _ = error as NSError
                    self.showToast(message: error.localizedDescription)
                    return
                  }

                //Login Success
                self.navigateToHome()
                  return
                }
            
            break
        case .withoutLogin:
            break
        case .none:
            break
        case .email:
            break
        }//end switch
    
        
}
    
    // MARK: - Navigation
    private func navigateToHome() {
        let homeTabController = LPHUtils.getStoryboard(type: .home).instantiateViewController(withIdentifier: ViewController.homeTab)
        
        let navVC = UINavigationController(rootViewController: homeTabController)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
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

        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            deviceToken = token
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
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
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

extension LoginSocialNetworkController: ASAuthorizationControllerPresentationContextProviding {

    // For present window
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    // Authorization Failed
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }

    // Authorization Succeeded
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Get user data with Apple ID credentitial
            let userId = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            print("User ID: \(userId)")
            print("User First Name: \(userFirstName ?? "")")
            print("User Last Name: \(userLastName ?? "")")
            print("User Email: \(userEmail ?? "")")
            // Write your code here
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Get user data using an existing iCloud Keychain credential
            let appleUsername = passwordCredential.user
            let applePassword = passwordCredential.password
            // Write your code here
        }
    }

}
