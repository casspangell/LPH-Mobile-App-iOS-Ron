//
//  AboutMasterShaController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 13/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AboutMasterShaController: BaseViewController, IndicatorInfoProvider {

    // MARK: - IBOutlets
    @IBOutlet weak var imageViewHeader: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    
    // MARK: - Views
    override func initView() {
        super.initView()
        imageViewHeader.contentMode = UIViewContentMode.scaleAspectFill
        let masterShaDescription = NSMutableAttributedString(string: AboutDescription.drSha)
        masterShaDescription.addAttribute(.font, value: UIFont(name: "OpenSans", size: 15)!, range: NSRange(location: 0, length: masterShaDescription.length))
        masterShaDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 200, length: 13))
        masterShaDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 592, length: 10))
        labelDescription.attributedText = masterShaDescription
    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
}
