//
//  MilestoneVo.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 15/01/18.
//  Updated by Cass Pangell on 1/13/21.
//  Copyright © 2021 LovePeaceHarmony. All rights reserved.
//

struct Milestones: Codable {
    var chanting_milestones: [Milestone]
    var current_chanting_streak: Streak
    var total_mins_chanted: Double
}

struct Milestone: Codable {
    var day_chanted: String
    var minutes: String
}

struct Streak: Codable {
    var last_day_chanted: String
    var current_streak: Int
    var longest_streak: Int
}

public struct MilestoneVo {
//    var daysCount: String
//    var minutesCount: String
//    var invitesCount: String
    
//    static func getEmptyMilestone() -> MilestoneVo {
//        return MilestoneVo(daysCount: "0", minutesCount: "0", invitesCount: "0")
//    }
}
