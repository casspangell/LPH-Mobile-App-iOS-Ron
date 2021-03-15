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
    class func updateMilestone(date: String, minutes: String, userID: String, completion: @escaping (Result<Any>) -> Void) throws {

        print("updating milestone")
        let user = "user:\(userID)"
        
        let milestone: [String:Any] = [
            "minutes": minutes as NSObject,
            "day_chanted": date
        ]
        
        //Database in Firestore
        let lphDatabase = Database.database().reference()
        lphDatabase.child(user).child("chanting_milestones").child(date).setValue(milestone)
        
        //Update total minutes chanted
        lphDatabase.child(user).child("total_mins_chanted").observeSingleEvent(of: .value) { (snapshot) in
            guard let totalMinsData = snapshot.value as? Double else {
                //Set initial value
                lphDatabase.child(user).child("total_mins_chanted").setValue(Double(minutes))
                return
            }
            
            let totalMinsChanted = totalMinsData + Double(minutes)!
            lphDatabase.child(user).child("total_mins_chanted").setValue(totalMinsChanted)
        }
    }
    
    //
    //  Updates Minutes when new milestone data is made
    //
//    class func updateTotalMinsChanted(userID: String, minutes: String, completion: @escaping(Result<Double>) -> Void) {
//        print("update total minutes chanted for user:\(userID)")
//
//        let user = "user:\(userID)"
//
//        //Database in Firestore
//        let lphDatabase = Database.database().reference()
//
//        lphDatabase.child(user).child("total_mins_chanted").observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let totalMinsData = snapshot.value as? Double else {
//                return
//            }
//            print(totalMinsData)
//
//            completion(.success(totalMinsData))
//        }) { (error) in
//            completion(.failure(error))
//            print(error.localizedDescription)
//        }
//
//    }
    
    //
    //  Updates Chanting Streak when new milestone data is made
    //
    class func updateChantingStreak(date: String, userID: String, completion: @escaping (Result<Any>) -> Void) throws {
        let user = "user:\(userID)"
        
        //Database in Firestore
        let lphDatabase = Database.database().reference()
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
    
    class func eraseMilestones(userID: String, completion: @escaping (Result<Any>) -> Void) throws {

        print("erasing all milestones")
        let user = "user:\(userID)"

        //Database in Firestore
        let lphDatabase = Database.database().reference()
        
        //Reset Chanting Streak
        lphDatabase.child(user).child("current_chanting_streak").observeSingleEvent(of: .value, with: { (snapshot) in

            let newStreakData: [String:Any] = [
                "current_streak": 0,
                "last_day_chanted": "0",
                "longest_streak": 0
            ]
            
            lphDatabase.child(user).child("current_chanting_streak").removeValue()

        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
        
        //Reset Total Minutes Chanted
        lphDatabase.child(user).child("total_mins_chanted").observeSingleEvent(of: .value, with: { (snapshot) in
            
            lphDatabase.child(user).child("current_chanting_streak").removeValue()
            
        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
        
        //Reset Milestones
        lphDatabase.child(user).child("chanting_milestones").observeSingleEvent(of: .value, with: { (snapshot) in
            
            lphDatabase.child(user).child("current_chanting_streak").removeValue()

        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }

    }
    
//MARK: Fetch Milestones
    
    //
    // kilroy: Not needed yet, but written just in case
    //
//    class func fetchChantingMilestones(userID: String, completion: @escaping(Result<[Milestone]>) -> Void) {
//
//        let user = "user:\(userID)"
//        var chantingMilestones:[Milestone] = []
//
//        //Database in Firestore
//        let lphDatabase = Database.database().reference()
//        print("fetching chanting milestones for user:\(userID)")
//
//        lphDatabase.child(user).child("chanting_milestones").observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let milestoneData = snapshot.value as? [String: Any] else {
//                return
//            }
//            print(milestoneData)
//
//            do {
//                for (_,v) in milestoneData {
//                    let dict = v as! [String : String]
//                    let milestone = Milestone(day_chanted: dict["day_chanted"]!, minutes: dict["minutes"]!)
//
//                    chantingMilestones.append(milestone)
//                    }
//
//                completion(.success(chantingMilestones))
//            }
//        }) { (error) in
//            completion(.failure(error))
//            print(error.localizedDescription)
//        }
//    }
    
    class func fetchCurrentChantingStreak(userID: String, completion: @escaping(Result<Streak>) -> Void) {
        print("fetching current chanting streak for user:\(userID)")

        let user = "user:\(userID)"
        var currentChantingStreak:Streak!
        
        //Database in Firestore
        let lphDatabase = Database.database().reference()
        
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
                
                completion(.success(currentChantingStreak))
            }
        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
    
    }
    
    class func fetchTotalMinsChanted(userID: String, completion: @escaping(Result<Double>) -> Void) {
        print("fetching total minutes chanted for user:\(userID)")

        let user = "user:\(userID)"

        //Database in Firestore
        let lphDatabase = Database.database().reference()
        
        lphDatabase.child(user).child("total_mins_chanted").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let totalMinsData = snapshot.value as? Double else {
                return
            }
            print(totalMinsData)
            
            completion(.success(totalMinsData))
        }) { (error) in
            completion(.failure(error))
            print(error.localizedDescription)
        }
        
    }
    
}