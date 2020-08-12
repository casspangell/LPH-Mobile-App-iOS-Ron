//
//  LoginVo.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 05/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import Foundation

 class LoginVo: NSObject, NSCoding {
    
    var email: String
    var password: String
    var fullName: String
    var profilePicUrl: String
    var isLoggedIn: Bool
    var loginType: LoginType
    var token: String
    var inviteCode: String
    
    init(email: String, password: String, fullName: String, profilePicUrl: String, isLoggedIn: Bool, loginType: LoginType, token: String, inviteCode: String) {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.profilePicUrl = profilePicUrl
        self.isLoggedIn = isLoggedIn
        self.loginType = loginType
        self.token = token
        self.inviteCode = inviteCode
    }
    
    // MARK: - NSCoding
    required convenience public init(coder aDecoder: NSCoder) {
        let email = aDecoder.decodeObject(forKey: UserDefaults.Keys.email) as! String
        let password = aDecoder.decodeObject(forKey: UserDefaults.Keys.password) as! String
        let fullName = aDecoder.decodeObject(forKey: UserDefaults.Keys.fullName) as! String
        let profilePicUrl = aDecoder.decodeObject(forKey: UserDefaults.Keys.profilePicUrl) as! String
        let isLoggedIn = aDecoder.decodeBool(forKey: UserDefaults.Keys.isLoggedIn)
        let loginType: LoginType = LoginType(rawValue: Int(aDecoder.decodeInt32(forKey: UserDefaults.Keys.loginType)))!
        let token = aDecoder.decodeObject(forKey: UserDefaults.Keys.token) as! String
        let inviteCode = aDecoder.decodeObject(forKey: UserDefaults.Keys.inviteCode) as! String
        self.init(email: email, password: password, fullName: fullName, profilePicUrl: profilePicUrl, isLoggedIn: isLoggedIn, loginType: loginType, token: token, inviteCode: inviteCode)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.email, forKey: UserDefaults.Keys.email)
        aCoder.encode(self.password, forKey: UserDefaults.Keys.password)
        aCoder.encode(self.fullName, forKey: UserDefaults.Keys.fullName)
        aCoder.encode(self.profilePicUrl, forKey: UserDefaults.Keys.profilePicUrl)
        aCoder.encode(self.isLoggedIn, forKey: UserDefaults.Keys.isLoggedIn)
        aCoder.encodeCInt(Int32(self.loginType.rawValue), forKey: UserDefaults.Keys.loginType)
        aCoder.encode(self.token, forKey: UserDefaults.Keys.token)
        aCoder.encode(self.inviteCode, forKey: UserDefaults.Keys.inviteCode)
    }
    
    static func getDefaultObject() -> LoginVo {
        return LoginVo(email: "", password: "", fullName: "", profilePicUrl: "", isLoggedIn: false, loginType: .none, token: "", inviteCode: "")
    }
    
}
