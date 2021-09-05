//
//  AboutMovementController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 13/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AboutMovementController: BaseViewController, IndicatorInfoProvider {

    // MARK: - IBOutlets
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    @IBOutlet weak var descriptionOne: UILabel!
    @IBOutlet weak var descriptionTwo: UILabel!
    @IBOutlet weak var descriptionThree: UILabel!
    @IBOutlet weak var descriptionFour: UILabel!
    @IBOutlet weak var descriptionFive: UILabel!
    @IBOutlet weak var descriptionSix: UILabel!
    
    // MARK: - Views
    override func initView() {
        super.initView()
        imageViewHeader.contentMode = UIViewContentMode.scaleAspectFill
        
        let movementDescription = NSLocalizedString(AboutDescription.movement, comment: "")
        let movementDescription2 = NSLocalizedString(AboutDescription.movement2, comment: "")
        let movementDescription3 = NSLocalizedString(AboutDescription.movement3, comment: "")
        let movementDescription4 = NSLocalizedString(AboutDescription.movement4, comment: "")
        let movementDescription5 = NSLocalizedString(AboutDescription.movement5, comment: "")
        let movementDescription6 = NSLocalizedString(AboutDescription.movement6, comment: "")

        descriptionOne.text = movementDescription
        descriptionTwo.text = movementDescription2
        descriptionThree.text = movementDescription3
        descriptionFour.text = movementDescription4
        descriptionFive.text = movementDescription5
        descriptionSix.text = movementDescription6

    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }

}
