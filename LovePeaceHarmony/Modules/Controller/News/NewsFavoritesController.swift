//
//  NewsFavoritesController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//import Kingfisher
import Firebase

class NewsFavoritesController: BaseViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate, NewsFavouriteDelegate {
    
    // MARK: - Variables
    var newsFavouritesList = [NewsVo]()
    var loginType: LoginType?
    var pageCount = 0
    var totalCount = 0
    var loginEngine: SocialLoginEngine?
    
    // MARK: - IBProperties
    @IBOutlet weak var viewNoDataContainer: UIView!
    @IBOutlet weak var tableViewNewsFavourite: UITableView!
    @IBOutlet weak var stackViewLoginContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginEngine = SocialLoginEngine(self)
    }
    
    override func initView() {
        super.initView()
        tableViewNewsFavourite.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Always hide all subviews
        tableViewNewsFavourite.isHidden = true
        viewNoDataContainer.isHidden = true
        stackViewLoginContainer.isHidden = true
        
        let loginVo = LPHUtils.getLoginVo()
        if loginVo.isLoggedIn && loginVo.loginType == .withoutLogin {
            renderUI(isLoginViewShown: true)
        } else {
            if loginType != loginVo.loginType {
                if LPHUtils.isConnectedToNetwork(showAlert: false, vc: self) {
                    fireFetchNewsFavouriteApi()
                } else {
                    newsFavouritesList.append(contentsOf: DBUtils.fetchNewsList(type: .favourite))
                    tableViewNewsFavourite.reloadData()
                }
            } else {
                let previousPosition = tableViewNewsFavourite.contentOffset
                newsFavouritesList.removeAll()
                newsFavouritesList.append(contentsOf: DBUtils.fetchNewsList(type: .favourite))
                tableViewNewsFavourite.reloadData()
                tableViewNewsFavourite.contentOffset = previousPosition
                renderUI(isLoginViewShown: false)
            }
        }
        tableViewNewsFavourite.reloadData()
        loginType = loginVo.loginType
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - IBActions
    @IBAction func onTapRecentArticle(_ sender: UITapGestureRecognizer) {
        if let newsController = parent as? NewsController {
            newsController.populateTab(currentTab: .recent)
        }
    }
    
    @IBAction func onTapEmailLogin(_ sender: UITapGestureRecognizer) {
        let loginEmailController = LPHUtils.getStoryboard(type: .login).instantiateViewController(withIdentifier: ViewController.login) as! LoginController
        loginEmailController.isFromProfileController = true
        present(loginEmailController, animated: true, completion: nil)
    }
    
    @IBAction func onTapGoogleLogin(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .google)
        } else {
            showToast(message: "Please check your internet connection")
        }
    }
    
    @IBAction func onTapFacebookLogin(_ sender: UITapGestureRecognizer) {
        if LPHUtils.checkNetworkConnection() {
            initiateLogin(type: .facebook)
        } else {
            showToast(message: "Please check your internet connection")
        }
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFavouritesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newsFavourite) as! NewsCell
        cell.selectionStyle = .none
        let currentNews = newsFavouritesList[indexPath.item]
        cell.labelTitle.text = currentNews.title
        if currentNews.isRead {
            cell.labelTitle.font = UIFont.init(name: "OpenSans", size: 15)
            cell.labelDescription.textColor = UIColor.lightGray
        } else {
            cell.labelTitle.font = UIFont.init(name: "OpenSans-Bold", size: 15)
            cell.labelDescription.textColor = UIColor.black
        }
        if currentNews.isFavourite {
            cell.buttonFavouriteStar.setImage(#imageLiteral(resourceName: "ic_star_fill"), for: .normal)
        } else {
            cell.buttonFavouriteStar.setImage(#imageLiteral(resourceName: "ic_star_empty"), for: .normal)
        }
        cell.buttonFavouriteStar.tag = indexPath.item
        cell.buttonFavouriteStar.addTarget(self, action: #selector(onTapFavourite(sender:)), for: .touchDown)
        
        cell.labelDescription.text = currentNews.description
        cell.labelTimeStamp.text = currentNews.date
//        cell.imageViewNews.kf.setImage(with: URL(string: currentNews.imageUrl))
        cell.imageViewNews.contentMode = UIViewContentMode.scaleAspectFill
        
        // Checking for pagination
        if indexPath.item == (newsFavouritesList.count - 1) && totalCount > newsFavouritesList.count {
            pageCount += PAGE_LIMIT
            fireFetchNewsFavouriteApi()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LPHUtils.checkNetworkConnection() {
            navigateToNewsDetails(selectedNews: newsFavouritesList[indexPath.item])
        } else {
            showToast(message: AlertMessage.noNetwork)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - Actions
    private func renderUI(isLoginViewShown: Bool) {
        if isLoginViewShown {
            tableViewNewsFavourite.isHidden = true
            viewNoDataContainer.isHidden = true
            stackViewLoginContainer.isHidden = false
        } else {
            stackViewLoginContainer.isHidden = true
            if newsFavouritesList.count == 0 {
                viewNoDataContainer.isHidden = false
                tableViewNewsFavourite.isHidden = true
            } else {
                viewNoDataContainer.isHidden = true
                tableViewNewsFavourite.isHidden = false
            }
        }
    }
    
    private func populateNews(feedsList: [NewsVo], totalFeeds: Int) {
        self.newsFavouritesList.append(contentsOf: feedsList)
        DBUtils.insertNewsList(newsList: feedsList, type: .favourite)
        self.totalCount = totalFeeds
        tableViewNewsFavourite.reloadData()
        self.renderUI(isLoginViewShown: false)
    }
    
    private func processMarkFavourite(newsIndex: Int) {
        newsFavouritesList[newsIndex].isFavourite = false
        DBUtils.insertNewsList(newsList: [newsFavouritesList[newsIndex]], type: .recent)
        DBUtils.deleteNews(newsId: newsFavouritesList[newsIndex].id, type: .favourite)
        newsFavouritesList.remove(at: newsIndex)
        tableViewNewsFavourite.reloadData()
        stackViewLoginContainer.isHidden = true
        if newsFavouritesList.count == 0 {
            viewNoDataContainer.isHidden = false
            tableViewNewsFavourite.isHidden = true
        }
    }
    
    private func processLoginResponse(source loginType: LoginType, password: String, serverResponse response: LPHResponse<ProfileVo, LoginError>) {
        if response.isSuccess() {
            
            let profileVo = response.getResult()
            let loginVo = LPHUtils.getLoginVo()
            loginVo.isLoggedIn = true
            loginVo.email = profileVo.email
            loginVo.password = password
            loginVo.fullName = profileVo.name
            loginVo.profilePicUrl = profileVo.profilePic
            loginVo.loginType = loginType
            loginVo.inviteCode = profileVo.inviteCode
            loginVo.token = response.getMetadata() as! String
            LPHUtils.setLoginVo(loginVo: loginVo)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: true)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: true)
            fireUpdateTokenApi()
        }
    }
    
    private func initiateLogin(type: LoginType) {
//        do {
//            try loginEngine?.initiateLogin(type) { (lphResponse) in
//                if lphResponse.isSuccess() {
//                    let loginVo = lphResponse.getResult()
//
//                    InstanceID.instanceID().instanceID { (result, error) in
//                    if let error = error {
//                    print("Error fetching remote instange ID: \(error)")
//                    } else if let result = result {
//                    print("Remote instance ID token: \(result.token)")
//                        self.fireSocialLoginRegisterApi(email: loginVo.email, password: loginVo.password, name: loginVo.fullName, profilePic: loginVo.profilePicUrl, source: type, deviceId: result.token)
//                    } else {
//
//                    }
//                     }
//                    }
//
//
//            }
//        } catch let exception as LPHException<LoginError> {
//
//        } catch {
//
//        }
    }
    
    //MARK: - IBActions
    @objc func onTapFavourite(sender: UIButton) {
        if let newsController = parent as? NewsController {
            newsController.refreshCategoryController()
        }
        let newsIndex = sender.tag
        let selectedNews = newsFavouritesList[newsIndex]
        fireMarkFavouriteApi(newsId: selectedNews.id, index: newsIndex)
    }
    
    //MARK: - Api
    private func fireFetchNewsFavouriteApi() {
        if newsFavouritesList.count == 0 {
            showLoadingIndicator()
        }
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            lphService.fetchNewsList(pageCount: self.pageCount, isFetchingFavourite: true) { (lphResponse) in
                self.hideLoadingIndicator()
                if lphResponse.isSuccess() {
                    self.populateNews(feedsList: lphResponse.getResult(), totalFeeds: lphResponse.getTotalCount())
                }
            }
        } catch let error {
            hideLoadingIndicator()
        }
    }
    
    private func fireMarkFavouriteApi(newsId: String, index newsIndex: Int) {
//        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            self.processMarkFavourite(newsIndex: newsIndex)
            lphService.markFavourite(newsId: newsId, markAsFavourite: false) { (lphResponse) in
                if lphResponse.isSuccess() {
                    
                }
//                self.hideLoadingIndicator()
            }
        } catch let error as LPHException<NewsError> {
            showToast(message: error.errorMessage)
        } catch {
            
        }
    }
    
    private func fireSocialLoginRegisterApi(email: String,password: String, name: String, profilePic: String, source: LoginType, deviceId: String) {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<LoginError>.getLPHService()
            lphService.fireLoginRegister(email: email, password: password, name: name, profilePicUrl: profilePic, source: source, deviceId: deviceId) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.processLoginResponse(source: source, password: password, serverResponse: lphResponse)
                }
                self.hideLoadingIndicator()
            }
        } catch let error {
            
        }
    }
    
    private func fireUpdateTokenApi() {
        
//        InstanceID.instanceID().instanceID { (result, error) in
//        if let error = error {
//        print("Error fetching remote instange ID: \(error)")
//        } else if let result = result {
//        print("Remote instance ID token: \(result.token)")
//            let deviceInfo = DEVICE_INFO
//            self.showLoadingIndicator()
//            do {
//                let lphService = try LPHServiceFactory<LoginError>.getLPHService()
//                try lphService.updateDeviceToken(token: result.token, info: deviceInfo) { (parsedResponse) in
//                    self.hideLoadingIndicator()
//                    self.renderUI(isLoginViewShown: false)
//                }
//            } catch let error {
//                
//            }
//         }
//        }
        

    }
    
    // MARK: - NewsFavouriteDelegate
    func newsFavouriteCallback() {
        if let newsController = parent as? NewsController {
            newsController.refreshCategoryController()
        }
    }
    
    // MARK: - Navigation
    private func navigateToNewsDetails(selectedNews: NewsVo) {
        let newsDetailsController = storyboard?.instantiateViewController(withIdentifier: ViewController.newsDetails) as! NewsDetailsController
        newsDetailsController.newsVo = selectedNews
        newsDetailsController.newsFavouriteDelegate = self
        present(newsDetailsController, animated: true, completion: nil)
    }
    
}

protocol NewsFavouriteDelegate {
    func newsFavouriteCallback()
}
