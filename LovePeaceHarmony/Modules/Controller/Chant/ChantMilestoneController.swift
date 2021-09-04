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
    
    @IBOutlet weak var timestampActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var daysStraightActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var longestStreakActivityIndicator: UIActivityIndicatorView!
    
    //For localization
    @IBOutlet weak var daysStraightLabel: UILabel!
    @IBOutlet weak var youHaveChantedLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var longestStreakLabel: UILabel!
    @IBOutlet weak var eraseButton: UIButton!
    
    
    var milestones:Milestones!
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysStraightLabel.text = NSLocalizedString("Days Straight", comment: "")
        youHaveChantedLabel.text = NSLocalizedString("You have chanted for a total of:", comment: "")
        daysLabel.text = NSLocalizedString("Days", comment: "")
        longestStreakLabel.text = NSLocalizedString("Longest streak:", comment: "")
        eraseButton.titleLabel?.text = NSLocalizedString("Erase Milestones", comment: "")
        
        timestampActivityIndicator.hidesWhenStopped = true
        longestStreakActivityIndicator.hidesWhenStopped = true
        daysStraightActivityIndicator.hidesWhenStopped = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let loginVo = LPHUtils.getLoginVo()
        let userId = LPHUtils.getCurrentUserID()
        
        loadPreviouslySavedData(userId: userId)
    }
    
    private func loadPreviouslySavedData(userId: String) {
        let timeStamp = LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.chantTimestamp)
        let daysStraight = LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.chantCurrentStreak)
        let longestStreak = LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.chantLongestStreak)
        
        labelMinutesCount.text = timeStamp
        labelDayCount.text = daysStraight
        labelStreakCount.text = longestStreak

        timestampActivityIndicator.startAnimating()
        daysStraightActivityIndicator.startAnimating()
        longestStreakActivityIndicator.startAnimating()
        
        fireMilestoneDetails(userId: userId)
    }
    
    //MARK: - IBActions
    @IBAction func onTapEraseMilestone(_ sender: UIButton) {
        let userId = LPHUtils.getCurrentUserID()
        
        showAlertConfirm(title: "", message: NSLocalizedString("Do you want to reset all your milestones?", comment: ""), vc: self) {(UIAlertAction) in
            APIUtilities.eraseMilestones(userID: userId) { (result) in
                self.showToast(message: NSLocalizedString("Milestone Data Deleted", comment: ""))
                self.fireMilestoneDetails(userId: userId)
            }
        }
    }
    
    @IBAction func onTapShareApp(_ sender: UIButton) {
        initiateShare()
    }
    

    private func initiateShare() {
        
//        if let link = NSURL(string: DYNAMIC_LINK_DOMAIN) {
//
//            let messageItem = "Chant Love, Peace, Harmony with me!"
//            let linkItem : NSURL = NSURL(string: DYNAMIC_LINK_DOMAIN)!
//            let imageItem : UIImage = UIImage(named: "AppIcon")!
//
//            let objectsToShare = [messageItem, linkItem, imageItem] as [Any]
//            let excludeActivities = [UIActivityType.addToReadingList, .airDrop, .assignToContact]
//
//            let shareViewController = UIActivityViewController(activityItems: [objectsToShare],  applicationActivities: nil)
//            shareViewController.excludedActivityTypes = excludeActivities
//
//            if UI_USER_INTERFACE_IDIOM() == .pad {
//                shareViewController.modalPresentationStyle = UIModalPresentationStyle.popover
//                let popover = shareViewController.popoverPresentationController as UIPopoverPresentationController!
//                popover?.sourceView = self.buttonShareApp
//                popover?.sourceRect = buttonShareApp.frame
//                popover?.permittedArrowDirections = .up
//            }
//
//            present(shareViewController, animated: true, completion: nil)
//        }
        
    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: Fetching Milestone Data
    private func fireMilestoneDetails(userId: String) {
        showLoadingIndicator()
        
        APIUtilities.fetchTotalSecsChanted(userID: userId) { [self] (result) in
            switch result {
            case .success(let seconds):

                let timeStamp = LPHUtils.returnHoursMinsSeconds(seconds: seconds)
                
                if timeStamp.count == 1 {
                    labelMinutesCount.text = "00:0\(timeStamp)"
                } else if timeStamp.count == 2 {
                    labelMinutesCount.text = "00:\(timeStamp)"
                } else {
                    labelMinutesCount.text = timeStamp
                }
                
                
                self.timestampActivityIndicator.stopAnimating()

            case .failure(let error):
                fatalError("Error: \(String(describing: error))")
            }
            
        }

        APIUtilities.fetchCurrentChantingStreak(userID: userId) { (result) in
            switch result {
            case .success(let streak):
                
                self.labelStreakCount.text = String(streak.longest_streak)
                self.labelDayCount.text = String(streak.current_streak)
                
                self.daysStraightActivityIndicator.stopAnimating()
                self.longestStreakActivityIndicator.stopAnimating()
                
            case .failure(let error):
                fatalError("Error: \(String(describing: error))")
            }
        }
        
        hideLoadingIndicator()

    }

}

