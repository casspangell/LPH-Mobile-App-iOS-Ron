//
//  LPHUrl.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

public class LPHUrl {
    
    private static let BASE_URL: String = "https://lovepeaceharmony.org/app/api/"

    public static let LOGIN: String = BASE_URL + "user/login"
    
    public static let REGISTER_SOCIAL_LOGIN = BASE_URL + "user/register"
    
    public static let UPDATE_DEVICE_TOKEN = BASE_URL + "user/update_device_token"
    
    public static let UPDATE_MILESTONE: String = BASE_URL + "user/update_milestone"
    
    public static let FETCH_MILESTONE: String = BASE_URL + "user/get_milestone"
    
    public static let ERASE_MILESTONE: String = BASE_URL + "user/reset_milestone"
    
    public static let NEWS_RECENT: String = BASE_URL + "news/recent_news"
    
    public static let NEWS_CATEGORY: String = BASE_URL + "news/categories"
    
    public static let NEWS_LIST_CATEGORY: String = BASE_URL + "news/category_news"
    
    public static let NEWS_FAVOURITE: String = BASE_URL + "news/recent_favorites"
    
    public static let MARK_FAVOURITE: String = BASE_URL + "news/mark_favorite"
    
    public static let MARK_READ: String = BASE_URL + "news/mark_read"
    
    public static let PROFILE = BASE_URL + "api/user"
    
    public static let UPDATE_PROFILE_PIC = BASE_URL + "user/profile_pic_upload"
    
    public static let LOGOUT = BASE_URL + "user/logout"
    
    
    
    public static let WEBSITE = "https://www.lovepeaceharmony.org"
    
    public static let DONATE_LINK = "https://lovepeaceharmony.org/donate/"
    
    public static let INVITE_LINK = "https://lovepeaceharmony.org/api/invite.php?invite_id="
    
}
