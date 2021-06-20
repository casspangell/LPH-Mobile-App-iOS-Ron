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
    @IBOutlet weak var labelMovementDescription: UILabel!
    
    // MARK: - Views
    override func initView() {
        super.initView()
        imageViewHeader.contentMode = UIViewContentMode.scaleAspectFill
        let movementDescription = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.movement, comment: "") )
        movementDescription.addAttribute(.font, value: UIFont(name: "OpenSans", size: 15)!, range: NSRange(location: 0, length: movementDescription.length))
        movementDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 561, length: 23))
        movementDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 1723, length: 23))
        movementDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 2045, length: 23))
        labelMovementDescription.attributedText = movementDescription
    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }

}
