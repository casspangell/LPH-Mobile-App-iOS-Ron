//
//  AlarmSoundListController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 04/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit

class AlarmSoundListController: UIViewController {
    
    // MARK: - Variables
    
    // MARK: IBOutlets
    @IBOutlet weak var tableViewSoundList: UITableView!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func onTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
