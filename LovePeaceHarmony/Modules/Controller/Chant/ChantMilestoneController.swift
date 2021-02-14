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

struct MilestoneStats {
    var daysInARow: Int //consecutive days
    var highestScoreInARow: Int //Highest Score
    var totalMinutes: String //total minutes
    var daysChanted: [String:Double] //total minutes per unique day
}

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
        let day = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantDay)
        let minutes = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinute)
        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
        let inviteCount = LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.inviteCount)
        
        let daysCount = Int(Float(day))
        let minutesCount = Int(Float(minutes) + pendingMinutesTemp)
        if daysCount >= 1000 {
//            labelDayCount.text = "\(Int(daysCount / 1000))K"
        } else {
//            labelDayCount.text = String(daysCount)
        }
        
        if minutesCount >= 1000 {
//            labelMinutesCount.text = "\(Int(minutesCount / 1000))K"
        } else {
//            labelMinutesCount.text = String(minutesCount)
        }
        
        if inviteCount >= 1000 {
//            labelPeopleCount.text = "\(Int(inviteCount / 1000))K"
        } else {
//            labelPeopleCount.text = String(inviteCount)
        }
        
        fireMilestoneDetails(userId: userId)
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
        
//        let daysCount = getDaysCount(milestones: milestoneArr)
//        let minutesCount = getMinutesCount(milestones: milestoneArr)
        let statistics = getStatistics(milestones: milestoneArr)
        
        
        
// //       LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.chantDay, value: Float(daysCount))
//   //     LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.chantMinute, value: minutesCount)
        
        
        
        
//        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.inviteCount, value: Int(milestoneVo.invitesCount)!)
//        
//        let daysCount = Float(daysCount)
//        let minutesCount = Float(minutesCount)
//        let pendingMinutesTemp = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.chantMinutePendingTemp)
//        let totalMinutes = minutesCount + pendingMinutesTemp
        
        
//    //    labelDayCount.text = String(daysCount)
//     //   labelMinutesCount.text = "\(minutesCount)!"
        
        
//        
//        if Int(milestoneVo.invitesCount)! >= 1000 {
//            labelPeopleCount.text = "\(Int(Int(milestoneVo.invitesCount)! / 1000))K"
//        } else {
//            labelPeopleCount.text = milestoneVo.invitesCount
//        }
        
    }
    
    func getMinutesCount(minutes:Double) -> String {

        let formatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.allowedUnits = [.hour, .minute]
            return formatter
        }()
        
        let remaining: TimeInterval = minutes

        if let result = formatter.string(from: remaining) {
            return result
        } else {
            return "0"
        }
    }
    
    
    
    func getStatistics(milestones:[Milestone]) {
        
        var timeArr:[[String:Double]] = [[:]]
        var minsChanted:[String] = []
        var uniqueDict:[String:Double] = [:] //unique singular dict
        var totalMins = ""
        
        if milestones.count > 0 {
            var totalMinChanted:Double = 0.0
        
            for m in milestones {
                let dayChanted = m.day_chanted
                let timeStamp = dayChanted.components(separatedBy: "T") //grabs date and removes timestamp
                let minsChanted = Double(m.minutes) //grabs mins in double
                
//                let timeDict:[String:Double] = [timeStamp[0]:minsChanted!]
                
                //Calculates total minutes chanted regardless of date
                totalMinChanted += minsChanted!

                //Creates a dictionary of unique dates with total mins chanted for each date
                if uniqueDict[timeStamp[0]] != nil {

                    var mins = Double(uniqueDict[timeStamp[0]]!)
                    mins += minsChanted!
                    uniqueDict.updateValue(mins, forKey: timeStamp[0])
                    
                } else {
                    uniqueDict.updateValue(minsChanted!, forKey: timeStamp[0])
                }
            }
            
            
            //Caculate days in a row
            var chantDatesArr:[ChantDate] = []
            
            let currentDay = LPHUtils.getCurrentDay()
            let currentDayArr = currentDay.components(separatedBy: "-")
            
            
            
            var count = 0
            
            //[ [month]:[array of days] ] //array of a single month with an array of all the times chanted in that month
            var dayArr:[String] = []
            for (_, dict) in uniqueDict.enumerated() {
                let day = dict.key
                let time = dict.value
                dayArr.append(day)
               
                print(day+" "+String(time))
            }
            
            //Convert all dates into a chant date
            var formattedDateArr:[ChantDate] = []
            for day in dayArr {
                let currentDayArr = day.components(separatedBy: "-")
                let formattedDate = ChantDate(day: Int(currentDayArr[2])!, month: Int(currentDayArr[1])!, year: Int(currentDayArr[0])!)
                formattedDateArr.append(formattedDate)
            }
            
            //Count current day streak and longest streak of all time
            var currentStreakCount = 0
            var longestStreakCount = 1
            for day1 in formattedDateArr {
                let month_1 = day1.month
                let day_1 = day1.day
                let year_1 = day1.year
                
                for day2 in formattedDateArr {
                    let month_2 = day2.month
                    let day_2 = day2.day
                    let year_2 = day2.year
                    
                    //Same year same month
                    if year_1 == year_2 {
                        print("year "+String(year_1))
                        if month_1 == month_2 {
                            print("month "+String(month_1))
                            if day_2 == (day_1 + 1) {
                                longestStreakCount += 1
                                labelStreakCount.text = String(longestStreakCount)
                                print("day1 "+String(day_1)+" day2 "+String(day_2))
                            }
                        }
                    }
                }
            }
            

           


            //Formatted total minutes chanted
            totalMins = getMinutesCount(minutes: totalMinChanted)
            let milestoneStat = getMilestonesStats(totalMinsChanted: totalMins)
        }
        
  
    }
    
    func getMilestonesStats(totalMinsChanted: String) -> MilestoneStats {
        let milestones:MilestoneStats = MilestoneStats(daysInARow: 0, highestScoreInARow: 0, totalMinutes: "", daysChanted: ["":0.0])
        return milestones
    }
    
//    func getDaysCount(milestones:[Milestone]) -> Int {
//        var timeArr:[[String:Double]] = [[:]]
//        var minsChanted:[String] = []
//        var uniqueDict:[String:Double] = [:] //unique singular dict
//
//        if milestones.count > 0 {
//            for m in milestones {
//                let dayChanted = m.day_chanted
//                let timeStamp = dayChanted.components(separatedBy: "T") //grabs date
//                let minsChanted = Double(m.minutes) //grabs mins
//
//                let timeDict:[String:Double] = [timeStamp[0]:minsChanted!]
//
//                //Creates a dictionary of unique dates with total mins chanted for each date
//                if uniqueDict[timeStamp[0]] != nil {
//                    print(uniqueDict[timeStamp[0]])
//                    var mins = Double(uniqueDict[timeStamp[0]]!)
//                    mins += minsChanted!
//                    uniqueDict.updateValue(mins, forKey: timeStamp[0])
//                } else {
//                    uniqueDict.updateValue(minsChanted!, forKey: timeStamp[0])
//                }
//
//            }
//
//            return 0
//        } else {
//            return 0
//        }
//    }

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
    
    // MARK: - Api
    private func fireMilestoneDetails(userId: String) {
        showLoadingIndicator()
        do {
            LPHServiceImpl.fetchMilestones(userID:userId) { (result) in
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
