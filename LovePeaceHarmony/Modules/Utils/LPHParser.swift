//
//  LPHParser.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 09/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import SwiftyJSON

public class LPHParser {
    
    static func isResponseSuccess(rawResponse: [String:Any]) -> (Bool, String, Bool) {
        var isSucess: Bool = false
        var message: String
        var isSessionExpired = false
        isSucess = rawResponse[Json.success] as! Bool
        message = rawResponse[Json.message] as! String
        isSessionExpired = (!isSucess && message == SESSION_EXPIRY_MESSAGE)
        return (isSucess, message, isSessionExpired)
    }
    
    static func parseFBLoginResponse(rawResponse: Any) -> LoginVo {
        let data:[String:AnyObject] = rawResponse as! [String : AnyObject]
        //Basic profile info
        let loginVo = LPHUtils.getLoginVo()
        loginVo.isLoggedIn = true
        loginVo.loginType = .facebook
        let firstName = data["first_name"] as! String
        let lastName = data["last_name"]! as! String
        loginVo.fullName = "\(firstName) \(lastName)"
        let dataJson = data["picture"]!["data"]! as! [String : Any]
        let profilePic = dataJson["url"]!
        loginVo.profilePicUrl = profilePic as! String
//        loginVo.email = data["email"] as! String
        let userId = data["id"] as! String
        loginVo.password = userId
        return loginVo
    }
    
    static func parseGoogleLogin(response: GIDGoogleUser) -> LoginVo {
        
        //Basic profile info
        let loginVo = LPHUtils.getLoginVo()
        loginVo.isLoggedIn = true
        loginVo.loginType = .google
        loginVo.fullName = response.profile!.name
        let profilePic = response.profile?.imageURL(withDimension: 320)
        loginVo.profilePicUrl = profilePic!.absoluteString
        loginVo.email = response.profile!.email
        let userId = response.userID
        loginVo.password = userId!
        return loginVo
    }
    
    static func parseLogin(rawResponse: [String: Any]) -> LPHResponse<ProfileVo, LoginError> {
        let lphResponse = LPHResponse<ProfileVo, LoginError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        if isSuccess {
            let jsonData = JSON(rawResponse)["data"]
            let token = jsonData["token"].rawString()!
            let userJson = jsonData["user"]
            var profileVo = ProfileVo()
            profileVo.userId = userJson["id"].rawString()!
            profileVo.email = userJson["email"].rawString()!
            profileVo.name = userJson["name"].rawString()!
            profileVo.profilePic = userJson["profile_pic_url"].rawString()!
            profileVo.inviteCode = userJson["invite_code"].rawString()!
            let loginTypeString = userJson["source"].rawString()!
            switch loginTypeString {
            case "email":
                profileVo.loginType = .email
                break
                
            case "google":
                profileVo.loginType = .google
                break
                
            case "facebook":
                profileVo.loginType = .facebook
                break
                
            default:
                profileVo.loginType = .none
                break
            }
            lphResponse.setResult(data: profileVo)
            lphResponse.setMetadata(metadata: token as AnyObject)
        } else {
            lphResponse.setSessionExpiry(isExpired: isSessionExpired)
            lphResponse.setServerMessage(serverMessage: message)
        }
        return lphResponse
    }
    
//    public static func parseMilestoneDetails(rawResponse: [String: Any]) -> LPHResponse<MilestoneVo, ChantError> {
//        let lphResponse = LPHResponse<MilestoneVo, ChantError>()
//        
        
        
        
//        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
//        if isSuccess {
////            let jsonData = JSON(rawResponse)["data"]
////            let days = jsonData["chanting_stats"]["days"].rawString()!
////            let minutes = Float(jsonData["chanting_stats"]["minutes"].rawString()!)
////            let minutesInString = String(format: "%.0f", minutes!)
////            let invites = jsonData["invites_stats"]["invitees_count"].rawString()!
////            let milestoneVo = MilestoneVo(daysCount: days, minutesCount: minutesInString, invitesCount: invites)
////            lphResponse.setResult(data: milestoneVo)
//        } else {
//            lphResponse.setSessionExpiry(isExpired: isSessionExpired)
//            lphResponse.setServerMessage(serverMessage: message)
//        }
//        return lphResponse
//    }
    
    public static func eraseMilestoneDetails(rawResponse: [String: Any]) -> LPHResponse<Any, ChantError> {
        let lphResponse = LPHResponse<Any, ChantError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        if isSuccess {
            lphResponse.setSucess(isSucess: isSuccess)
        }
        lphResponse.setSessionExpiry(isExpired: isSessionExpired)
        lphResponse.setServerMessage(serverMessage: message)
        return lphResponse
    }
    
//    public static func fetchMilestones(response: Milestones) -> LPHResponse<Milestones, ChantError> {
//        let lphResponse = LPHResponse<Milestones, ChantError>()
//        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: response)
//        if isSuccess {
//            lphResponse.setSucess(isSucess: isSuccess)
//        }
//        lphResponse.setSessionExpiry(isExpired: isSessionExpired)
//        lphResponse.setServerMessage(serverMessage: message)
//        return lphResponse
//    }
    
    public static func parseNewsList(rawResponse: [String: Any]) -> LPHResponse<[NewsVo], NewsError> {
        let lphResponse = LPHResponse<[NewsVo], NewsError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        if isSuccess {
            let jsonData = JSON(rawResponse)
            let newsArrayJson = jsonData["data"].array
            var newsList = [NewsVo]()
            let dateParseFormatter = DateFormatter()
            dateParseFormatter.dateFormat = DatePattern.parse
            let dateDisplayFormatter = DateFormatter()
            dateDisplayFormatter.dateFormat = DatePattern.display
            var date: Date
            for newsJson in newsArrayJson! {
                var news = NewsVo()
                news.id = newsJson["new_id"].rawString()!
                news.title = newsJson["news_heading"].rawString()!
                news.description = newsJson["news_description"].rawString()!
                news.imageUrl = newsJson["news_pic_url"].rawString()!
                news.isRead = Bool(newsJson["is_read"].rawString()!)!
                news.isFavourite = Bool(newsJson["is_favorite"].rawString()!)!
                let parsedDate = newsJson["news_date"].rawString()!
                date = dateParseFormatter.date(from: parsedDate)!
                news.date = dateDisplayFormatter.string(from: date)
                news.timeStamp = String(date.timeIntervalSince1970)
                news.detailsUrl = newsJson["url"].rawString()!
                newsList.append(news)
            }
            lphResponse.setResult(data: newsList)
            lphResponse.setTotalCount(totalCount: Int(jsonData["totalNewsCount"].rawString()!)!)
        } else {
            lphResponse.setSessionExpiry(isExpired: isSessionExpired)
            lphResponse.setServerMessage(serverMessage: message)
        }
        return lphResponse
    }
    
    public static func parseNewsCategoryList(rawResponse: [String: Any]) -> LPHResponse<[CategoryVo], NewsError> {
        let lphResponse = LPHResponse<[CategoryVo], NewsError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        if isSuccess {
            let jsonData = JSON(rawResponse)
            let categoryArrayJson = jsonData["data"].array
            var categoryList = [CategoryVo]()
            for categoryJson in categoryArrayJson! {
                var category = CategoryVo()
                category.id = categoryJson["category_id"].rawString()!
                category.name = categoryJson["category_name"].rawString()!
                category.totalPostCount = categoryJson["num_of_posts"].rawString()!
                category.unreadPostCount = categoryJson["unread_count"].rawString()!
                category.favouritePostCount = categoryJson["favorites_count"].rawString()!
                category.imageUrl = categoryJson["news_pic_url"].rawString()!
                categoryList.append(category)
            }
            lphResponse.setResult(data: categoryList)
            lphResponse.setTotalCount(totalCount: Int(jsonData["totalCategoriesCount"].rawString()!)!)
        } else {
            lphResponse.setSessionExpiry(isExpired: isSessionExpired)
            lphResponse.setServerMessage(serverMessage: message)
        }
        return lphResponse
    }
    
    public static func parseProfilePicUpdate(rawResponse: [String: Any]) -> LPHResponse<ProfileVo, LoginError> {
        let lphResponse = LPHResponse<ProfileVo, LoginError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        if isSuccess {
            let jsonData = JSON(rawResponse)["data"]
            let userJson = jsonData["user"]
            var profileVo = ProfileVo()
            profileVo.userId = userJson["id"].rawString()!
            profileVo.email = userJson["email"].rawString()!
            profileVo.name = userJson["name"].rawString()!
            profileVo.profilePic = userJson["profile_pic_url"].rawString()!
            let loginTypeString = userJson["source"].rawString()!
            switch loginTypeString {
            case "email":
                profileVo.loginType = .email
                break
                
            case "google":
                profileVo.loginType = .google
                break
                
            case "facebook":
                profileVo.loginType = .facebook
                break
                
            default:
                profileVo.loginType = .none
                break
            }
            print("----- \(profileVo.name)")
            lphResponse.setResult(data: profileVo)
        } else {
            lphResponse.setSessionExpiry(isExpired: isSessionExpired)
            lphResponse.setServerMessage(serverMessage: message)
        }
        return lphResponse
    }
    
    public static func parseMarkFavourite(rawResponse: [String: Any]) -> LPHResponse<Any, NewsError> {
        let lphResponse = LPHResponse<Any, NewsError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        lphResponse.setSucess(isSucess: isSuccess)
        lphResponse.setSessionExpiry(isExpired: isSessionExpired)
        lphResponse.setServerMessage(serverMessage: message)
        return lphResponse
    }
    
    public static func parseUpdateToken(rawResponse: [String: Any]) -> LPHResponse<Any, LoginError> {
        let lphResponse = LPHResponse<Any, LoginError>()
        let (isSuccess, message, isSessionExpired) = isResponseSuccess(rawResponse: rawResponse)
        lphResponse.setSucess(isSucess: isSuccess)
        lphResponse.setSessionExpiry(isExpired: isSessionExpired)
        lphResponse.setServerMessage(serverMessage: message)
        return lphResponse
    }
    
}
