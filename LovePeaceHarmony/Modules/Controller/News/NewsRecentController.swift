//
//  NewsRecentController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//import Kingfisher

class NewsRecentController: BaseViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, NewsFavouriteDelegate {

    // MARK: - IBProperties
    @IBOutlet weak var tableViewNewsRecent: UITableView!
    
    // MARK: - Variables
    var newsList = [NewsVo]()
    var pageCount = 0
    var totalCount = 0
    var tappedButton: UIButton?
    
    override func initView() {
        super.initView()
        tableViewNewsRecent.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if LPHUtils.isConnectedToNetwork(showAlert: false, vc: self) {
            fireNewsRecentApi()
        } else {
            newsList.append(contentsOf: DBUtils.fetchNewsList(type: .recent))
            tableViewNewsRecent.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let position = tableViewNewsRecent.contentOffset
        self.newsList.removeAll()
        self.newsList.append(contentsOf: DBUtils.fetchNewsList(type: .recent))
        tableViewNewsRecent.reloadData()
        tableViewNewsRecent.contentOffset = position
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - Actions
    private func populateNews(newsList: [NewsVo], totalFeeds: Int) {
        DBUtils.insertNewsList(newsList: newsList, type: .recent)
        self.newsList.append(contentsOf: newsList)
        self.totalCount = totalFeeds
        tableViewNewsRecent.reloadData()
        if(newsList.count == 0) {
            showNoDataText(message: "No news available.", tableView: tableViewNewsRecent)
        }
    }
    
    private func processMarkFavourite(newsIndex: Int, isFavourite: Bool) {
        toggleStarButton(isFavourite)
        newsList[newsIndex].isFavourite = isFavourite
        if isFavourite {
            DBUtils.insertNewsList(newsList: [newsList[newsIndex]], type: .favourite)
        } else {
            DBUtils.deleteNews(newsId: newsList[newsIndex].id, type: .favourite)
        }
        DBUtils.insertNewsList(newsList: [newsList[newsIndex]], type: .recent)
    }
    
    private func toggleStarButton(_ isFavourite: Bool) {
        if tappedButton != nil {
            if isFavourite {
                tappedButton?.setImage(#imageLiteral(resourceName: "ic_star_fill"), for: .normal)
            } else {
                tappedButton?.setImage(#imageLiteral(resourceName: "ic_star_empty"), for: .normal)
            }
        }
    }
    
    //MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newsRecent) as! NewsCell
        cell.selectionStyle = .none
        let currentNews = newsList[indexPath.item]
        print("------- \(currentNews.isRead)")
        if currentNews.isRead {
            cell.labelTitle.font = UIFont.init(name: "OpenSans", size: 15)
            cell.labelDescription.textColor = UIColor.lightGray
        } else {
            cell.labelTitle.font = UIFont.init(name: "OpenSans-Bold", size: 15)
            cell.labelDescription.textColor = UIColor.black
        }
        cell.labelTitle.text = currentNews.title
        cell.labelDescription.text = currentNews.description
        cell.labelTimeStamp.text = currentNews.date
        if currentNews.isFavourite {
            cell.buttonFavouriteStar.setImage(#imageLiteral(resourceName: "ic_star_fill"), for: .normal)
        } else {
            cell.buttonFavouriteStar.setImage(#imageLiteral(resourceName: "ic_star_empty"), for: .normal)
        }
        cell.buttonFavouriteStar.tag = indexPath.item
        cell.buttonFavouriteStar.addTarget(self, action: #selector(onTapFavourite(sender:)), for: .touchDown)
        
//        cell.imageViewNews.kf.indicatorType = .activity
//        cell.imageViewNews.kf.setImage(with:  URL(string: currentNews.imageUrl))
        cell.imageViewNews.contentMode = UIViewContentMode.scaleAspectFill
        
        // Checking for pagination
        if indexPath.item == (newsList.count - 1) && totalCount > newsList.count {
            pageCount += PAGE_LIMIT
            fireNewsRecentApi()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LPHUtils.checkNetworkConnection() {
            navigateToNewsDetails(selectedNews: newsList[indexPath.item])
        } else {
            showToast(message: AlertMessage.noNetwork)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    //MARK: - IBActions
    @objc func onTapFavourite(sender: UIButton) {
        if let newsController = parent as? NewsController {
            newsController.refreshCategoryController()
        }
        tappedButton = sender
        animateButton(sender, 0.2) {}
        if LPHUtils.getLoginVo().loginType != .withoutLogin {
            let newsIndex = sender.tag
            let selectedNews = newsList[newsIndex]
            fireMarkFavouriteApi(newsId: selectedNews.id, markAsFavourite: !selectedNews.isFavourite, index: newsIndex)
        } else {
            showToast(message: AlertMessage.login)
        }
    }
    
    //MARK: - Api
    private func fireNewsRecentApi() {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            lphService.fetchNewsList(pageCount: self.pageCount, isFetchingFavourite: false) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.populateNews(newsList: lphResponse.getResult(), totalFeeds: lphResponse.getTotalCount())
                }
                self.hideLoadingIndicator()
            }
        } catch let error {
            
        }
    }
    
    private func fireMarkFavouriteApi(newsId: String, markAsFavourite: Bool, index newsIndex: Int) {
//        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            self.processMarkFavourite(newsIndex: newsIndex, isFavourite: markAsFavourite)
            lphService.markFavourite(newsId: newsId, markAsFavourite: markAsFavourite) { (lphResponse) in
                if lphResponse.isSuccess() {
//                    self.processMarkFavourite(newsIndex: newsIndex, isFavourite: markAsFavourite)
                }
//                self.hideLoadingIndicator()
            }
        } catch let error as LPHException<NewsError> {
            self.hideLoadingIndicator()
            showToast(message: error.errorMessage)
        } catch {
            
        }
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

// MARK: - UITableViewCell
class NewsCell: UITableViewCell {
    
    @IBOutlet weak var imageViewNews: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTimeStamp: UILabel!
    @IBOutlet weak var buttonFavouriteStar: UIButton!
    
    
}
