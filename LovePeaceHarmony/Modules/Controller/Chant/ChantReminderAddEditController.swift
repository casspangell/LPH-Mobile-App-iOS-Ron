//
//  ChantReminderAddEditController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 01/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import UserNotifications

class ChantReminderAddEditController: BaseViewController {
    
    // MARK: - Variables
    var reminder: Reminder?
    var repeatText: String?
    var repeatStream = [Bool]()
    var type: ReminderAddEditType?
    var callback: ReminderCallback?
    enum ReminderAddEditType: Int {
        case add
        case edit
    }
    enum ReminderRepeat: Int {
        case everyDay
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var datePickerReminder: UIDatePicker!
    @IBOutlet weak var labelRepeat: UILabel!
    @IBOutlet weak var labelAlarmSoundName: UILabel!
    @IBOutlet weak var buttonDeleteReminder: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editReminderLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var soundLabel: UILabel!
    
    // MARK: - View
    override func viewDidLoad() {
        labelRepeat.text = NSLocalizedString("Repeat", comment: "")
        labelAlarmSoundName.text = NSLocalizedString("Default", comment: "")
        buttonDeleteReminder.setTitle(NSLocalizedString("Delete Reminder", comment: ""), for: .normal) 
        
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        editReminderLabel.text = NSLocalizedString("Edit Reminder", comment: "")
        repeatLabel.text = NSLocalizedString("Repeat", comment: "")
        soundLabel.text = NSLocalizedString("Sound", comment: "")
    }
    override func initView() {
        super.initView()
        if type == .edit {
            repeatText = reminder?.repeatDays
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            var hours: String?
            if reminder?.amPm == TIME_PM {
                if Int((reminder?.hour)!) != 12 {
                    hours = String(Int((reminder?.hour)!)! + 12)
                } else {
                 hours = (reminder?.hour)!
                }
            } else {
                hours = (reminder?.hour)!
            }
            datePickerReminder.date = dateFormatter.date(from: "\(hours!):\((reminder?.minute)!)")!
            labelRepeat.text = reminder?.repeatDays
        } else {
            buttonDeleteReminder.isHidden = true
        }
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                //                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["jjffff"])
                print(request)
            }
        })
    }
    
    //MARK: - IBActions
    @IBAction func onTapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapSave(_ sender: UIButton) {
        let date = datePickerReminder.date
        var hour = Calendar.current.component(.hour, from: date)
        let minute = String(Calendar.current.component(.minute, from: date))
        var amPm: String?
        if hour >= 12 {
            if hour != 12 {
                hour -= 12
            }
            amPm = TIME_PM
        } else {
            amPm = TIME_AM
        }
        if type == .add {
            print(amPm!)
            if AlarmUtils.isSameReminderExist(hour: String(hour), minute: minute, amPm: amPm!) {
                showToast(message: NSLocalizedString("Alarm already added for this time!", comment: ""))
            }  else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DatePattern.parse
                
                AlarmUtils.saveCoreDataReminder(scheduledDate: date, reminderId: String(arc4random()), hour: String(hour), minute: minute, amPm: amPm!, repeatDays: repeatText, fullTime: dateFormatter.string(from: date))
                callback?.refreshView()
                dismiss(animated: true, completion: nil)
            }
        } else {
            reminder?.hour = String(hour)
            reminder?.minute = minute
            reminder?.amPm = amPm!
            reminder?.repeatDays = repeatText
            let oldTime = String(format: "%02d:%02d", Int((reminder?.hour!)!)!, Int((reminder?.minute!)!)!)
            AlarmUtils.updateCoreDataReminder(reminder: reminder!, newDate: date, oldTime: oldTime, isOn: true)
            callback?.refreshView()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func onTapDelete(_ sender: UIButton) {
        showAlertConfirm(title: "", message: NSLocalizedString("Do you want to delete the alarm?", comment: ""), vc: self, callback: { (UIAlertAction) in
            AlarmUtils.deleteCoreDataReminder(reminder: self.reminder!)
            self.callback?.refreshView()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func onTapRepeat(_ sender: UITapGestureRecognizer) {
        navigateToRepeatSelect()
    }
    
    @IBAction func onTapAlarmSound(_ sender: UITapGestureRecognizer) {
        navigateToAlarmSoundSelect()
    }
    
    @IBAction func unwindSequeRepeatDone(segue: UIStoryboardSegue) {
        let sourceController = segue.source as! AlarmRepeatController
        repeatStream = sourceController.repeatStream
        print(repeatStream)
        repeatText = sourceController.repeatText
        labelRepeat.text = repeatText!
    }
    
    // MARK: - Navigation
    private func navigateToRepeatSelect() {
        let alarmRepeatController = storyboard?.instantiateViewController(withIdentifier: ViewController.alarmRepeat) as! AlarmRepeatController
        alarmRepeatController.repeatStream = repeatStream
        alarmRepeatController.repeatText = repeatText
        present(alarmRepeatController, animated: true, completion: nil)
    }
    
    private func navigateToAlarmSoundSelect() {
        let alarmSoundListNavigationController = storyboard?.instantiateViewController(withIdentifier: NavigationController.alarmSelect) as! UINavigationController
        let alarmSoundListController = alarmSoundListNavigationController.viewControllers[0] as! AlarmSoundListController
        present(alarmSoundListNavigationController, animated: true, completion: nil)
    }
    
    
    
}
