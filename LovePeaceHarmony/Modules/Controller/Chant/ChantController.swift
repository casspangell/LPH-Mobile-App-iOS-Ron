//
//  ChantController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MaterialShowcase

class ChantController: ButtonBarPagerTabStripViewController, MaterialShowcaseDelegate {
    
    // MARK: - Variables
    private enum ChantTab: Int {
        case chantNow
        case chantReminders
        case chantMilestones
    }
    private var selectedTab: ChantTab?
    private var chantViewControllers = [UIViewController]()
    private var showcaseViewIndex = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewChantNowContainer: UIView!
    @IBOutlet weak var viewReminderContainer: UIView!
    @IBOutlet weak var viewMilestoneContainer: UIView!
    @IBOutlet weak var labelTabChantNow: UILabel!
    @IBOutlet weak var labelTabReminder: UILabel!
    @IBOutlet weak var labelTabMilestone: UILabel!
    @IBOutlet weak var chantNavTab: UITabBarItem!
    
    // MARK: - View
    override func viewDidLoad() {
        scrollViewContainer.isScrollEnabled = false
        containerView = scrollViewContainer
        settings.style.buttonBarHeight = 0
        
        labelTabChantNow.text = NSLocalizedString("Chant Now", comment: "")
        labelTabReminder.text = NSLocalizedString("Reminders", comment: "")
        labelTabMilestone.text = NSLocalizedString("Milestones", comment: "")
        chantNavTab.title = NSLocalizedString("Chant", comment: "")

        super.viewDidLoad()
        let chantNowController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantNow)
        let chantReminderController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantReminder)
        let chantMilestoneController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantMilestone)
        chantViewControllers.append(contentsOf: [chantNowController!, chantReminderController!, chantMilestoneController!])
        populateTab(currentTab: .chantNow)
    }
    
    //Check to see if the tutorial splash is needed. The bool is set in appdelegate if user 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        if LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isTutorialShown) == true {
            renderShowcaseView()
        }
    }
    
    private func renderShowcaseView() {
        switch showcaseViewIndex {
            
        case 0:
            LPHUtils.renderShowcaseView(title: NSLocalizedString("Chant any time", comment: ""), view: viewChantNowContainer, delegate: self)
            break
            
        case 1:
            LPHUtils.renderShowcaseView(title: NSLocalizedString("Set reminders to chant", comment: ""), view: viewReminderContainer, delegate: self)
            break
            
        case 2:
            LPHUtils.renderShowcaseView(title: NSLocalizedString("View your milestones", comment: ""), view: viewMilestoneContainer, delegate: self)
            break
            
//        case 3:
//            //Reset tutorial
//            let chantNowController = chantViewControllers[0] as! ChantNowController
//            chantNowController.renderShowcaseView()
//            break
            
        default:
            break
        }
    }
    
    // MARK: - MaterialShowcaseDelegate
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        showcaseViewIndex += 1
        renderShowcaseView()
    }

    
    // MARK: - XLPagerTabStrip
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return generateTabs()
    }
    
    // MARK: - IBActions
    @IBAction func onTapChantNow(_ sender: UITapGestureRecognizer) {
        if selectedTab! != .chantNow {
            populateTab(currentTab: .chantNow)
        }
    }
    
    @IBAction func onTapReminders(_ sender: UITapGestureRecognizer) {
        if selectedTab! != .chantReminders {
            populateTab(currentTab: .chantReminders)
        }
    }
    
    @IBAction func onTapMilestones(_ sender: UITapGestureRecognizer) {
        if selectedTab! != .chantMilestones {
            populateTab(currentTab: .chantMilestones)
        }
    }
    
    // MARK: - Actions
    private func generateTabs() -> [UIViewController] {
        let chantNowController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantNow)
        let chantReminderController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantReminder)
        let chantMilestoneController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantMilestone)
        chantViewControllers.append(contentsOf: [chantNowController!, chantReminderController!, chantMilestoneController!])
        return chantViewControllers
    }
    private func populateTab(currentTab: ChantTab) {
        
        moveToViewController(at: currentTab.rawValue)
        switch currentTab {
        case .chantNow:
            viewChantNowContainer.backgroundColor = Color.orange
            viewReminderContainer.backgroundColor = Color.tabDisabled
            viewMilestoneContainer.backgroundColor = Color.tabDisabled
            labelTabChantNow.textColor = UIColor.white
            labelTabReminder.textColor = Color.purpleDark
            labelTabMilestone.textColor = Color.purpleDark
            break
            
        case .chantReminders:
            viewChantNowContainer.backgroundColor = Color.tabDisabled
            viewReminderContainer.backgroundColor = Color.orange
            viewMilestoneContainer.backgroundColor = Color.tabDisabled
            labelTabChantNow.textColor = Color.purpleDark
            labelTabReminder.textColor = UIColor.white
            labelTabMilestone.textColor = Color.purpleDark
            break
            
        case .chantMilestones:
            viewChantNowContainer.backgroundColor = Color.tabDisabled
            viewReminderContainer.backgroundColor = Color.tabDisabled
            viewMilestoneContainer.backgroundColor = Color.orange
            labelTabChantNow.textColor = Color.purpleDark
            labelTabReminder.textColor = Color.purpleDark
            labelTabMilestone.textColor = UIColor.white
            break
            
        }
        
        selectedTab = currentTab
    }
    
    func stopChantingPlayback() {
        if let chantNowController = chantViewControllers[0] as? ChantNowController {
            chantNowController.stopChantingIfPlaying()
        }
    }
    
    func navigateToChantMilestone() {
        populateTab(currentTab: .chantMilestones)
    }
    
    
}
