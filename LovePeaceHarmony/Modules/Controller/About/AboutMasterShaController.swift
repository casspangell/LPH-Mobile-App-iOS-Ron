//
//  AboutMasterShaController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 13/12/17.
//  Updated by Cass Pangell on 9/5/21.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AboutMasterShaController: BaseViewController, IndicatorInfoProvider {

    // MARK: - IBOutlets
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    @IBOutlet weak var descriptionOne: UILabel!
    @IBOutlet weak var descriptionTwo: UILabel!
    @IBOutlet weak var descriptionThree: UILabel!

    
    // MARK: - Views
    override func initView() {
        super.initView()
        imageViewHeader.contentMode = UIViewContentMode.scaleAspectFill
        
        let masterShaDescription = NSLocalizedString(AboutDescription.drSha, comment: "")
        let masterShaDescription1 = NSLocalizedString(AboutDescription.drSha1, comment: "")
        let masterShaDescription2 = NSLocalizedString(AboutDescription.drSha2, comment: "")

        descriptionOne.text = masterShaDescription
        descriptionTwo.text = masterShaDescription1
        descriptionThree.text = masterShaDescription2

    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
}
