//
//  MilestoneVo.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 15/01/18.
//  Copyright © 2018 LovePeaceHarmony. All rights reserved.
//

public struct MilestoneVo {
    var daysCount: String
    var minutesCount: String
    var invitesCount: String
    
    static func getEmptyMilestone() -> MilestoneVo {
        return MilestoneVo(daysCount: "0", minutesCount: "0", invitesCount: "0")
    }
}
