//
//  NewsCategoriesController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Kingfisher

class NewsCategoriesController: BaseViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var categoryList = [CategoryVo]()
    var pageCount = 0
    var totalCount = 0
    var initialLaunch = true
    var refreshCategory = false
    
    // MARK: - IBProperties
    @IBOutlet weak var tableViewNewsCategory: UITableView!
    
    // MARK: - Views
    override func initView() {
        super.initView()
        tableViewNewsCategory.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if LPHUtils.checkNetworkConnection() {
            fireNewsCategoryApi()
        } else {
            let categoryList = DBUtils.fetchCategoryList()
            populateCategories(categoryList: categoryList, totalCategories: categoryList.count)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initialLaunch {
            self.categoryList.removeAll()
            let dbCategoryList = DBUtils.fetchCategoryList()
            populateCategories(categoryList: dbCategoryList, totalCategories: dbCategoryList.count)
        }
        if !initialLaunch && refreshCategory {
            refreshCategory = false
            pageCount = 0
            categoryList.removeAll()
            tableViewNewsCategory.reloadData()
            fireNewsCategoryApi()
        }
        initialLaunch = false
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.newsCategory) as! NewsCategoryCell
        cell.selectionStyle = .none
        let currentCategory = categoryList[indexPath.item]
        cell.labelName.text = currentCategory.name
        cell.labelUnreadCount.text = "\(currentCategory.unreadPostCount) unread"
        
        let totalPostCount = Int(currentCategory.totalPostCount)!
        var totalPostCountText: String = currentCategory.totalPostCount
        if totalPostCount > 1 {
            totalPostCountText  += " posts"
        } else {
            totalPostCountText += " post"
        }
        
        let favouritePostCount = Int(currentCategory.favouritePostCount)!
        var favouritePostCountText: String = currentCategory.favouritePostCount
        if favouritePostCount > 1 {
            favouritePostCountText += " favourites"
        } else {
            favouritePostCountText += " favourite"
        }
        
        cell.labelPostCount.text = totalPostCountText
        cell.labelFavouritesCount.text = favouritePostCountText
        if currentCategory.imageUrl != "null" && currentCategory.imageUrl != "" {
            cell.imageViewCategory.kf.setImage(with: URL(string: currentCategory.imageUrl))
            cell.imageViewCategory.contentMode = UIViewContentMode.scaleAspectFill
        } else {
            cell.imageViewCategory.image = #imageLiteral(resourceName: "ic_category_placeholder")
        }
        
        
        
        // Checking for pagination
        if indexPath.item == (categoryList.count - 1) && totalCount > categoryList.count {
            pageCount += PAGE_LIMIT
            fireNewsCategoryApi()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LPHUtils.checkNetworkConnection() {
            navigateToCategoryDetails(selectedCategory: categoryList[indexPath.item])
        } else {
            showToast(message: "You need a working internet connection to view the details.")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - Api
    private func fireNewsCategoryApi() {
        showLoadingIndicator()
        do {
            let lphService: LPHService = try LPHServiceFactory<NewsError>.getLPHService()
            lphService.fetchNewsCategoryList(pageCount: self.pageCount) { (lphResponse) in
                if lphResponse.isSuccess() {
                    let categories = lphResponse.getResult()
                    DBUtils.insertCategoryList(categoryList: categories)
                    self.populateCategories(categoryList: lphResponse.getResult(), totalCategories: lphResponse.getTotalCount())
                }
                self.hideLoadingIndicator()
            }
        } catch let error {
            
        }
    }
    
    // MARK: - Actions
    private func populateCategories(categoryList: [CategoryVo], totalCategories: Int) {
        self.categoryList.append(contentsOf: categoryList)
        self.totalCount = totalCategories
        tableViewNewsCategory.reloadData()
        if(categoryList.count == 0) {
            showNoDataText(message: "No Categories available.", tableView: tableViewNewsCategory)
        }
    }
    
    // MARK: - Navigation
    private func navigateToCategoryDetails(selectedCategory: CategoryVo) {
        let categoryDetails = storyboard?.instantiateViewController(withIdentifier: ViewController.newsCategoryDetails) as! NewsCategoryDetailsController
        categoryDetails.categoryId = selectedCategory.id
        present(categoryDetails, animated: true, completion: nil)
    }

}

public class NewsCategoryCell: UITableViewCell {
    
    @IBOutlet weak var imageViewCategory: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPostCount: UILabel!
    @IBOutlet weak var labelUnreadCount: UILabel!
    @IBOutlet weak var labelFavouritesCount: UILabel!
    
}
