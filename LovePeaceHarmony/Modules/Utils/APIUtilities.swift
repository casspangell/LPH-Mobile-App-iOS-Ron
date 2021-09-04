//
//  APIUtilities.swift
//  LovePeaceHarmony
//
//  Created by Cass Pangell on 3/15/21.
//  Copyright © 2021 LovePeaceHarmony. All rights reserved.
//

//
//  This class is for the implimentation of the new Firebase API
//

import Foundation
import Firebase
import FirebaseDatabase

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

class APIUtilities {
    
    //
    //  Updates Milestone when new chanting data is made
    //
    class func updateMilestone(date: String, seconds: Int, userID: String, completion: @escaping (Result<Any>) -> Void) {

        print("updating milestone")
        let user = "\(userID)"
        
        let milestone: [String:Any] = [
            "seconds": seconds as NSObject,
            "day_chanted": date
        ]
        
        //Database in Firestore
        let lphDatabase = Database.database().reference(withPath: "love-peace-harmony")
        lphDatabase.child(user).child("chanting_milestones").child(date).setValue(milestone)
        
        //Update total minutes chanted
        lphDatabase.child(user).child("total_secs_chanted").observeSingleEvent(of: .value) { (snapshot) in
            guard let totalSecsData = snapshot.value as? Int else {
                //Set initial value
                lphDatabase.child(user).updateChildValues(["total_secs_chanted" : seconds])
                return
            }
            
            let totalSecsChanted = totalSecsData + seconds
            lphDatabase.child(user).updateChildValues(["total_secs_chanted" : totalSecsData])
        }
    }
    
    
    //
    //  Updates Chanting Streak when new milestone data is made
    //
    class func updateChantingStreak(date: String, userID: String, completion: @escaping (Result<Any>) -> Void) {
        print("updating chanting streak")
        let user = "\(userID)"
        
        //Database in Firestore
        let lphDatabase = Database.database().reference(withPath: "love-peace-harmony")
        lphDatabase.child(user).child("current_chanting_streak").observeSingleEvent(of: .value, with: { (snapshot) in
           
            guard let streakValue = snapshot.value as? [String: Any] else {
                //there's no streak set, setting initial streak
                print("no streak, adding initial streak of 0")
                let currentStreak: [String:Any] = [
                    "current_streak": 1 as NSObject,
                    "last_day_chanted": date,
                    "longest_streak": 1
                ]
                
                lphDatabase.child(user).child("current_chanting_streak").setValue(currentStreak)
                
                return
            }
            
            //Check to see if value is yesterday, if so, update streak counter and replace date
            //Format it into a Calendar object to check
            //If date is not yesterday, reset streak
            let chantingStreakData = streakValue["last_day_chanted"]
            var longestStreak = streakValue["longest_streak"] as! Int
            var currentStreak = streakValue["current_streak"] as! Int
            let dateFormatter = ISO8601DateFormatter()
            let dateValue = dateFormatter.date(from:chantingStreakData as! String)!
            
            if (Calendar.current.isDateInYesterday(dateValue)){
                print("Updating current streak, updating streak by 1")
                currentStreak+=1
                
                //Check longest streak and update it if we need to
                if(currentStreak > longestStreak) {
                    longestStreak = currentStreak
                }
                
                //Set new data
                let newStreakData: [String:Any] = [
                    "current_streak": currentStreak,
                    "last_day_chanted": date,
                    "longest_streak": longestStreak
                ]
                
                lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)
                
            } else if (Calendar.current.isDateInToday(dateValue)) {
                print("Date today, not updating chanting streak")
                //Do nothing we've already chanted today
                
                //However, if it's 0, we need to up it to 1
                if (currentStreak == 0 && longestStreak == 0) {
                    let newStreakData: [String:Any] = [
                        "current_streak": 1,
                        "last_day_chanted": date,
                        "longest_streak": 1
                    ]
                    
                    lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)
                } else if (currentStreak == 0) {
                    let newStreakData: [String:Any] = [
                        "current_streak": 1,
                        "last_day_chanted": date,
                        "longest_streak": longestStreak
                    ]
                    
                    lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)
                } else {}
                
            } else {
                //Current streak needs to be reset. Check longest streak.
                //If current streak is longer than longest streak update longest streak
                
                //Check longest streak and update it if we need to
                if(currentStreak > longestStreak) {
                    longestStreak = currentStreak
                }

                //Set new data
                print("Date not yesterday, resetting streak")
                let newStreakData: [String:Any] = [
                    "current_streak": 1,
                    "last_day_chanted": date,
                    "longest_streak": longestStreak
                ]
                
                lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)
            }
        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
    }
    
    class func eraseMilestones(userID: String, completion: @escaping (Result<Any>) -> Void) {

        print("erasing all milestones")
        let user = "\(userID)"
        
        let currentDate = LPHUtils.getCurrentDate()
        let chantDate = String(currentDate)

        //Database in Firestore
        let lphDatabase = Database.database().reference(withPath: "love-peace-harmony")
        
        //Reset Chanting Streak
        let newStreakData: [String:Any] = [
            "current_streak": 0,
            "last_day_chanted": chantDate,
            "longest_streak": 0
        ]
        
        lphDatabase.child(user).child("current_chanting_streak").setValue(newStreakData)

        //Reset Total Minutes Chanted
        lphDatabase.child(user).child("total_secs_chanted").setValue(0)

        //Reset Milestones
        lphDatabase.child(user).child("chanting_milestones").setValue(nil)

        //Update UI
        completion(.success(true))
        
    }
    
//MARK: Fetch Milestones
    class func fetchCurrentChantingStreak(userID: String, completion: @escaping(Result<Streak>) -> Void) {
        print("fetching current chanting streak for user:\(userID)")

        let user = "\(userID)"
        var currentChantingStreak:Streak!
        
        //Database in Firestore
        let lphDatabase = Database.database().reference(withPath: "love-peace-harmony")
        lphDatabase.child(user).getData { (_, snapshot) in
            guard let snapshot = snapshot.value as? [String: Any] else {
                return
            }
        
                let currentStreak = snapshot["current_chanting_streak"] as? [String: Any]

            do {
                let lastDay = currentStreak!["last_day_chanted"] as! String
                let currentStreak = currentStreak!["current_streak"] as! Int
//                let longestStreak = currentStreak["longest_streak"] as! Int
            }
        }
        
        
        lphDatabase.child(user).child("current_chanting_streak").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chantStreakData = snapshot.value as? [String: Any] else {
                return
            }
            print(chantStreakData)
            do {
                let lastDay = chantStreakData["last_day_chanted"] as! String
                let currentStreak = chantStreakData["current_streak"] as! Int
                let longestStreak = chantStreakData["longest_streak"] as! Int
                currentChantingStreak = Streak(last_day_chanted: lastDay, current_streak: currentStreak, longest_streak: longestStreak)
                
                //Set UserDefaults
                LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.chantCurrentStreak, value: "\(currentStreak)")
                LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.chantLongestStreak, value: "\(longestStreak)")
                
                completion(.success(currentChantingStreak))
            }
        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
    
    }
    
    class func fetchTotalSecsChanted(userID: String, completion: @escaping(Result<Double>) -> Void) {
        print("fetching total seconds chanted for user:\(userID)")

        let user = "\(userID)"

        //Database in Firestore
        let lphDatabase = Database.database().reference(withPath: "love-peace-harmony")
        
        lphDatabase.child(user).child("total_secs_chanted").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let totalSecsData = snapshot.value as? Double else {
                return
            }
            print(totalSecsData)
            
            //Set UserDefaults
            let timeStamp = LPHUtils.returnHoursMinsSeconds(seconds: totalSecsData)
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.chantTimestamp, value: timeStamp)
            
            completion(.success(totalSecsData))
        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
        
    }
    
}
