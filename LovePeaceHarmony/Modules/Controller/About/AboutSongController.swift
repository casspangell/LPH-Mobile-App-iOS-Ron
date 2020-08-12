//
//  AboutSongController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 13/12/17.
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
        
        let songTitle = NSMutableAttributedString(string: AboutDescription.songTitle)
        songTitle.addAttribute(.font, value: UIFont(name: "OpenSans-Semibold", size: 15)!, range: NSRange(location: 0, length: songTitle.length))
        songTitle.addAttribute(.font, value: UIFont(name: "OpenSans-SemiboldItalic", size: 15)!, range: NSRange(location: 47, length: 23))
        labelTitle.attributedText = songTitle
        
        let songDescription = NSMutableAttributedString(string: AboutDescription.songDescription)
        songDescription.addAttribute(.font, value: UIFont(name: "OpenSans", size: 15)!, range: NSRange(location: 0, length: songDescription.length))
        songDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 254, length: 23))
        songDescription.addAttribute(.font, value: UIFont(name: "OpenSans-Italic", size: 15)!, range: NSRange(location: 609, length: 23))
        labelDescription.attributedText = songDescription
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
            if let homeController = parent?.parent as? HomeTabController {
                homeController.stopChantingPlayback()
            }
        }
    }

}
