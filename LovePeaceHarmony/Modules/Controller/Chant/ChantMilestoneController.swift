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
    
    var milestones:Milestones!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let loginVo = LPHUtils.getLoginVo()

        loadPreviouslySavedData()
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
    
    private func populateData(milestoneVo: Milestones) {
        
        let milestones = milestoneVo.chanting_milestones
        var milestoneArr:[Milestone] = []
        
        //create an array from the data
        for m in milestones {
            milestoneArr.append(m)
        }
        
        //calculate days straight
        let daysCount = getDaysCount(milestones: milestoneArr)
        let minutesCount = getMinutesCount(milestones: milestoneArr)
        
        LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantDay, value: Float(daysCount))
        LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.chantMinute, value: minutesCount)
        
//        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.inviteCount, value: Int(milestoneVo.invitesCount)!)
//        
//        let daysCount = Float(daysCount)
//        let minutesCount = Float(minutesCount)
//        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
//        let totalMinutes = minutesCount + pendingMinutesTemp
        labelDayCount.text = String(daysCount)
        labelMinutesCount.text = "\(minutesCount)!"
//        
//        if Int(milestoneVo.invitesCount)! >= 1000 {
//            labelPeopleCount.text = "\(Int(Int(milestoneVo.invitesCount)! / 1000))K"
//        } else {
//            labelPeopleCount.text = milestoneVo.invitesCount
//        }
        
    }
    
    func getMinutesCount(milestones:[Milestone]) -> String {
        
        var totalMinutesCount = 0.0
        var milestoneArr:[Milestone] = []
        
        for m in milestones {
            milestoneArr.append(m)
            totalMinutesCount += Double(m.minutes)! //calculate total minutes
        }

        let formatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.allowedUnits = [.hour, .minute]
            return formatter
        }()
        
        let remaining: TimeInterval = 1111123 //totalMinutesCount

        if let result = formatter.string(from: remaining) {
            return result
        } else {
            return "0"
        }
    }
    
    func getDaysCount(milestones:[Milestone]) -> Int {
        var timeArr:[String] = []
        
        for m in milestones {
            let timestamp = m.day_chanted
            let timearray = timestamp.components(separatedBy: "T") //grabs date
            timeArr.append(timearray[0]) //sticks all dates in array
        }
        
        //compare dates from today and find the same date in a row
        var daysCount = 0
        var d = timeArr[0]
        for t in timeArr {
            if t == d {
                daysCount += 1
            }
        }
        return daysCount
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
        
        if let link = NSURL(string: DYNAMIC_LINK_DOMAIN) {
            
            let titleItem = "Share Chant Love, Peace, Harmony"
            let linkItem : NSURL = NSURL(string: DYNAMIC_LINK_DOMAIN)!
            let imageItem : UIImage = UIImage(named: "AppIcon")!
            
            let objectsToShare = [titleItem, linkItem, imageItem] as [Any]
            let excludeActivities = [UIActivityType.addToReadingList, .airDrop, .assignToContact]
            
            let shareViewController = UIActivityViewController(activityItems: [objectsToShare],  applicationActivities: nil)
            shareViewController.excludedActivityTypes = excludeActivities
//            if UI_USER_INTERFACE_IDIOM() == .pad {
//                activityViewController.modalPresentationStyle = UIModalPresentationStyle.popover
//                let popover = activityViewController.popoverPresentationController as UIPopoverPresentationController!
//                popover?.sourceView = self.buttonShareApp
//                popover?.sourceRect = buttonShareApp.frame
//                popover?.permittedArrowDirections = .up
//            }
            present(shareViewController, animated: true, completion: nil)
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

                    self.milestones = milestones
                    
                    self.hideLoadingIndicator()
                    self.populateData(milestoneVo: milestones)

                case .failure(let error):
                    self.showToast(message: String("error: \(error.localizedDescription)"))
                    fatalError("Error: \(String(describing: error))")
                }
            }
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
