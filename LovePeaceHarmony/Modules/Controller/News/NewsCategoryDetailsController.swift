//
//  NewsCategoryDetailsController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 19/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
//import Kingfisher

class NewsCategoryDetailsController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var isFirstLaunch = true
    var categoryId: String?
    private var category: CategoryVo?
    private var newsList = [NewsVo]()
    private var pageCount = 0
    private var totalCount = 0
    var tappedButton: UIButton?
    
    // MARK: - IBOutlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPostCount: UILabel!
    @IBOutlet weak var labelUnreadCount: UILabel!
    @IBOutlet weak var labelFavouritesCount: UILabel!
    @IBOutlet weak var tableViewNewsList: UITableView!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        if categoryId != nil {
            fireCategoryNewsListApi(categoryId: categoryId!)
        }
    }
    
    override func initView() {
        super.initView()
        tableViewNewsList.separatorStyle = .none
        if category != nil {
            populateCategoryDetails()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateCategoryDetails()
    }
    
    private func populateCategoryDetails() {
        category = DBUtils.fetchCategory(categoryId: categoryId!)
        let totalPostCount = Int((category?.totalPostCount)!)!
        var totalPostCountText: String = (category?.totalPostCount)!
        if totalPostCount > 1 {
            totalPostCountText  += " posts"
        } else {
            totalPostCountText += " post"
        }
        
        let unreadPostCount = Int((category?.unreadPostCount)!)!
        labelUnreadCount.text = "\(unreadPostCount) unread"
        
        let favouritePostCount = Int((category?.favouritePostCount)!)!
        var favouritePostCountText: String = (category?.favouritePostCount)!
        if favouritePostCount > 1 {
            favouritePostCountText += " favourites"
        } else {
            favouritePostCountText += " favourite"
        }
        
        labelTitle.text = (category?.name)!
        labelPostCount.text = totalPostCountText
        labelFavouritesCount.text = favouritePostCountText
        
        if !isFirstLaunch {
            isFirstLaunch = false
            newsList.removeAll()
            newsList.append(contentsOf: DBUtils.fetchNewsList(type: .category))
            tableViewNewsList.reloadData()
        }
    }
    
    // MARK: - IBActions
    @IBAction func onTapBack(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onTapFavourite(sender: UIButton) {
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
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newsCategoryDetails) as! NewsCell
        let currentNews = newsList[indexPath.item]
        cell.labelTitle.text = currentNews.title
        cell.labelTimeStamp.text = currentNews.date
        cell.labelDescription.text = currentNews.description
//        cell.imageViewNews.kf.indicatorType = .activity
//        cell.imageViewNews.kf.setImage(with: URL(string: currentNews.imageUrl))
        cell.imageViewNews.contentMode = UIViewContentMode.scaleAspectFill
        if currentNews.isFavourite {
            cell.buttonFavouriteStar.setImage(#imageLiteral(resourceName: "ic_star_fill"), for: .normal)
        } else {
            cell.buttonFavouriteStar.setImage(#imageLiteral(resourceName: "ic_star_empty"), for: .normal)
        }
        cell.buttonFavouriteStar.tag = indexPath.item
        cell.buttonFavouriteStar.addTarget(self, action: #selector(onTapFavourite(sender:)), for: .touchDown)
        
        if currentNews.isRead {
            cell.labelTitle.font = UIFont.init(name: "OpenSans", size: 15)
            cell.labelDescription.textColor = UIColor.lightGray
        } else {
            cell.labelTitle.font = UIFont.init(name: "OpenSans-Bold", size: 15)
            cell.labelDescription.textColor = UIColor.black
        }
        
        // Checking for pagination
        if indexPath.item == (newsList.count - 1) && totalCount > newsList.count {
            pageCount += PAGE_LIMIT
            fireCategoryNewsListApi(categoryId: (category?.id)!)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LPHUtils.checkNetworkConnection() {
            navigateToNewsDetails(selectedNews: newsList[indexPath.item])
        } else {
            showToast(message: "You need a working internet connection to view the details.")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - Api
    private func fireCategoryNewsListApi(categoryId: String) {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            lphService.fetchNewsListFromCategory(categoryId: categoryId, pageCount: pageCount) { (lphResponse) in
                if lphResponse.isSuccess() {
                    self.populateNews(newsList: lphResponse.getResult())
                }
                self.hideLoadingIndicator()
            }
        } catch let error as LPHException<NewsError> {
            self.hideLoadingIndicator()
            showToast(message: error.errorMessage)
        } catch let error {
            
        }
    }
    
    private func fireMarkFavouriteApi(newsId: String, markAsFavourite: Bool, index newsIndex: Int) {
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            self.processMarkFavourite(newsIndex: newsIndex, isFavourite: markAsFavourite)
            lphService.markFavourite(newsId: newsId, markAsFavourite: markAsFavourite) { (lphResponse) in
                if lphResponse.isSuccess() {
                }
            }
        } catch let error as LPHException<NewsError> {
            showToast(message: error.errorMessage)
        } catch {
            
        }
    }
    
    // MARK: - Actions
    private func populateNews(newsList: [NewsVo]) {
        if pageCount == 0 {
            DBUtils.deleteNews(newsId: nil, type: .category)
        }
        DBUtils.insertNewsList(newsList: newsList, type: .category)
        self.newsList.append(contentsOf: newsList)
        tableViewNewsList.reloadData()
    }
    
    private func processMarkFavourite(newsIndex: Int, isFavourite: Bool) {
        toggleStarButton(isFavourite)
        newsList[newsIndex].isFavourite = isFavourite
        if isFavourite {
            print(category?.favouritePostCount)
            let favouriteCount = Int((category?.favouritePostCount)!)!
            category?.favouritePostCount = String(favouriteCount + 1)
            DBUtils.updateCategory(category: category!)
            populateCategoryDetails()
            DBUtils.insertNewsList(newsList: [newsList[newsIndex]], type: .favourite)
        } else {
            let favouriteCount = Int((category?.favouritePostCount)!)!
            category?.favouritePostCount = String(favouriteCount - 1)
            DBUtils.updateCategory(category: category!)
            populateCategoryDetails()
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
    
    
    // MARK: - Navigation
    private func navigateToNewsDetails(selectedNews: NewsVo) {
        let newsDetailsController = storyboard?.instantiateViewController(withIdentifier: ViewController.newsDetails) as! NewsDetailsController
        newsDetailsController.newsVo = selectedNews
        newsDetailsController.categoryId = categoryId
        present(newsDetailsController, animated: true, completion: nil)
    }
    
}
