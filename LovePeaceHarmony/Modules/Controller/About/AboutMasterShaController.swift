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
        let masterShaDescription = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.drSha, comment: ""))
        let masterShaDescription1 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.drSha1, comment: ""))
        let masterShaDescription2 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.drSha2, comment: ""))
//        masterShaDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 200, length: 13))
//        masterShaDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 592, length: 10))
        
        let wholeMasterShaDescription = NSMutableAttributedString(string:"\(masterShaDescription)\n\n\(masterShaDescription1)\n\n\(masterShaDescription2)")
        wholeMasterShaDescription.addAttribute(.font, value: UIFont(name: "OpenSans", size: 15)!, range: NSRange(location: 0, length: wholeMasterShaDescription.length))
        labelDescription.attributedText = wholeMasterShaDescription
    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
}
