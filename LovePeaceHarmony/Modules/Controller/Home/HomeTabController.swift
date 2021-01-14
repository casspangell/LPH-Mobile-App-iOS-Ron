//
//  HomeTabController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks

class HomeTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        dynamicLink() //gets the app share link
    }

    
    func navigateToChantMilestone() {
        selectedIndex = 0
        let chantController = childViewControllers[0] as! ChantController
        chantController.navigateToChantMilestone()
    }
    
    func navigateToNewsFavourites() {
        selectedIndex = 1
        let newsController = childViewControllers[1] as! NewsController
        newsController.navigateToNewsFavourite()
    }
    
//    func generateContentLink() -> URL {
//      let baseURL = URL(string: "https://lovepeaceharmony.page.link")!
//      let domain = "https://your-app.page.link"
//      let linkBuilder = DynamicLinkComponents(link: baseURL, domainURIPrefix: domain)
//      linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.your.bundleID")
//      linkBuilder?.androidParameters =
//          DynamicLinkAndroidParameters(packageName: "com.your.packageName")
//
//
//      // Fall back to the base url if we can't generate a dynamic link.
//      return linkBuilder?.link ?? baseURL
//    }
    
//    private func dynamicLink() {
//        let linkUrl = LPHUrl.INVITE_LINK + LPHUtils.getLoginVo().inviteCode
//        guard let link = URL(string: linkUrl) else {
//            print("invite link nil")
//            return
//        }
        
//        let components = DynamicLinkComponents.init(link: link, domainURIPrefix: SHARE_DYNAMIC_LINK)
//
//        let iOSParams = DynamicLinkIOSParameters(bundleID: LPH_IOS_BUNDLE_ID)
//        iOSParams.minimumAppVersion = "1.0"
//        iOSParams.appStoreID = "1355584112"
//        components!.iOSParameters = iOSParams
//
//        let androidParams = DynamicLinkAndroidParameters(packageName: LPH_ANDROID_BUNDLE_ID)
//        androidParams.minimumVersion = 1
//        components!.androidParameters = androidParams
        
//        let options = DynamicLinkComponentsOptions()
//        options.pathLength = .unguessable
//        components!.options = options
//
//        let longLink = components?.url
//
//
//        let longShareLink: String = (longLink?.absoluteString)!
//        print("Long share link: \(longShareLink)")
//        LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appInviteShareLink, value: longShareLink)
//
//        components!.shorten { (shortURL, warnings, error) in
//            // Handle shortURL.
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            let shortShareLink = (shortURL?.absoluteString)!
//            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appInviteShareLink, value: shortShareLink)
//            print("Short share link \(shortShareLink)")
////            print( ?? "")
//            // ...
//        }
//    }
    
    func stopChantingPlayback() {
        if let chantNowController = childViewControllers[0] as? ChantController {
            chantNowController.stopChantingPlayback()
        }
        
    }
}
