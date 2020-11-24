//
//  ProfileController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices
//import Kingfisher
import FirebaseAuth
import FBSDKLoginKit
import Firebase

class ProfileController: BaseViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, RefreshCallback {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var viewShareContainer: UIView!
    @IBOutlet weak var labelAppVersion: UILabel!
    
    // MARK: - View
    override func initView() {
        super.initView()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            labelAppVersion.text = "Version \(version)"
        }
        
        let loginVo = LPHUtils.getLoginVo()
        labelFullName.text = loginVo.fullName
        print(loginVo.fullName)
        renderProfilePic(imageUrl: loginVo.profilePicUrl)
    }
    
    func renderProfilePic(imageUrl: String) {
//        imageViewProfilePic.kf.indicatorType = .activity
//        imageViewProfilePic.contentMode = UIViewContentMode.scaleAspectFill
//        imageViewProfilePic.kf.setImage(with: URL(string: imageUrl))
//        if UI_USER_INTERFACE_IDIOM() == .pad {
//            imageViewProfilePic.layer.cornerRadius = 70
//        } else if UI_USER_INTERFACE_IDIOM() == .phone {
//            imageViewProfilePic.layer.cornerRadius = 35
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    // MARK: - IBActions
    @IBAction func onTapShareApp(_ sender: UITapGestureRecognizer) {
        initiateShare()
    }
    
    @IBAction func onTapManageFavorites(_ sender: UITapGestureRecognizer) {
        let parentTabController = parent?.parent as! HomeTabController
        parentTabController.navigateToNewsFavourites()
    }
    
    @IBAction func onTapMilestones(_ sender: UITapGestureRecognizer) {
        let parentTabController = parent?.parent as! HomeTabController
        parentTabController.navigateToChantMilestone()
    }
    
    @IBAction func onTapProfilePic(_ sender: UITapGestureRecognizer) {
        navigateToProfilePicEditController()
    }
    
    @IBAction func onTapProfilePicEditButton(_ sender: UIButton) {
        navigateToProfilePicEditController()
    }
    
    @IBAction func onTapSignOut(_ sender: UITapGestureRecognizer) {
        showAlertConfirm(title: "", message: "Do you want to signout?", vc: self) {(UIAlertAction) in
            self.fireLogoutApi()
        }
    }
    
    // MARK: - RefreshProfileEdit
    func refresh() {
        let loginVo = LPHUtils.getLoginVo()
        renderProfilePic(imageUrl: loginVo.profilePicUrl)
    }
    
    // MARK: - Actions
    private func initiateShare() {
        if let link = NSURL(string: LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.appInviteShareLink)) {
            let objectsToShare = ["Love Peace Harmony",link] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            let excludeActivities = [
                UIActivityType.addToReadingList, .airDrop, .assignToContact]
            activityViewController.excludedActivityTypes = excludeActivities
            if UI_USER_INTERFACE_IDIOM() == .pad {
                activityViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = activityViewController.popoverPresentationController as UIPopoverPresentationController!
                popover?.sourceView = self.viewShareContainer
                popover?.sourceRect = viewShareContainer.frame
                popover?.permittedArrowDirections = .up
            }
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func processLogout() {
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.loginType == .google {
            do {
                GIDSignIn.sharedInstance().signOut()
                try Auth.auth().signOut()
            } catch {
                
            }
        } else if loginVo.loginType == .facebook {
            LoginManager().logOut()
        }
        loginVo.isLoggedIn = false
        loginVo.fullName = ""
        loginVo.profilePicUrl = ""
        loginVo.token = ""
        DBUtils.deleteNews(newsId: nil, type: .recent)
        DBUtils.deleteNews(newsId: nil, type: .category)
        DBUtils.deleteNews(newsId: nil, type: .favourite)
        LPHUtils.setLoginVo(loginVo: loginVo)
        if let homeController = parent?.parent as? HomeTabController {
            homeController.stopChantingPlayback()
        }
        
        let reminderList = AlarmUtils.fetchCoreDataReminderList()
        for reminder in reminderList {
            AlarmUtils.deleteCoreDataReminder(reminder: reminder)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.failed:
            LPHUtils.showToast(message: "Message sending failed", view: view)
            break
            
        case MFMailComposeResult.sent:
            LPHUtils.showToast(message: "Message sent successfully", view: view)
            break
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.failed:
            LPHUtils.showToast(message: "Message sending failed", view: view)
            break
            
        case MessageComposeResult.sent:
            LPHUtils.showToast(message: "Message sent successfully", view: view)
            break
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Api
    private func fireLogoutApi() {
        
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            self.showLoadingIndicator()
            do {
                let lphService = try LPHServiceFactory<LoginError>.getLPHService()
                try lphService.logout(deviceToken: result.token) { (parsedResponse) in
                    if parsedResponse.isSuccess() {
                        self.processLogout()
                    }
                }
            } catch let error as LPHException<NewsError> {
                self.hideLoadingIndicator()
                self.showToast(message: error.errorMessage)
            } catch let error {
                
            }
         }
        }
        

    }
    
    // MARK: - Navigation
    private func navigateToProfilePicEditController() {
        let profilePicEditController = storyboard?.instantiateViewController(withIdentifier: ViewController.profilePicEdit) as! ProfilePicEditController
        profilePicEditController.refreshCallback = self
        present(profilePicEditController, animated: true, completion: nil)
    }
    
}

// Protocol
protocol RefreshCallback {
    func refresh()
}
