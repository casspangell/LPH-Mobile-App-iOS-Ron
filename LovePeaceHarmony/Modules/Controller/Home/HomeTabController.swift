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
        dynamicLink()
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
    
    private func dynamicLink() {
        let linkUrl = LPHUrl.INVITE_LINK + LPHUtils.getLoginVo().inviteCode
        guard let link = URL(string: linkUrl) else {
            return
        }
        let components = FIRDynamicLinkComponents.init(link: link, domain: DYNAMIC_LINK_DOMAIN)
        
        let iOSParams = FIRDynamicLinkIOSParameters(bundleID: LPH_IOS_BUNDLE_ID)
        iOSParams.minimumAppVersion = "1.0"
        iOSParams.appStoreID = "1355584112"
        components.iOSParameters = iOSParams
        
        let androidParams = FIRDynamicLinkAndroidParameters(packageName: LPH_ANDROID_BUNDLE_ID)
        androidParams.minimumVersion = 1
        components.androidParameters = androidParams
        
        let options = FIRDynamicLinkComponentsOptions()
        options.pathLength = .unguessable
        components.options = options
        
        let longLink = components.url
        
        
        let longShareLink: String = (longLink?.absoluteString)!
        print("Long share link: \(longShareLink)")
        LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appInviteShareLink, value: longShareLink)
        
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let shortShareLink = (shortURL?.absoluteString)!
            LPHUtils.setUserDefaultsString(key: UserDefaults.Keys.appInviteShareLink, value: shortShareLink)
            print("Short share link \(shortShareLink)")
//            print( ?? "")
            // ...
        }
    }
    
    func stopChantingPlayback() {
        if let chantNowController = childViewControllers[0] as? ChantController {
            chantNowController.stopChantingPlayback()
        }
        
    }
}
