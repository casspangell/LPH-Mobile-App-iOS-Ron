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
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var lphMessengerLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.titleLabel?.text = NSLocalizedString("Logout", comment: "")
        lphMessengerLabel.text = NSLocalizedString("Love Peace Harmony Messenger", comment: "")
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        showLoadingIndicator()
        
        do {
          try firebaseAuth.signOut()
       
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        AVAudioSingleton.sharedInstance.stop()
        self.hideLoadingIndicator()
        self.navigateToLogin()
    }
 
    private func navigateToLogin() {
        let homeTabController = LPHUtils.getStoryboard(type: .login).instantiateViewController(withIdentifier: ViewController.login)
        present(homeTabController, animated: true, completion: nil)
    }
}
