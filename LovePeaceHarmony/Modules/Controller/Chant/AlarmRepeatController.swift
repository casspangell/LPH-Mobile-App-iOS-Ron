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
    
    @IBOutlet weak var selectRepeatLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var everydayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectRepeatLabel.text = NSLocalizedString("Select Repeat", comment: "")
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        everydayLabel.text = NSLocalizedString("Everyday", comment: "")
        sundayLabel.text = NSLocalizedString("Sunday", comment: "")
        mondayLabel.text = NSLocalizedString("Monday", comment: "")
        tuesdayLabel.text = NSLocalizedString("Tuesday", comment: "")
        wednesdayLabel.text = NSLocalizedString("Wednesday", comment: "")
        thursdayLabel.text = NSLocalizedString("Thursday", comment: "")
        fridayLabel.text = NSLocalizedString("Friday", comment: "")
        saturdayLabel.text = NSLocalizedString("Saturday", comment: "")

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
            if repeatText! == NSLocalizedString("Every Day", comment: "") {
                switchEveryday.isOn = true
                activateSwitches(isActivate: false)
            } else if repeatText! != NSLocalizedString("Off", comment: "") {
                for day in (repeatText?.split(separator: " "))! {
                    if day == NSLocalizedString("Sun", comment: "") {
                        switchSunday.isOn = true
                    } else if day == NSLocalizedString("Mon", comment: "") {
                        switchMonday.isOn = true
                    } else if day == NSLocalizedString("Tue", comment: "") {
                        switchTuesday.isOn = true
                    } else if day == NSLocalizedString("Wed", comment: "") {
                        switchWednesday.isOn = true
                    } else if day == NSLocalizedString("Thu", comment: "") {
                        switchThursday.isOn = true
                    } else if day == NSLocalizedString("Fri", comment: "") {
                        switchFriday.isOn = true
                    } else if day == NSLocalizedString("Sat", comment: "") {
                        switchSaturday.isOn = true
                    }
                }
            }
        }
        
    }
    
    private func getRepeatText(_ repeatStream: [Bool]) -> String {
        repeatText = ""
        if repeatStream.count == 0 {
            repeatText = NSLocalizedString("Off", comment: "")
        } else {
            if repeatStream[ChantReminderAddEditController.ReminderRepeat.everyDay.rawValue] {
                repeatText = NSLocalizedString("Every Day", comment: "")
            } else {
                if repeatText == nil {
                    repeatText = ""
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.sunday.rawValue] {
                    repeatText! += NSLocalizedString("Sun", comment: "")
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.monday.rawValue]{
                    repeatText! += " \(NSLocalizedString("Mon", comment: ""))"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.tuesday.rawValue] {
                    repeatText! += " \(NSLocalizedString("Tue", comment: ""))"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.wednesday.rawValue] {
                    repeatText! += " \(NSLocalizedString("Wed", comment: ""))"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.thursday.rawValue] {
                    repeatText! += " \(NSLocalizedString("Thu", comment: ""))"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.friday.rawValue] {
                    repeatText! += " \(NSLocalizedString("Fri", comment: ""))"
                }
                if repeatStream[ChantReminderAddEditController.ReminderRepeat.saturday.rawValue] {
                    repeatText! += " \(NSLocalizedString("Sat", comment: ""))"
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
