//
//  LPHService.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public protocol LPHService {
    
    func fireLoginRegister(email: String, password: String, name: String, profilePicUrl: String, source: LoginType, deviceId: String, parsedResponse: @escaping (LPHResponse<ProfileVo, LoginError>) -> Void)
    
    func fireLogin(email: String, password: String, deviceId: String, source: LoginType, parsedResponse: @escaping (LPHResponse<ProfileVo, LoginError>) -> Void) throws
    
    func updateDeviceToken(token: String, info: String, parsedResponse: @escaping (LPHResponse<Any, LoginError>) -> Void)

    func eraseMilestone(parsedResponse: @escaping (LPHResponse<Any, ChantError>) -> Void)

    func fetchNewsList(pageCount: Int, isFetchingFavourite: Bool, parsedResponse: @escaping (LPHResponse<[NewsVo], NewsError>) -> Void)
    
    func markFavourite(newsId: String, markAsFavourite: Bool, parsedResponse: @escaping (LPHResponse<Any, NewsError>) -> Void)
    
    func markRead(newsId: String, markAsRead: Bool, parsedResponse: @escaping (LPHResponse<Any, NewsError>) -> Void)
    
    func fetchNewsCategoryList(pageCount: Int, parsedResponse: @escaping (LPHResponse<[CategoryVo], NewsError>) -> Void)
    
    func fetchNewsListFromCategory(categoryId: String, pageCount: Int, parsedResponse: @escaping (LPHResponse<[NewsVo], NewsError>) -> Void)
    
    func updateProfilePic(base64Image: String, parsedResponse: @escaping (LPHResponse<ProfileVo, LoginError>) -> Void)
    
    func logout(deviceToken: String, parsedResponse: @escaping (LPHResponse<Any, LoginError>) -> Void)
}
