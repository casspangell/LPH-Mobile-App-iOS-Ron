//
//  NewsController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class NewsController: ButtonBarPagerTabStripViewController {

    // MARK: - IBProperties
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var viewNewsRecentContainer: UIView!
    @IBOutlet weak var viewNewsCategoryContainer: UIView!
    @IBOutlet weak var viewNewsFavouritesContainer: UIView!
    @IBOutlet weak var labelTabRecent: UILabel!
    @IBOutlet weak var labelTabCategory: UILabel!
    @IBOutlet weak var labelTabFavorites: UILabel!
    
    // MARK: - Variables
    public enum NewsTab: Int {
        case recent
        case categories
        case favourites
    }
    private var selectedTab: NewsTab?
    private var newsViewControllers = [UIViewController]()
    
    // MARK: - Views
    override func viewDidLoad() {
        scrollViewContainer.isScrollEnabled = false
        containerView = scrollViewContainer
        settings.style.buttonBarHeight = 0
        super.viewDidLoad()
        populateTab(currentTab: .recent)
    }
    
    // MARK: - XLPagerTabStrip
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return generateTab()
    }
    
    //MARK: - IBActions
    @IBAction func onTapNewsRecent(_ sender: UITapGestureRecognizer) {
        if selectedTab! != .recent {
            populateTab(currentTab: .recent)
        }
    }
    
    @IBAction func onTapNewsCategory(_ sender: UITapGestureRecognizer) {
        if selectedTab! != .categories {
            populateTab(currentTab: .categories)
        }
    }
    
    @IBAction func onTapNewsFavourites(_ sender: UITapGestureRecognizer) {
        if selectedTab! != .favourites {
            populateTab(currentTab: .favourites)
        }
    }
    
    // MARK: - Actions
    private func generateTab() -> [UIViewController] {
        let newsRecentController = storyboard?.instantiateViewController(withIdentifier: ViewController.newsRecent)
        let newsCategoryController = storyboard?.instantiateViewController(withIdentifier: ViewController.newsCategories)
        let newsFavouriteController = storyboard?.instantiateViewController(withIdentifier: ViewController.newsFavourites)
        newsViewControllers.append(contentsOf: [newsRecentController!, newsCategoryController!, newsFavouriteController!])
        return newsViewControllers
    }
    
    public func populateTab(currentTab: NewsTab) {
        
        moveToViewController(at: currentTab.rawValue)
        
        switch currentTab {
        case .recent:
            viewNewsRecentContainer.backgroundColor = Color.purpleLight
            viewNewsCategoryContainer.backgroundColor = Color.tabDisabled
            viewNewsFavouritesContainer.backgroundColor = Color.tabDisabled
            labelTabRecent.textColor = UIColor.white
            labelTabCategory.textColor = Color.purpleDark
            labelTabFavorites.textColor = Color.purpleDark
            break
            
        case .categories:
            viewNewsRecentContainer.backgroundColor = Color.tabDisabled
            viewNewsCategoryContainer.backgroundColor = Color.purpleLight
            viewNewsFavouritesContainer.backgroundColor = Color.tabDisabled
            labelTabRecent.textColor = Color.purpleDark
            labelTabCategory.textColor = UIColor.white
            labelTabFavorites.textColor = Color.purpleDark
            break
            
        case .favourites:
            viewNewsRecentContainer.backgroundColor = Color.tabDisabled
            viewNewsCategoryContainer.backgroundColor = Color.tabDisabled
            viewNewsFavouritesContainer.backgroundColor = Color.purpleLight
            labelTabRecent.textColor = Color.purpleDark
            labelTabCategory.textColor = Color.purpleDark
            labelTabFavorites.textColor = UIColor.white
            break
        }
        
        selectedTab = currentTab
    }
    
    func navigateToNewsFavourite() {
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(populateNewsFavouriteTab), userInfo: nil, repeats: false)
//        populateTab(currentTab: .favourites)
    }
    
    func refreshCategoryController() {
        if let categoryController = newsViewControllers[1] as? NewsCategoriesController {
            categoryController.refreshCategory = true
        }
    }
    
    @objc private func populateNewsFavouriteTab() {
        populateTab(currentTab: .favourites)
    }
    
}
