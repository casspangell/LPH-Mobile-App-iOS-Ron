//
//  LPHServiceImpl.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Updated by Cass Pangell on 03/03/21.
//  Copyright © 2021 LovePeaceHarmony. All rights reserved.
//
import Firebase
import FirebaseDatabase

public class LPHServiceImpl: LPHService {
    
    //Database in Firestore
    private let lphDatabase = Database.database().reference()
    
    private func handleSessionExpiry(completion: @escaping () -> Void) {
        let loginVo = LPHUtils.getLoginVo()
        
        InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
        print("Error fetching remote instange ID: \(error)")
        } else if let result = result {
        print("Remote instance ID token: \(result.token)")
            do {
                try self.fireLogin(email: loginVo.email, password: loginVo.password, deviceId: result.token, source: loginVo.loginType) {(lphResponse) in
                    if lphResponse.isSuccess() {
                        loginVo.token = lphResponse.getMetadata() as! String
                        LPHUtils.setLoginVo(loginVo: loginVo)
                        completion()
                    }
                }
            } catch {
                
            }
         }
        }

    }
    
    public func fireLoginRegister(email: String, password: String, name: String, profilePicUrl: String, source: LoginType, deviceId: String, parsedResponse: @escaping (LPHResponse<ProfileVo, LoginError>) -> Void) {
        var loginType: String?
        if source == .email {
            loginType = "email"
        } else if source == .facebook {
            loginType = "facebook"
        } else if source == .google {
            loginType = "google"
        }
        let inviteCode = LPHUtils.getUserDefaultsString(key: UserDefaults.Keys.invitedCode)
        let loginRegisterParam = [HttpParam.email: email,
                                  HttpParam.password: password,
                                  HttpParam.fullName: name,
                                  HttpParam.profileUrl: profilePicUrl,
                                  HttpParam.source: loginType!,
                                  HttpParam.inviteCode: inviteCode]
        print(loginRegisterParam)
        RestClient.httpRequest(url: LPHUrl.REGISTER_SOCIAL_LOGIN, method: .post, params: loginRegisterParam, isLoading: true) { (rawResponse) in
            let lphResponse = LPHParser.parseLogin(rawResponse: rawResponse)
            if lphResponse.isSuccess() {
                LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.invitedCode, value: "")
            }
            parsedResponse(lphResponse)
        }
    }
    
    public func fireLogin(email: String, password: String, deviceId: String, source: LoginType, parsedResponse: @escaping (LPHResponse<ProfileVo, LoginError>) -> Void) throws {
        print(email)
        print(source)
        var loginType: String?
        if source == .email {
            loginType = "email"
        } else if source == .facebook {
            loginType = "facebook"
        } else if source == .google {
            loginType = "google"
        }
        let loginRegisterParam = [HttpParam.email: email,
                                  HttpParam.password: password,
                                  HttpParam.source: loginType!]
        RestClient.httpRequest(url: LPHUrl.LOGIN, method: .post, params: loginRegisterParam, isLoading: true) { (rawResponse) in
            let lphResponse = LPHParser.parseLogin(rawResponse: rawResponse)
            parsedResponse(lphResponse)
        }
    }
    
    public func updateDeviceToken(token: String, info: String, parsedResponse: @escaping (LPHResponse<Any, LoginError>) -> Void) {
        let updateTokenParam = [HttpParam.deviceToken: token,
                                HttpParam.deviceInfo: info]
        RestClient.httpRequest(url: LPHUrl.UPDATE_DEVICE_TOKEN, method: .post, params: updateTokenParam, isLoading: true) { (rawResponse) in
            let lphResponse = LPHParser.parseUpdateToken(rawResponse: rawResponse)
            parsedResponse(lphResponse)
        }
    }
    
//    public func updateMilestone(date: String, minutes: String, userID: String, parsedResponse: @escaping (LPHResponse<MilestoneVo, ChantError>) -> Void) throws {
//
//        print("updating milestone")
//        let user = "user:\(userID)"
//        
//        let milestone: [String:Any] = [
//            "minutes": minutes as NSObject,
//            "day_chanted": date
//        ]
//        
//        lphDatabase.child(user).child("chanting_milestones").child(date).setValue(milestone)
//        
//        //Update total minutes chanted
//        lphDatabase.child(user).child("total_mins_chanted").observeSingleEvent(of: .value) { (snapshot) in
//            guard let totalMinsData = snapshot.value as? Double else {
//                return
//            }
//            
//            let totalMinsChanted = totalMinsData + Double(minutes)!
//            self.lphDatabase.child(user).child("total_mins_chanted").setValue(totalMinsChanted)
//        }
//    }
    
//    public func fetchMilestones(userID: String, response: @escaping (Milestones) -> Void) {
//        print("fetching milestones")
//
//        let user = "user:\(userID)"
//
//        var currentChantingStreak:Streak!
//        var chantingMilestones:[Milestone] = []
//        var totalMinsChanted:Double!
//        
//        //Database in Firestore
//        let lphDatabase = Database.database().reference()
//        
//        lphDatabase.child(user).child("chanting_milestones").observeSingleEvent(of: .value) { (snapshot) in
//            guard let milestoneData = snapshot.value as? [String: Any] else {
//                return
//            }
//            print(milestoneData)
//            
//        do {
//            for (_,v) in milestoneData {
//                let dict = v as! [String : String]
//                let milestone = Milestone(day_chanted: dict["day_chanted"]!, minutes: dict["minutes"]!)
//
//                chantingMilestones.append(milestone)
//                }
//            }
//        }
//        
//        lphDatabase.child(user).child("current_chanting_streak").observeSingleEvent(of: .value) { (snapshot) in
//            guard let chantStreakData = snapshot.value as? [String: Any] else {
//                return
//            }
//            print(chantStreakData)
//            
//            let lastDay = chantStreakData["last_day_chanted"] as! String
//            let currentStreak = chantStreakData["current_streak"]! as! Int
//            let longestStreak = chantStreakData["longest_streak"] as! Int
//            currentChantingStreak = Streak(last_day_chanted: lastDay, current_streak: currentStreak, longest_streak: longestStreak)
//        }
//        
//        lphDatabase.child(user).child("total_mins_chanted").observeSingleEvent(of: .value) { (snapshot) in
//            guard let totalMinsData = snapshot.value as? Double else {
//                return
//            }
//            print(totalMinsData)
//            
//            totalMinsChanted = totalMinsData
//        }
//        
//        let chantingData = Milestones(chanting_milestones: chantingMilestones, current_chanting_streak: currentChantingStreak, total_mins_chanted: totalMinsChanted)
//        
//        response(chantingData)
//
//    }

//    public func updateChantingStreak(date: String, userID: String, parsedResponse: @escaping (LPHResponse<MilestoneVo, ChantError>) -> Void) throws {
//        let user = "user:\(userID)"
//        
//        //Database in Firestore
//        let lphDatabase = Database.database().reference()
//        lphDatabase.child(user).child("current_chanting_streak").observeSingleEvent(of: .value) { (snapshot) in
//           
//            guard let streakValue = snapshot.value as? [String: Any] else {
//                //there's no streak set, setting initial streak
//                print("no streak, adding initial streak of 0")
//                let currentStreak: [String:Any] = [
//                    "current_streak": 0 as NSObject,
//                    "last_day_chanted": date,
//                    "longest_streak": 0
//                ]
//                
//                lphDatabase.child(user).child("current_chanting_streak").setValue(currentStreak)
//                
//                return
//            }
//            
//            //Check to see if value is yesterday, if so, update streak counter and replace date
//            //Format it into a Calendar object to check
//            //If date is not yesterday, reset streak
//            let chantingStreakData = streakValue["last_day_chanted"]
//            var longestStreak = streakValue["longest_streak"] as! Int
//            var currentStreak = streakValue["current_streak"] as! Int
//            let dateFormatter = ISO8601DateFormatter()
//            let dateValue = dateFormatter.date(from:chantingStreakData as! String)!
//            
//            if (Calendar.current.isDateInYesterday(dateValue)){
//                print("Updating current streak, updating streak by 1")
//                currentStreak+=1
//                
//                //Check longest streak and update it if we need to
//                if(currentStreak > longestStreak) {
//                    longestStreak = currentStreak
//                }
//                
//                //Set new data
//                let newStreakData: [String:Any] = [
//                    "current_streak": currentStreak,
//                    "last_day_chanted": date,
//                    "longest_streak": longestStreak
//                ]
//                
//                lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)
//                
//            } else if (Calendar.current.isDateInToday(dateValue)) {
//                print("Date today, not updating chanting streak")
//                //Do nothing we've already chanted today
//            
//            } else {
//                //Current streak needs to be reset. Check longest streak.
//                //If current streak is longer than longest streak update longest streak
//                
//                //Check longest streak and update it if we need to
//                if(currentStreak > longestStreak) {
//                    longestStreak = currentStreak
//                }
//
//                //Set new data
//                print("Date not yesterday, resetting streak")
//                let newStreakData: [String:Any] = [
//                    "current_streak": 1,
//                    "last_day_chanted": date,
//                    "longest_streak": longestStreak
//                ]
//                
//                lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)
//            }
//
//        }
//    }

//    public func fetchMilestone(parsedResponse: @escaping (LPHResponse<MilestoneVo, ChantError>) -> Void) {
        
//        print("fetching milestones")
//        let deviceToken = LPHUtils.getCurrentUserToken()
//        let user = "user:\(deviceToken)"
//
//        lphDatabase.child(user).child("chanting_milestones").observeSingleEvent(of: .value) { (snapshot) in
//            guard let value = snapshot.value as? [String: Any] else {
//                return
//            }
//
//            print("value \(value)")
//            let lphResponse = LPHParser.parseMilestoneDetails(rawResponse: value)
//        }
//
//        RestClient.httpRequest(url: LPHUrl.FETCH_MILESTONE, method: .get, params: [:], isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.parseMilestoneDetails(rawResponse: rawResponse)
//            print(lphResponse.getSessionExpiry())
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.fetchMilestone(parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
//    }
        
    public func eraseMilestone(parsedResponse: @escaping (LPHResponse<Any, ChantError>) -> Void) {
//        RestClient.httpRequest(url: LPHUrl.ERASE_MILESTONE, method: .delete, params: [:], isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.eraseMilestoneDetails(rawResponse: rawResponse)
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.eraseMilestone(parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
    }
    
    public func fetchNewsList(pageCount: Int, isFetchingFavourite: Bool, parsedResponse: @escaping (LPHResponse<[NewsVo], NewsError>) -> Void) {
//
//        let newsParam = [HttpParam.pageOffset: String(pageCount),
//                         HttpParam.pageLimit: String(PAGE_LIMIT)]
//        var url: String
//        if isFetchingFavourite {
//            let apiToken = LPHUtils.getLoginVo().token
//            url = LPHUrl.NEWS_FAVOURITE
//        } else {
//            url = LPHUrl.NEWS_RECENT
//        }
//        RestClient.httpRequest(url: url, method: .get, params: newsParam, isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.parseNewsList(rawResponse: rawResponse)
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.fetchNewsList(pageCount: pageCount, isFetchingFavourite: isFetchingFavourite, parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
    }
    
    public func markFavourite(newsId: String, markAsFavourite: Bool, parsedResponse: @escaping (LPHResponse<Any, NewsError>) -> Void) {
//        let newsParam = [HttpParam.newsId: newsId,
//                         HttpParam.isFavourite: markAsFavourite ? "1" : "0"]
//        RestClient.httpRequest(url: LPHUrl.MARK_FAVOURITE, method: .post, params: newsParam, isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.parseMarkFavourite(rawResponse: rawResponse)
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.markFavourite(newsId: newsId, markAsFavourite: markAsFavourite, parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
    }
    
    public func markRead(newsId: String, markAsRead: Bool, parsedResponse: @escaping (LPHResponse<Any, NewsError>) -> Void) {
//        let newsParam = [HttpParam.newsId: newsId,
//                         HttpParam.isRead: markAsRead ? "1" : "0"]
//        RestClient.httpRequest(url: LPHUrl.MARK_READ, method: .post, params: newsParam, isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.parseMarkFavourite(rawResponse: rawResponse)
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.markRead(newsId: newsId, markAsRead: markAsRead, parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
    }
    
    public func fetchNewsCategoryList(pageCount: Int, parsedResponse: @escaping (LPHResponse<[CategoryVo], NewsError>) -> Void) {
//        let newsRecentParam = [HttpParam.pageOffset: String(pageCount)]
//        RestClient.httpRequest(url: LPHUrl.NEWS_CATEGORY, method: .get, params: newsRecentParam, isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.parseNewsCategoryList(rawResponse: rawResponse)
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.fetchNewsCategoryList(pageCount: pageCount, parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
    }
    
    public func fetchNewsListFromCategory(categoryId: String, pageCount: Int, parsedResponse: @escaping (LPHResponse<[NewsVo], NewsError>) -> Void) {
//        let newsRecentParam = [HttpParam.categoryId: String(categoryId),
//                               HttpParam.pageLimit: String(PAGE_LIMIT),
//                               HttpParam.pageOffset: String(pageCount)]
//        RestClient.httpRequest(url: LPHUrl.NEWS_LIST_CATEGORY, method: .get, params: newsRecentParam, isLoading: false) { (rawResponse) in
//            let lphResponse = LPHParser.parseNewsList(rawResponse: rawResponse)
//            if lphResponse.getSessionExpiry() {
//                self.handleSessionExpiry {
//                    try! self.fetchNewsListFromCategory(categoryId: categoryId, pageCount: pageCount, parsedResponse: parsedResponse)
//                }
//            } else {
//                parsedResponse(lphResponse)
//            }
//        }
    }
    
    public func updateProfilePic(base64Image: String, parsedResponse: @escaping (LPHResponse<ProfileVo, LoginError>) -> Void) {
        var updateProfilePicParam = [HttpParam.image: base64Image]
        // Removing carriage return from encoded string
        let withoutCarriageReturn = updateProfilePicParam[HttpParam.image]?.replacingOccurrences(of: "\r\n", with: "")
        updateProfilePicParam[HttpParam.image] = withoutCarriageReturn
        RestClient.httpRequest(url: LPHUrl.UPDATE_PROFILE_PIC, method: .post, params: updateProfilePicParam, isLoading: false) { (rawResponse) in
            let lphResponse = LPHParser.parseLogin(rawResponse: rawResponse)
            if lphResponse.getSessionExpiry() {
                self.handleSessionExpiry {
                    try! self.updateProfilePic(base64Image: base64Image, parsedResponse: parsedResponse)
                }
            } else {
                parsedResponse(lphResponse)
            }
        }
    }
    
    public func logout(deviceToken: String, parsedResponse: @escaping (LPHResponse<Any, LoginError>) -> Void) {
        let updateProfilePicParam = [HttpParam.deviceToken: deviceToken]
        RestClient.httpRequest(url: LPHUrl.LOGOUT, method: .post, params: updateProfilePicParam, isLoading: false) { (rawResponse) in
            let lphResponse = LPHParser.parseUpdateToken(rawResponse: rawResponse)
            if lphResponse.getSessionExpiry() {
                self.handleSessionExpiry {
                    try! self.logout(deviceToken: deviceToken, parsedResponse: parsedResponse)
                }
            } else {
                parsedResponse(lphResponse)
            }
        }
    }
    
}
