//
//  ChantReminderController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreData
import UserNotifications

class ChantReminderController: BaseViewController, ReminderCallback, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableViewReminder: UITableView!
    
    // MARK: - Variables
    var reminderList = [Reminder]()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderList.append(contentsOf: AlarmUtils.fetchCoreDataReminderList())
        if reminderList.count == 0 {
            showNoDataText(message: NSLocalizedString("No reminder added.", comment: ""), tableView: tableViewReminder)
        }
        tableViewReminder.reloadData()
    }
    
    @objc func update() {
        print("update fired")
    }
    
    override func initView() {
        super.initView()
        tableViewReminder.separatorStyle = .none
    }
    
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ChantReminderCell?
        if indexPath.item == reminderList.count {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.chantReminderDummy) as! ChantReminderCell
            cell?.selectionStyle = .none
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.chantReminder) as! ChantReminderCell
            let currentReminder = reminderList[indexPath.item]
            cell?.selectionStyle = .none
            cell?.labelHour.text = String(format: "%02d", Int(currentReminder.hour!)!)
            cell?.labelMinute.text = String(format: "%02d", Int(currentReminder.minute!)!)
            cell?.labelAmPm.text = currentReminder.amPm
            cell?.switchActive.isOn = currentReminder.isActivated
            var repeatText: String
            if currentReminder.repeatDays == "Off" {
                repeatText = NSLocalizedString("Repeat - Off", comment: "")
            } else {
                repeatText = "\(NSLocalizedString("Repeats ", comment: "")) \((currentReminder.repeatDays)!)"
            }
            cell?.labelRepeat.text = repeatText
            cell?.switchActive.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reminderList.count > 0 {
            navigateToReminderAddEditController(reminder: reminderList[indexPath.item], type: .edit)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    // MARK: - IBActions
    @IBAction func onTapAddReminder(_ sender: UIButton) {

        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
                print(item)
            }
        }
        if reminderList.count < 10 {
            navigateToReminderAddEditController(reminder: nil, type: .add)
        } else {
            showToast(message: NSLocalizedString("Maximum number of reminders reached.", comment: "") )
        }
        
    }
    
    // MARK: - Actions
    @objc func switchValueChanged(sender: UISwitch) {
        let cell:UITableViewCell = (sender.superview)?.superview as! UITableViewCell
        let indexPath:IndexPath = self.tableViewReminder.indexPath(for: cell)!
        let selectedReminder = reminderList[indexPath.item]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DatePattern.parse
        let updatedDate = dateFormatter.date(from: selectedReminder.fullTime!)
        let oldTime = String(format: "%02d:%02d", Int(selectedReminder.hour!)!, Int(selectedReminder.minute!)!)
        AlarmUtils.updateCoreDataReminder(reminder: selectedReminder, newDate: updatedDate!, oldTime: oldTime, isOn: sender.isOn)
    }
    
    // MARK: - Navigation
    private func navigateToReminderAddEditController(reminder: Reminder?, type: ChantReminderAddEditController.ReminderAddEditType?) {
        let reminderAddEditController = storyboard?.instantiateViewController(withIdentifier: ViewController.chantReminderAddEdit) as! ChantReminderAddEditController
        reminderAddEditController.reminder = reminder
        reminderAddEditController.type = type!
        reminderAddEditController.callback = self
        present(reminderAddEditController, animated: true, completion: nil)
    }
    
    // MARK: - Callback
    func refreshView() {
        reminderList.removeAll()
        reminderList.append(contentsOf: AlarmUtils.fetchCoreDataReminderList())
        tableViewReminder.reloadData()
        if reminderList.count == 0 {
            showNoDataText(message: NSLocalizedString("No reminder added.", comment: ""), tableView: tableViewReminder)
        } else {
            tableViewReminder.backgroundView = nil
        }
    }
    
}

protocol ReminderCallback {
    func refreshView()
}

public class ChantReminderCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelAmPm: UILabel!
    @IBOutlet weak var switchActive: UISwitch!
    @IBOutlet weak var labelRepeat: UILabel!
}
