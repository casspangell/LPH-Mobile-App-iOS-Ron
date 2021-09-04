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
        let movementDescription2 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.movement2, comment: "") )
        let movementDescription3 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.movement3, comment: "") )
        let movementDescription4 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.movement4, comment: "") )
        let movementDescription5 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.movement5, comment: "") )
        let movementDescription6 = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.movement6, comment: "") )
        
        let wholeMovementDescription = NSMutableAttributedString(string:"\(movementDescription)\n\n\(movementDescription2)\n\n\(movementDescription3)\n\n\(movementDescription4)\n\n\(movementDescription5)\n\n\(movementDescription6)")
        wholeMovementDescription.addAttribute(.font, value: UIFont(name: "OpenSans", size: 15)!, range: NSRange(location: 0, length: wholeMovementDescription.length))

        labelMovementDescription.attributedText = wholeMovementDescription

    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }

}
