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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.navigateToLogin()
    }
 
    private func navigateToLogin() {
        let homeTabController = LPHUtils.getStoryboard(type: .login).instantiateViewController(withIdentifier: ViewController.login)
        present(homeTabController, animated: true, completion: nil)
    }
}
