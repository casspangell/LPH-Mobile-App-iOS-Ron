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

//struct MilestoneStats {
//    var daysInARow: Int //consecutive days
//    var highestScoreInARow: Int //Highest Score
//    var totalMinutes: String //total minutes
//    var daysChanted: [String:Double] //total minutes per unique day
//}

struct ChantDate {
    var day: Int
    var month: Int
    var year: Int
}

class ChantMilestoneController: BaseViewController, IndicatorInfoProvider {
    
    // MARK: - IBProperties
    @IBOutlet weak var labelDayCount: UILabel!
    @IBOutlet weak var labelMinutesCount: UILabel!
    @IBOutlet weak var labelPeopleCount: UILabel!
    @IBOutlet weak var viewMilestoneContainer: UIView!
    @IBOutlet weak var buttonShareApp: UIButton!
    @IBOutlet weak var labelStreakCount: UILabel!
    
    var milestones:Milestones!
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let loginVo = LPHUtils.getLoginVo()
        let userId = LPHUtils.getCurrentUserID()
        
        loadPreviouslySavedData(userId: userId)
    }
    
    private func loadPreviouslySavedData(userId: String) {
//        let day = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantDay)
//        let minutes = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinute)
//        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
//        let inviteCount = LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.inviteCount)
        
//        let daysCount = Int(Float(day))
//        let minutesCount = Int(Float(minutes) + pendingMinutesTemp)
//        if daysCount >= 1000 {
////            labelDayCount.text = "\(Int(daysCount / 1000))K"
//        } else {
////            labelDayCount.text = String(daysCount)
//        }
//
//        if minutesCount >= 1000 {
////            labelMinutesCount.text = "\(Int(minutesCount / 1000))K"
//        } else {
////            labelMinutesCount.text = String(minutesCount)
//        }
//
//        if inviteCount >= 1000 {
////            labelPeopleCount.text = "\(Int(inviteCount / 1000))K"
//        } else {
////            labelPeopleCount.text = String(inviteCount)
//        }
        
        fireMilestoneDetails(userId: userId)
    }
    
    //MARK: - IBActions
    @IBAction func onTapEraseMilestone(_ sender: UIButton) {
        let userId = LPHUtils.getCurrentUserID()
        
        showAlertConfirm(title: "", message: "Do you want to reset all your milestones?", vc: self) {(UIAlertAction) in
            APIUtilities.eraseMilestones(userID: userId) { (result) in
                self.showToast(message: "Milestone Data Deleted")
                self.fireMilestoneDetails(userId: userId)
            }
        }
    }
    
    @IBAction func onTapShareApp(_ sender: UIButton) {
        initiateShare()
    }
    
    private func populateData(milestoneVo: Milestones) {

// //       LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantDay, value: Float(daysCount))
//   //     LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.chantMinute, value: minutesCount)
        
        
        
        
//        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.inviteCount, value: Int(milestoneVo.invitesCount)!)

//    //    labelDayCount.text = String(daysCount)
//     //   labelMinutesCount.text = "\(minutesCount)!"
        
        
//        
//        if Int(milestoneVo.invitesCount)! >= 1000 {
//            labelPeopleCount.text = "\(Int(Int(milestoneVo.invitesCount)! / 1000))K"
//        } else {
//            labelPeopleCount.text = milestoneVo.invitesCount
//        }
        
    }

    private func initiateShare() {
        
        if let link = NSURL(string: DYNAMIC_LINK_DOMAIN) {
            
            let messageItem = "Chant Love, Peace, Harmony with me!"
            let linkItem : NSURL = NSURL(string: DYNAMIC_LINK_DOMAIN)!
            let imageItem : UIImage = UIImage(named: "AppIcon")!
            
            let objectsToShare = [messageItem, linkItem, imageItem] as [Any]
            let excludeActivities = [UIActivityType.addToReadingList, .airDrop, .assignToContact]
            
            let shareViewController = UIActivityViewController(activityItems: [objectsToShare],  applicationActivities: nil)
            shareViewController.excludedActivityTypes = excludeActivities
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                shareViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = shareViewController.popoverPresentationController as UIPopoverPresentationController!
                popover?.sourceView = self.buttonShareApp
                popover?.sourceRect = buttonShareApp.frame
                popover?.permittedArrowDirections = .up
            }
            
            present(shareViewController, animated: true, completion: nil)
        }
        
    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: Fetching Milestone Data
    private func fireMilestoneDetails(userId: String) {
        showLoadingIndicator()
        
        APIUtilities.fetchTotalMinsChanted(userID: userId) { [self] (result) in
            switch result {
            case .success(let seconds):
                let (h, m, s) = LPHUtils.secondsToHoursMinutesSeconds(seconds: Int(seconds))
                labelMinutesCount.text = "\(h):\(m):\(s)"
                
            case .failure(let error):
                fatalError("Error: \(String(describing: error))")
            }
            
        }

        APIUtilities.fetchCurrentChantingStreak(userID: userId) { (result) in
            switch result {
            case .success(let streak):
                
                self.labelStreakCount.text = String(streak.longest_streak)
                self.labelDayCount.text = String(streak.current_streak)
                
            case .failure(let error):
                fatalError("Error: \(String(describing: error))")
            }
        }
        
        hideLoadingIndicator()

    }

}

