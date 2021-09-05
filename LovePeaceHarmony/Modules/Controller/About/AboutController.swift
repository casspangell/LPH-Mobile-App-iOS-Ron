//
//  AboutController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AboutController: ButtonBarPagerTabStripViewController {

    // MARK: - Variables
    private enum AboutTab: Int {
        case song
        case movement
        case masterSha
    }
    private var selectedTab: AboutTab?
    private var aboutViewControllers = [UIViewController]()
    
    // MARK: - IBProperties
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var viewTabSongContainer: UIView!
    @IBOutlet weak var viewTabMovementContainer: UIView!
    @IBOutlet weak var viewTabMasterShaContainer: UIView!
    @IBOutlet weak var labelTabSong: UILabel!
    @IBOutlet weak var labelTabMovement: UILabel!
    @IBOutlet weak var labelTabMasterSha: UILabel!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var donateNowButton: UIButton!
    @IBOutlet weak var aboutTabBar: UITabBarItem!
    
    
    // MARK: - Views
    override func viewDidLoad() {
        
        labelTabSong.text = NSLocalizedString("The Song", comment: "")
        labelTabMovement.text = NSLocalizedString("The Movement", comment: "")
        labelTabMasterSha.text = NSLocalizedString("Master Sha", comment: "")
        visitWebsiteButton.setTitle(NSLocalizedString("Visit Our Website", comment: ""), for: .normal)
        donateNowButton.setTitle(NSLocalizedString("Donate Now", comment: ""), for: .normal)
        
        scrollViewContainer.isScrollEnabled = false
        containerView = scrollViewContainer
        settings.style.buttonBarHeight = 0
        
        super.viewDidLoad()
        selectedTab = .song
        populateTab(currentTab: .song)
    }
    
    // MARK: - XLPagerTabStrip
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return generateTabs()
    }
    
    // MARK: - Actions
    private func generateTabs() -> [UIViewController] {
        let songController = storyboard?.instantiateViewController(withIdentifier: ViewController.aboutSong)
        let movementController = storyboard?.instantiateViewController(withIdentifier: ViewController.aboutMovement)
        let masterShaController = storyboard?.instantiateViewController(withIdentifier: ViewController.aboutMasterSha)
        aboutViewControllers.append(contentsOf: [songController!, movementController!, masterShaController!])
        return aboutViewControllers
    }
    
    private func populateTab(currentTab: AboutTab) {
        
        moveToViewController(at: currentTab.rawValue)
        switch currentTab {
        case .song:
            viewTabSongContainer.backgroundColor = Color.purpleDark
            viewTabMovementContainer.backgroundColor = Color.tabDisabled
            viewTabMasterShaContainer.backgroundColor = Color.tabDisabled
            labelTabSong.textColor = UIColor.white
            labelTabMovement.textColor = Color.purpleDark
            labelTabMasterSha.textColor = Color.purpleDark
            break
            
        case .movement:
            viewTabSongContainer.backgroundColor = Color.tabDisabled
            viewTabMovementContainer.backgroundColor = Color.purpleDark
            viewTabMasterShaContainer.backgroundColor = Color.tabDisabled
            labelTabSong.textColor = Color.purpleDark
            labelTabMovement.textColor = UIColor.white
            labelTabMasterSha.textColor = Color.purpleDark
            break
            
        case .masterSha:
            viewTabSongContainer.backgroundColor = Color.tabDisabled
            viewTabMovementContainer.backgroundColor = Color.tabDisabled
            viewTabMasterShaContainer.backgroundColor = Color.purpleDark
            labelTabSong.textColor = Color.purpleDark
            labelTabMovement.textColor = Color.purpleDark
            labelTabMasterSha.textColor = UIColor.white
            break
            
        }
        selectedTab = currentTab
    }
    
    //MARK: - IBActions
    @IBAction func onTapTabSong(_ sender: UITapGestureRecognizer) {
        if selectedTab != .song {
            populateTab(currentTab: .song)
        }
    }
    
    @IBAction func onTapTabMovement(_ sender: UITapGestureRecognizer) {
        if selectedTab != .movement {
            populateTab(currentTab: .movement)
        }
    }
    
    @IBAction func onTapMasterSha(_ sender: UITapGestureRecognizer) {
        if selectedTab != .masterSha {
            populateTab(currentTab: .masterSha)
        }
    }
    
    @IBAction func onTapVisitWebsite(_ sender: UIButton) {
        if let url = URL(string: WEBSITE_URL) {
            UIApplication.shared.open(url, options: [:])
        } else {
            print("else")
        }
    }
    
    @IBAction func onTapDonateNow(_ sender: UIButton) {
        if let url = URL(string: DONATE_URL) {
            UIApplication.shared.open(url, options: [:])
        } else {
            print("else")
        }
    }

}
