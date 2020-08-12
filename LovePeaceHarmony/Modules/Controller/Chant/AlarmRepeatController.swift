//
//  AlarmRepeatController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 01/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit

class AlarmRepeatController: BaseViewController {
    
    // MARK: - Variables
    var repeatText: String?
    var repeatStream = [Bool]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var switchEveryday: UISwitch!
    @IBOutlet weak var switchSunday: UISwitch!
    @IBOutlet weak var switchMonday: UISwitch!
    @IBOutlet weak var switchTuesday: UISwitch!
    @IBOutlet weak var switchWednesday: UISwitch!
    @IBOutlet weak var switchThursday: UISwitch!
    @IBOutlet weak var switchFriday: UISwitch!
    @IBOutlet weak var switchSaturday: UISwitch!
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        generateStreamFromRepeatText()
    }
    
    // MARK: - IBActions
    @IBAction func onTapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onValueChangedEveryDay(_ sender: UISwitch) {
        activateSwitches(isActivate: !sender.isOn)
    }
    
    // MARK: - Actions
    private func generateStreamFromRepeatText() {
        activateSwitches(isActivate: true)
        repeatStream.append(false)
        repeatStream.append(false)
        repeatStream.append(false)
        repeatStream.append(false)
        repeatStream.append(false)
        repeatStream.append(false)
        repeatStream.append(false)
        repeatStream.append(false)
        print(repeatText)
        if repeatText != nil {
            if repeatText! == "Every Day" {
                switchEveryday.isOn = true
                activateSwitches(isActivate: false)
            } else if repeatText! != "Off" {
                for day in (repeatText?.split(separator: " "))! {
                    if day == "Sun" {
                        switchSunday.isOn = true
                    } else if day == "Mon" {
                        switchMonday.isOn = true
                    } else if day == "Tue" {
                        switchTuesday.isOn = true
                    } else if day == "Wed" {
                        switchWednesday.isOn = true
                    } else if day == "Thu" {
                        switchThursday.isOn = true
                    } else if day == "Fri" {
                        switchFriday.isOn = true
                    } else if day == "Sat" {
                        switchSaturday.isOn = true
                    }
                }
            }
        }
        
    }
    
    private func getRepeatText(_ repeatStream: [Bool]) -> String {
        repeatText = ""
        if repeatStream.count == 0 {
            repeatText = "Off"
        } else {
            if repeatStream[ChantReminderAddEditController.ReminderRepeat.everyDay.rawValue] {
                repeatText = "Every Day"
            } else {
                if repeatText == nil {
                    repeatText = ""
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.sunday.rawValue] {
                    repeatText! += "Sun"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.monday.rawValue]{
                    repeatText! += " Mon"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.tuesday.rawValue] {
                    repeatText! += " Tue"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.wednesday.rawValue] {
                    repeatText! += " Wed"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.thursday.rawValue] {
                    repeatText! += " Thu"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.friday.rawValue] {
                    repeatText! += " Fri"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.saturday.rawValue] {
                    repeatText! += " Sat"
                }
            }
        }
        return repeatText!
    }
    
    private func activateSwitches(isActivate: Bool) {
        switchSunday.isEnabled = isActivate
        switchMonday.isEnabled = isActivate
        switchTuesday.isEnabled = isActivate
        switchWednesday.isEnabled = isActivate
        switchThursday.isEnabled = isActivate
        switchFriday.isEnabled = isActivate
        switchSaturday.isEnabled = isActivate
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var isAnyRepeatOn = false
        if switchEveryday.isOn {
            isAnyRepeatOn = true
            repeatStream[0] = true
        } else {
            repeatStream[0] = false
            if switchSunday.isOn {
                repeatStream[1] = true
                isAnyRepeatOn = true
            }
            if switchMonday.isOn {
                repeatStream[2] = true
                isAnyRepeatOn = true
            }
            if switchTuesday.isOn {
                repeatStream[3] = true
                isAnyRepeatOn = true
            }
            if switchWednesday.isOn {
                repeatStream[4] = true
                isAnyRepeatOn = true
            }
            if switchThursday.isOn {
                repeatStream[5] = true
                isAnyRepeatOn = true
            }
            if switchFriday.isOn {
                repeatStream[6] = true
                isAnyRepeatOn = true
            }
            if switchSaturday.isOn {
                repeatStream[7] = true
                isAnyRepeatOn = true
            }
        }
        if !isAnyRepeatOn {
            repeatStream.removeAll()
        }
        repeatText = getRepeatText(repeatStream)
    }
    
}
