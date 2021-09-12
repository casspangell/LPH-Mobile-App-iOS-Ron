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
    private let lphDatabase = Database.database().reference(withPath: "love-peace-harmony")
    
    private func handleSessionExpiry(completion: @escaping () -> Void) {
        let loginVo = LPHUtils.getLoginVo()
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
                do {
                    try self.fireLogin(email: loginVo.email, password: loginVo.password, deviceId: token, source: loginVo.loginType) {(lphResponse) in
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
//                LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.invitedCode, value: "")
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
    
//    public func eraseMilestone(parsedResponse: @escaping (LPHResponse<Any, ChantError>) -> Void) {
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
//    }
    
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
