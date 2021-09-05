//
//  AboutSongController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 13/12/17.
//  Updated by Cass Pangell on 9/4/21.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import youtube_ios_player_helper

class AboutSongController: BaseViewController, IndicatorInfoProvider, YTPlayerViewDelegate {

    // MARK: Variables
    
    var constraintCalculated = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewVideoContainer: UIView!
    @IBOutlet weak var viewLoadingContainer: UIView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var descriptionOne: UILabel!
    @IBOutlet weak var descriptionTwo: UILabel!
    @IBOutlet weak var descriptionThree: UILabel!
    @IBOutlet weak var descriptionFour: UILabel!
    
    // MARK: - Views
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !constraintCalculated {
            let youtubePlayer: YTPlayerView = YTPlayerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: viewVideoContainer.frame.height))
            activityIndicator.startAnimating()
            youtubePlayer.delegate = self
            youtubePlayer.load(withVideoId: YOUTUBE_SONG_ID)
            viewVideoContainer.addSubview(youtubePlayer)
            constraintCalculated = true
        }
        
        let songTitle = NSMutableAttributedString(string: NSLocalizedString(AboutDescription.songTitle, comment: "") )
        labelTitle.attributedText = songTitle
        
        let songDescription = NSLocalizedString(AboutDescription.songDescription, comment: "")
        let songDescription2 = NSLocalizedString(AboutDescription.songDescription2, comment: "")
        let songDescription3 = NSLocalizedString(AboutDescription.songDescription3, comment: "")
        let songDescription4 = NSLocalizedString(AboutDescription.songDescription4, comment: "")
        
        descriptionOne.text = songDescription
        descriptionTwo.text = songDescription2
        descriptionThree.text = songDescription3
        descriptionFour.text = songDescription4
    }

    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - YTPlayerViewDelegate
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        viewLoadingContainer.removeFromSuperview()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .playing {
            AVAudioSingleton.sharedInstance.pause()
        }
    }

}
