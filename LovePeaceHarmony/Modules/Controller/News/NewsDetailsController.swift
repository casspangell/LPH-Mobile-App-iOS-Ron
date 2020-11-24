//
//  NewsDetailsController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 19/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
//import Kingfisher

class NewsDetailsController: BaseViewController, UIWebViewDelegate {

    // MARK: - Variables
    var categoryId: String?
    var newsVo: NewsVo?
    var activityIndicator: UIActivityIndicatorView?
    var newsFavouriteDelegate: NewsFavouriteDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var buttonStar: UIButton!
    @IBOutlet weak var webViewNews: UIWebView!
    
    // MARK: - Views
    override func initView() {
        super.initView()
        if newsVo != nil {
            if (newsVo?.isFavourite)! {
                buttonStar.imageView?.image = #imageLiteral(resourceName: "ic_star_fill")
            } else {
                buttonStar.imageView?.image = #imageLiteral(resourceName: "ic_star_empty")
            }
            initWebView(url: (newsVo?.detailsUrl)!)
            if !(newsVo?.isRead)! {
                fireMarkReadApi(newsId: (newsVo?.id)!, markAsRead: true)
            }
        }
    }
    
    private func initWebView(url: String) {
        let urlEncodedPath = url.replacingOccurrences(of: " ", with: "%20")
        print(urlEncodedPath)
        let nsUrl: NSURL = NSURL(string: urlEncodedPath)!
        let request: URLRequest = NSURLRequest(url: nsUrl as URL) as URLRequest
        webViewNews.loadRequest(request)
        webViewNews.scalesPageToFit = true
        webViewNews.contentMode = UIViewContentMode.scaleAspectFill
        webViewNews.delegate = self
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator?.center = self.view.center
        activityIndicator?.hidesWhenStopped = true;
        activityIndicator?.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        view.addSubview(activityIndicator!)
        
        activityIndicator?.startAnimating()
    }

    // MARK: - IBActions
    @IBAction func onTapBack(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapFavourite(_ sender: UIButton) {
        newsFavouriteDelegate?.newsFavouriteCallback()
        animateButton(sender, 0.2) {}
        if LPHUtils.getLoginVo().loginType != .withoutLogin {
            fireMarkFavouriteApi(newsId: (newsVo?.id)!, markAsFavourite: !(newsVo?.isFavourite)!)
        } else {
            showToast(message: AlertMessage.login)
        }
    }
    
    // MARK: - Api
    private func fireMarkReadApi(newsId: String, markAsRead: Bool) {
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            lphService.markRead(newsId: newsId, markAsRead: markAsRead) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.processMarkRead()
                }
            }
        } catch let error {
            
        }
    }
    
    private func fireMarkFavouriteApi(newsId: String, markAsFavourite: Bool) {
//        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            self.processFavourite(markedAsfavourite: markAsFavourite)
            lphService.markFavourite(newsId: newsId, markAsFavourite: markAsFavourite) { (lphResponse) in
                if lphResponse.isSuccess() {
                    
                }
//                self.hideLoadingIndicator()
            }
        } catch let error as LPHException<NewsError> {
            showToast(message: error.errorMessage)
        } catch {
            
        }
    }
    
    // MARK: - Actions
    private func processFavourite(markedAsfavourite: Bool) {
        var category: CategoryVo?
        if categoryId != nil {
            category = DBUtils.fetchCategory(categoryId: categoryId!)
        }
        if markedAsfavourite {
            buttonStar.setImage(#imageLiteral(resourceName: "ic_star_fill"), for: .normal)
            newsVo?.isFavourite = true
            DBUtils.insertNewsList(newsList: [newsVo!], type: .recent)
            DBUtils.insertNewsList(newsList: [newsVo!], type: .favourite)
            if categoryId != nil {
                DBUtils.insertNewsList(newsList: [newsVo!], type: .category)
                let favouriteCount = Int((category?.favouritePostCount)!)!
                category?.favouritePostCount = String(favouriteCount + 1)
                DBUtils.updateCategory(category: category!)
            }
            
        } else {
            buttonStar.setImage(#imageLiteral(resourceName: "ic_star_empty"), for: .normal)
            newsVo?.isFavourite = false
            DBUtils.deleteNews(newsId: (newsVo?.id)!, type: .favourite)
            DBUtils.insertNewsList(newsList: [newsVo!], type: .recent)
            if categoryId != nil {
                DBUtils.insertNewsList(newsList: [newsVo!], type: .category)
                let favouriteCount = Int((category?.favouritePostCount)!)!
                category?.favouritePostCount = String(favouriteCount - 1)
                DBUtils.updateCategory(category: category!)
            }
        }
    }
    
    // MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator?.stopAnimating()
    }
    
    // MARK: - Action
    private func processMarkRead() {
        newsVo?.isRead = true
        DBUtils.insertNewsList(newsList: [newsVo!], type: .recent)
        if (newsVo?.isFavourite)! {
            DBUtils.insertNewsList(newsList: [newsVo!], type: .favourite)
        }
        
        if categoryId != nil {
            DBUtils.insertNewsList(newsList: [newsVo!], type: .category)
            var category = DBUtils.fetchCategory(categoryId: categoryId!)
            let unreadCount = Int((category?.unreadPostCount)!)!
            category?.unreadPostCount = String(unreadCount - 1)
            DBUtils.updateCategory(category: category!)
        }
    }
    
}
