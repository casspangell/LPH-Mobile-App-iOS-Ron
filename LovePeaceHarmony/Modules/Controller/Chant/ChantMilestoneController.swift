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
    
    // MARK: - IBProperties
    @IBOutlet weak var labelDayCount: UILabel!
    @IBOutlet weak var labelMinutesCount: UILabel!
    @IBOutlet weak var labelPeopleCount: UILabel!
    @IBOutlet weak var viewMilestoneContainer: UIView!
    @IBOutlet weak var buttonShareApp: UIButton!
    
    var milestones:[Milestone]! = [] 
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        viewMilestoneContainer.isHidden = true
        
        let loginVo = LPHUtils.getLoginVo()
//        if loginVo.isLoggedIn && loginVo.loginType == .withoutLogin {
//            renderUI(isLoginViewShown: true)
//        } else {
//            if loginType != loginVo.loginType {
//                fireMilestoneApi()
//            } else {
//                renderUI(isLoginViewShown: false)
                loadPreviouslySavedData()
//            }
//        }
//        loginType = loginVo.loginType
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
        
        fireMilestoneDetails()
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
    
    private func populateData(milestoneVo: MilestoneVo) {
//        LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantDay, value: Float(milestoneVo.daysCount)!)
//        LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantMinute, value: Float(milestoneVo.minutesCount)!)
//        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.inviteCount, value: Int(milestoneVo.invitesCount)!)
//        
//        let daysCount = Float(milestoneVo.daysCount)!
//        let minutesCount = Float(milestoneVo.minutesCount)!
//        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
//        let totalMinutes = minutesCount + pendingMinutesTemp
//        labelDayCount.text = getParsedFloatAsString(value: daysCount)
//        labelMinutesCount.text = getParsedFloatAsString(value: totalMinutes)
//        
//        if Int(milestoneVo.invitesCount)! >= 1000 {
//            labelPeopleCount.text = "\(Int(Int(milestoneVo.invitesCount)! / 1000))K"
//        } else {
//            labelPeopleCount.text = milestoneVo.invitesCount
//        }
        
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

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - Api
    private func fireMilestoneDetails() {
        showLoadingIndicator()
        do {
            
            LPHServiceImpl.fetchMilestones { (result) in
                switch result {
                case .success(let milestones):
                    self.hideLoadingIndicator()
//                    self.milestones = milestones
                    
//                    JustHUD.shared.hide()
//                    self.venues = venues
//
//                    self.collectionView.reloadData()
//                    print(self.venues)
//                    self.saveVenuesToCoreData()
//
                case .failure(let error):
                    self.showToast(message: String("error: \(error.localizedDescription)"))
                    fatalError("Error: \(String(describing: error))")
                }
            }
            
//            lphService.fetchMilestone(parsedResponse: { (lphResponse) in
//                self.hideLoadingIndicator()
//                if lphResponse.isSuccess() {
//                    self.populateData(milestoneVo: lphResponse.getResult())
//                }
//            })
        }
    }
    
    private func fireMilestoneErase() {
        do {
            let lphService: LPHService = try LPHServiceFactory<ChantError>.getLPHService()
//            self.populateData(milestoneVo: MilestoneVo.getEmptyMilestone())
//            lphService.eraseMilestone(parsedResponse: { (lphResponse) in
//                if lphResponse.isSuccess() {
//
//                }
//            })
        } catch let error as LPHException<ChantError> {
            showToast(message: error.errorMessage)
        } catch let error {
            
        }
    }

}
