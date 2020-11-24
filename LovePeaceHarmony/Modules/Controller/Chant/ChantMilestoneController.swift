//
//  ChantMilestoneController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase

class ChantMilestoneController: BaseViewController, IndicatorInfoProvider {

    // MARK: - Variables
    var loginType: LoginType?
    var loginEngine: SocialLoginEngine?
    
    // MARK: - IBProperties
    @IBOutlet weak var labelDayCount: UILabel!
    @IBOutlet weak var labelMinutesCount: UILabel!
    @IBOutlet weak var labelPeopleCount: UILabel!
    @IBOutlet weak var viewMilestoneContainer: UIView!
    @IBOutlet weak var stackViewLoginContainer: UIStackView!
    @IBOutlet weak var buttonShareApp: UIButton!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        loginEngine = SocialLoginEngine(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewMilestoneContainer.isHidden = true
        stackViewLoginContainer.isHidden = true
        
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.isLoggedIn && loginVo.loginType == .withoutLogin {
            renderUI(isLoginViewShown: true)
        } else {
            if loginType != loginVo.loginType {
                fireMilestoneApi()
            } else {
                renderUI(isLoginViewShown: false)
                loadPreviouslySavedData()
            }
        }
        loginType = loginVo.loginType
    }
    
    private func loadPreviouslySavedData() {
        let day = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantDay)
        let minutes = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinute)
        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
        let inviteCount = LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.inviteCount)
        
        let daysCount = Int(Float(day))
        let minutesCount = Int(Float(minutes) + pendingMinutesTemp)
        if daysCount >= 1000 {
            labelDayCount.text = "\(Int(daysCount / 1000))K"
        } else {
            labelDayCount.text = String(daysCount)
        }
        
        if minutesCount >= 1000 {
            labelMinutesCount.text = "\(Int(minutesCount / 1000))K"
        } else {
            labelMinutesCount.text = String(minutesCount)
        }
        
        if inviteCount >= 1000 {
            labelPeopleCount.text = "\(Int(inviteCount / 1000))K"
        } else {
            labelPeopleCount.text = String(inviteCount)
        }
        
    }
    
    //MARK: - IBActions
    @IBAction func onTapEraseMilestone(_ sender: UIButton) {
        showAlertConfirm(title: "", message: "Do you want to reset all your milestones?", vc: self) {(UIAlertAction) in
            self.fireMilestoneErase()
        }
    }
    
    @IBAction func onTapShareApp(_ sender: UIButton) {
        initiateShare()
    }
    
    @IBAction func onTapSignInWithEmail(_ sender: UITapGestureRecognizer) {
        let loginEmailController = LPHUtils.getStoryboard(type: .login).instantiateViewController(withIdentifier: ViewController.login) as! LoginController
        loginEmailController.isFromProfileController = true
        present(loginEmailController, animated: true, completion: nil)
    }
    
    @IBAction func onTapFacebookLogin(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .facebook)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    @IBAction func onTapGoogleLogin(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .google)
        } else {
            showToast(message: "Please check your internet connection.")
        }
    }
    
    // MARK: - Actions
    private func renderUI(isLoginViewShown: Bool) {
        viewMilestoneContainer.isHidden = isLoginViewShown
        stackViewLoginContainer.isHidden = !isLoginViewShown
    }
    
    private func populateData(milestoneVo: MilestoneVo) {
        LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantDay, value: Float(milestoneVo.daysCount)!)
        LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantMinute, value: Float(milestoneVo.minutesCount)!)
        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.inviteCount, value: Int(milestoneVo.invitesCount)!)
        
        let daysCount = Float(milestoneVo.daysCount)!
        let minutesCount = Float(milestoneVo.minutesCount)!
        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
        let totalMinutes = minutesCount + pendingMinutesTemp
        labelDayCount.text = getParsedFloatAsString(value: daysCount)
        labelMinutesCount.text = getParsedFloatAsString(value: totalMinutes)
        
        if Int(milestoneVo.invitesCount)! >= 1000 {
            labelPeopleCount.text = "\(Int(Int(milestoneVo.invitesCount)! / 1000))K"
        } else {
            labelPeopleCount.text = milestoneVo.invitesCount
        }
        
    }
    
    private func getParsedFloatAsString( value: Float) -> String {
        var value = value
        var strValue: String
        if value >= 1000 {
            value /= 1000
            let singleDecimalFloat = Float(String(format: "%.1f", value))
            strValue = String(format: "%g", singleDecimalFloat!) + "K"
        } else {
            strValue = String(Int(value))
        }
        return strValue
    }
    
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
                popover?.sourceView = self.buttonShareApp
                popover?.sourceRect = buttonShareApp.frame
                popover?.permittedArrowDirections = .up
            }
            present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    private func initiateLogin(type: LoginType) {
        do {
            try loginEngine?.initiateLogin(type) { (lphResponse) in
                if lphResponse.isSuccess() {
                    let loginVo = lphResponse.getResult()
    
                    InstanceID.instanceID().instanceID { (result, error) in
                    if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                    } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                        self.fireSocialLoginRegisterApi(email: loginVo.email, password: loginVo.password, name: loginVo.fullName, profilePic: loginVo.profilePicUrl, source: type, deviceId: result.token)
                     }
                    }
                    
                } else {
                    
                }
            }
        } catch let exception as LPHException<LoginError> {
            
        } catch {
            
        }
    }
    
    private func processLoginResponse(source loginType: LoginType, password: String, serverResponse response: LPHResponse<ProfileVo, LoginError>) {
        if response.isSuccess() {
            
            let profileVo = response.getResult()
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.email = profileVo.email
            loginVo.password = password
            loginVo.fullName = profileVo.name
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.loginType = loginType
            loginVo.inviteCode = profileVo.inviteCode
            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: true)
            fireUpdateTokenApi()
        }
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - Api
    private func fireMilestoneDetails() {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<ChantError>.getLPHService()
            lphService.fetchMilestone(parsedResponse: { (lphResponse) in
                self.hideLoadingIndicator()
                if lphResponse.isSuccess() {
                    self.populateData(milestoneVo: lphResponse.getResult())
                }
            })
        } catch let error as LPHException<ChantError> {
            hideLoadingIndicator()
            loadPreviouslySavedData()
        } catch let error {
            hideLoadingIndicator()
        }
    }
    
    private func fireMilestoneErase() {
        do {
            let lphService: LPHService = try LPHServiceFactory<ChantError>.getLPHService()
            self.populateData(milestoneVo: MilestoneVo.getEmptyMilestone())
            lphService.eraseMilestone(parsedResponse: { (lphResponse) in
                if lphResponse.isSuccess() {
                    
                }
            })
        } catch let error as LPHException<ChantError> {
            showToast(message: error.errorMessage)
        } catch let error {
            
        }
    }
    
    private func fireSocialLoginRegisterApi(email: String,password: String, name: String, profilePic: String, source: LoginType, deviceId: String) {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<LoginError>.getLPHService()
            lphService.fireLoginRegister(email: email, password: password, name: name, profilePicUrl: profilePic, source: source, deviceId: deviceId) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.processLoginResponse(source: source, password: password, serverResponse: lphResponse)
                }
                self.hideLoadingIndicator()
            }
        } catch let error {
            
        }
    }
    
    private func fireUpdateTokenApi() {
        var deviceToken = String()
        let deviceInfo = DEVICE_INFO
        showLoadingIndicator()
        
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            deviceToken = result.token
         }
        }
        
        do {
            let lphService = try LPHServiceFactory<LoginError>.getLPHService()
            try lphService.updateDeviceToken(token: deviceToken, info: deviceInfo) { (parsedResponse) in
                self.hideLoadingIndicator()
                let loginVo = LPHUtils.getLoginVo()
                if loginVo.isLoggedIn && loginVo.loginType == .withoutLogin {
                    self.renderUI(isLoginViewShown: true)
                } else {
                    if self.loginType != loginVo.loginType {
                        self.fireMilestoneApi()
                    } else {
                        self.renderUI(isLoginViewShown: false)
                    }
                }
                self.loginType = loginVo.loginType
            }
        } catch let error {
            
        }
    }
    
    private func fireMilestoneApi() {
        renderUI(isLoginViewShown: false)
        fireMilestoneDetails()
    }

}
