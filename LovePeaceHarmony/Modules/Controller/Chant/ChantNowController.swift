//
//  ChantNowController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Updated by Cass Pangell on 1/1/21.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import EventKit
import XLPagerTabStrip
import AVFoundation
import Firebase
import MaterialShowcase

class ChantNowController: BaseViewController, IndicatorInfoProvider, AVAudioPlayerDelegate {
    
    // MARK: - Variables
    var audioPlayer: AVAudioPlayer?
    var sliderTimer: Timer?
    var totalChantDuration: Float?
    var startTime: String?
    var songListStatus = [ChantFile: Bool]()
    var songListOriginal = [ChantFile]()
    var songListShuffled = [ChantFile]()
    var currentSong: ChantFile?
    var currentSongString: String?
    var isAudioPlaying = false
    var isShuffleEnabled = false
    var isRepeatEnabled = false
    var chantMilestoneCounter:Float = 0
    var chantTitle = ["Mandarin, Soul Language and English", "Instrumental", "Hindi", "Hindi, Soul Language, English", "Spanish", "Mandarin, English, German", "French", "French Antillean Creole", "Kawehi Haw", "Master Sha English", "Master Sha Lula English Ka Haw"]
    
    // MARK: - IBProperties
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var labelSeekTime: UILabel!
    @IBOutlet weak var labelTotalDuration: UILabel!
    @IBOutlet weak var sliderMusicSeek: UISlider!
    @IBOutlet weak var sliderVolume: UISlider!
    
    @IBOutlet weak var switchMandarinSoulEnglish: UISwitch!
    @IBOutlet weak var switchInstrumental: UISwitch!
    @IBOutlet weak var switchHindi: UISwitch!
    @IBOutlet weak var switchHindiSLEng: UISwitch!
    @IBOutlet weak var switchSpanish: UISwitch!
    @IBOutlet weak var switchMandarinEngGerman: UISwitch!
    @IBOutlet weak var switchFrench: UISwitch!
    @IBOutlet weak var switchAntilleanCreole: UISwitch!
    @IBOutlet weak var switchKawehiHaw: UISwitch!
    @IBOutlet weak var switchShaLulaEngKaHaw: UISwitch!
    @IBOutlet weak var switchShaEng: UISwitch!
    
    @IBOutlet weak var mandarinSoulEnglishLabel: UILabel!
    @IBOutlet weak var instrumentalLabel: UILabel!
    @IBOutlet weak var hindiLabel: UILabel!
    @IBOutlet weak var hindiSoulLanguageEnglishLabel: UILabel!
    @IBOutlet weak var spanishLabel: UILabel!
    @IBOutlet weak var mandarinEnglishGermanLabel: UILabel!
    @IBOutlet weak var frenchLabel: UILabel!
    @IBOutlet weak var frenchCreoleLabel: UILabel!
    
    @IBOutlet weak var LPHInManyLanguagesBarLable: UILabel!
    @IBOutlet weak var expressionsOfLPHBarLabel: UILabel!
    
    @IBOutlet weak var alohaLabel: UILabel!
    @IBOutlet weak var lulaliHawaiian: UILabel!
    @IBOutlet weak var lphEnglish: UILabel!
    
    @IBOutlet weak var buttonShuffle: UIButton!
    @IBOutlet weak var buttonRepeat: UIButton!
    @IBOutlet weak var labelSongName: UILabel!
    
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Strings for localization
        mandarinSoulEnglishLabel.text = NSLocalizedString("Mandarin, Soul Language, English", comment: "")
        instrumentalLabel.text = NSLocalizedString("Instrumental", comment: "")
        hindiLabel.text = NSLocalizedString("Hindi", comment: "")
        hindiSoulLanguageEnglishLabel.text = NSLocalizedString("Hindi, Soul Language, English", comment: "")
        spanishLabel.text = NSLocalizedString("Spanish", comment: "")
        mandarinEnglishGermanLabel.text = NSLocalizedString("Mandarin, English, German", comment: "")
        frenchLabel.text = NSLocalizedString("French", comment: "")
        frenchCreoleLabel.text = NSLocalizedString("French & Creole", comment: "")
        LPHInManyLanguagesBarLable.text = NSLocalizedString("Love Peace Harmony in Many Languages", comment: "")
        expressionsOfLPHBarLabel.text = NSLocalizedString("Expressions of Love Peace Harmony", comment: "")
        alohaLabel.text = NSLocalizedString("Aloha, Maluhia, Lokahi (LPH in Hawaiian)", comment: "")
        lulaliHawaiian.text = NSLocalizedString("Lu La Li Version, English and Hawaiian", comment: "")
        lphEnglish.text = NSLocalizedString("Love Peace Harmony in English", comment: "")
        
        sliderMusicSeek.setThumbImage(#imageLiteral(resourceName: "ic_slider_thumb"), for: .normal)
        sliderMusicSeek.setThumbImage(#imageLiteral(resourceName: "ic_slider_thumb"), for: .selected)
        sliderMusicSeek.setThumbImage(#imageLiteral(resourceName: "ic_slider_thumb"), for: .focused)
        sliderMusicSeek.setThumbImage(#imageLiteral(resourceName: "ic_slider_thumb"), for: .highlighted)
        restoreChantSettings()
        initiateMusicPlayer()
        if isShuffleEnabled {
            generateShuffleList()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        //        UIApplication.shared.beginReceivingRemoteControlEvents()
        //        var mpic = MPNow
        //        mpic.nowPlayingInfo = [
        //            MPMediaItemPropertyTitle:"This Is a Test",
        //            MPMediaItemPropertyArtist:"Matt Neuburg"
        //        ]
    }
    
    @objc func didBecomeActive() {
        if audioPlayer != nil && !(audioPlayer?.isPlaying)! {
            buttonPlayPause.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
        }
    }
    
    func renderShowcaseView() {
        LPHUtils.renderShowcaseView(title: NSLocalizedString("Turn on / off chants", comment: ""), view: switchMandarinSoulEnglish, delegate: nil, secondaryText: NSLocalizedString("Use the switches to customize your chanting playlist.", comment: ""))
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isTutorialShown, value: true)
    }
    // MARK: - XLPagerTabStrip
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Title")
    }
    
    // MARK: - Actions
    private func restoreChantSettings() {
        let isMandarinOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish)
        let isInstrumentalOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn)
        let isHindiOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isHindiOn)
        let isHindi_SL_EnglishOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isHindi_SL_EnglishOn)
        let isSpanishOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isSpanishOn)
        let isMandarinEnglishGermanOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isMandarinEnglishGermanOn)
        let isFrenchOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isFrenchOn)
        let isfrenchAntilleanCreoleOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isfrenchAntilleanCreoleOn)
        let isKawehiHawOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isKawehiHawOn)
        let isShaEnglishOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isShaEngOn)
        let isShaLulaEngKaHawOn = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isShaLulaEngKaHawOn)
        
        isShuffleEnabled = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isShuffleEnabled)
        if isShuffleEnabled {
            buttonShuffle.tintColor = Color.orange
        } else {
            buttonShuffle.tintColor = Color.disabled
        }
        isRepeatEnabled = LPHUtils.getUserDefaultsBool(key: UserDefaults.Keys.isRepeatEnabled)
        if isRepeatEnabled {
            buttonRepeat.tintColor = Color.orange
        } else {
            buttonRepeat.tintColor = Color.disabled
        }
        songListStatus[.mandarin_soul_english] = isMandarinOn
        songListStatus[.instrumental] = isInstrumentalOn
        songListStatus[.hindi] = isHindiOn
        songListStatus[.hindi_sl_english] = isHindi_SL_EnglishOn
        songListStatus[.spanish] = isSpanishOn
        songListStatus[.mandarin_english_german] = isMandarinEnglishGermanOn
        songListStatus[.french] = isFrenchOn
        songListStatus[.french_antillean_creole] = isfrenchAntilleanCreoleOn
        songListStatus[.kawehi_haw] = isKawehiHawOn
        songListStatus[.sha_eng] = isShaEnglishOn
        songListStatus[.sha_lula_eng_ka_haw] = isShaLulaEngKaHawOn
        
        switchMandarinSoulEnglish.isOn = isMandarinOn
        switchInstrumental.isOn = isInstrumentalOn
        switchHindi.isOn = isHindiOn
        switchHindiSLEng.isOn =  isHindi_SL_EnglishOn
        switchSpanish.isOn = isSpanishOn
        switchMandarinEngGerman.isOn = isMandarinEnglishGermanOn
        switchFrench.isOn = isFrenchOn
        switchAntilleanCreole.isOn = isfrenchAntilleanCreoleOn
        switchKawehiHaw.isOn = isKawehiHawOn
        switchShaEng.isOn = isShaEnglishOn
        switchShaLulaEngKaHaw.isOn = isShaLulaEngKaHawOn
        
        if totalChantDuration != nil {
            let currentTime = TimeInterval(LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.currentSeek))
            audioPlayer?.currentTime = currentTime
            let minutes = String(format: "%02d", Int(currentTime / 60))
            let seconds = String(format: "%02d", Int(currentTime.truncatingRemainder(dividingBy: 60)))
            labelSeekTime.text = String("\(minutes).\(seconds)")
            let temp: Float = (Float(currentTime) / totalChantDuration!) / 60
            sliderMusicSeek.setValue(Float(temp), animated: true)
        }
        
        if songListStatus[.mandarin_soul_english]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 0)
        } else if songListStatus[.instrumental]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 1)
        } else if songListStatus[.hindi]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 2)
        } else if songListStatus[.hindi_sl_english]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 3)
        } else if songListStatus[.spanish]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 4)
        } else if songListStatus[.mandarin_english_german]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 5)
        } else if songListStatus[.french]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 6)
        } else if songListStatus[.french_antillean_creole]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 7)
        } else if songListStatus[.kawehi_haw]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 8)
        } else if songListStatus[.sha_eng]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 9)
        } else if songListStatus[.sha_lula_eng_ka_haw]! {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: 10)
        } else {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: -1)
        }
        
        songListOriginal.append(.mandarin_soul_english)
        songListOriginal.append(.instrumental)
        songListOriginal.append(.hindi)
        songListOriginal.append(.hindi_sl_english)
        songListOriginal.append(.spanish)
        songListOriginal.append(.mandarin_english_german)
        songListOriginal.append(.french)
        songListOriginal.append(.french_antillean_creole)
        songListOriginal.append(.kawehi_haw)
        songListOriginal.append(.sha_eng)
        songListOriginal.append(.sha_lula_eng_ka_haw)
        
    }
    
    private func generateShuffleList() {
        songListShuffled.removeAll()
        songListShuffled.append(currentSong!)
        var shuffledTempArray = [ChantFile]()
        for song in songListOriginal {
            if song != currentSong {
                shuffledTempArray.append(song)
            }
        }
        shuffledTempArray.shuffle()
        songListShuffled.append(contentsOf: shuffledTempArray)
        print("---shuffled song list---")
        for song in songListShuffled {
            print(song)
        }
    }
    
    private func initiateMusicPlayer() {
        let currentSongIndex = LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.currentChantSong)
        print("current song index: \(currentSongIndex)")
        if currentSongIndex != -1 {
            currentSong = ChantFile(rawValue: currentSongIndex)
            renderSongName()
            labelSeekTime.text = "00:00"
            var songName: String?
            
            switch currentSong {
            case .mandarin_soul_english:
                songName = ChantFileName.mandarinSoulEnglish
            case .instrumental:
                songName = ChantFileName.instrumental
            case .hindi:
                songName = ChantFileName.hindi
            case .hindi_sl_english:
                songName = ChantFileName.hindi_sl_english
            case .spanish:
                songName = ChantFileName.spanish
            case .mandarin_english_german:
                songName = ChantFileName.mandarin_english_german
            case .french:
                songName = ChantFileName.french
            case .french_antillean_creole:
                songName = ChantFileName.french_antillean_creole
            case .kawehi_haw:
                songName = ChantFileName.kawehi_haw
            case .sha_eng:
                songName = ChantFileName.sha_eng
            case .sha_lula_eng_ka_haw:
                songName = ChantFileName.sha_lula_eng_ka_haw

            default:
                songName = ChantFileName.mandarinSoulEnglish
            }

            
            
            guard let url = Bundle.main.url(forResource: songName!, withExtension: "mp3") else { return }
            currentSongString = songName!
            
            AVAudioSingleton.sharedInstance.prepare()
            
            let asset = AVURLAsset(url: url)
            
            totalChantDuration = Float((CMTimeGetSeconds(asset.duration)) / 60)
            let totalMinute = Int(totalChantDuration!)
            let decimalMinute: Float = (totalChantDuration! - Float(totalMinute)) * 100
            let originalMinute: Int = Int(decimalMinute * 0.6)
            labelTotalDuration.text = "\(totalMinute).\(originalMinute)"
            
            // Settings volume to previous value
            var volume = LPHUtils.getUserDefaultsFloat(key: UserDefaults.Keys.playerVolume)
            if volume == 0 {
                volume = 30
            }
            audioPlayer?.volume = volume
            sliderVolume.setValue(volume / 100, animated: false)
            
            // Setting to previous seek position
            let currentTime = TimeInterval(LPHUtils.getUserDefaultsInt(key: UserDefaults.Keys.currentSeek))
//            audioPlayer?.currentTime = currentTime
            
            //grabs the current timestamp for more accurate chanting time
            startTime = String(currentTime)
            updateSlider()
        } else {
            labelTotalDuration.text = "-:-"
        }
    }
    
    @objc func updateSlider() {
        
//        if audioPlayer != nil {
            let currentTime = AVAudioSingleton.sharedInstance.getCurrentTime()
        
            chantMilestoneCounter += 1
            let milestoneTempMinutes = chantMilestoneCounter.truncatingRemainder(dividingBy: 600)
            if milestoneTempMinutes == 0 {
                let pendingMilestonesTemp = Int(chantMilestoneCounter / 600)
                LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.chantMinutePendingTemp, value: pendingMilestonesTemp)
            }
            
            // let currentTime = (audioPlayer?.currentTime)!
            
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentSeek, value: Int(currentTime))
            let minutes = String(format: "%02d", Int(currentTime / 60))
            let seconds = String(format: "%02d", Int(currentTime.truncatingRemainder(dividingBy: 60)))
            labelSeekTime.text = String("\(minutes).\(seconds)")
            var temp: Float = (Float(currentTime) / totalChantDuration!) / 60
            if temp != 1 && temp > 1 {
                temp = 0
                audioPlayerDidFinishPlaying(audioPlayer!, successfully: true)
                togglePlayPauseButton()
            }
            sliderMusicSeek.setValue(Float(temp), animated: true)
//        }
    }
    
    private func togglePlayPauseButton() {
        
        if (!isAudioPlaying) {
            AVAudioSingleton.sharedInstance.play(chantFileName: currentSongString!)
            startTime = labelSeekTime.text //reset start time
            sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ChantNowController.updateSlider), userInfo: nil, repeats: true)
            buttonPlayPause.setImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
            isAudioPlaying = true
        } else {
            AVAudioSingleton.sharedInstance.pause()
            sliderTimer?.invalidate()
            buttonPlayPause.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            processChantingMilestone()
            startTime = labelSeekTime.text //reset start time
            isAudioPlaying = false
        }
    }
    
    private func renderSongName() {
        if currentSong != nil {
            labelSongName.text = "\(NSLocalizedString("Now playing: ", comment: "")) \(chantTitle[(currentSong?.rawValue)!])"
        } else {
            labelSongName.text = " "
        }
    }
    
    func stopChantingIfPlaying() {
        if audioPlayer != nil  && (audioPlayer?.isPlaying)! {
            audioPlayer?.stop()
            togglePlayPauseButton()
        }
    }
    
    private func processChantingMilestone() {
        //Grab timestamp label and convert to total seconds
        //Calculate the start timestamp and the current timestamp
        let currentTime = labelSeekTime.text!.components(separatedBy: ".")
        
        //Is the playtime greater than zero? Double check please.
        if currentTime.contains(".") {
            let sTime = startTime!.components(separatedBy: ".") //I dont know why these values are flipped in the array
            let currentTimeTotalSecs = (Int(currentTime[0])!*60) + Int(currentTime[1])!
            let startTimeTotalSecs = (Int(sTime[0])!*60) + Int(sTime[1])!
            let totalSeconds = (currentTimeTotalSecs - startTimeTotalSecs)
            
            fireMilestoneSavingApi(seconds: totalSeconds)
        } else {
            fireMilestoneSavingApi(seconds: 0)
        }
    }
    
    private func forceStopPlaying(chantSong : ChantFile) {
        processChantingMilestone()
        if currentSong == chantSong {
            if (audioPlayer != nil && (audioPlayer?.isPlaying)!) {
                audioPlayer?.stop()
            }
            labelSeekTime.text = "0.0"
            labelTotalDuration.text = "-:-"
            sliderMusicSeek.setValue(0, animated: true)
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentSeek, value: 0)
            if currentSong != nil {
                currentSong = getNextSong()
                print(currentSong)
                if currentSong != nil {
                    LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: (currentSong?.rawValue)!)
                } else {
                    LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: -1)
                    showToast(message: NSLocalizedString(AlertMessage.enableSong, comment: "") )
                }
            }
            renderSongName()
            initiateMusicPlayer()
            togglePlayPauseButton()
        }
        
        
        var currentSongIndex = -1
        if currentSong == nil {
            if songListStatus[.mandarin_soul_english]! {
                currentSong = .mandarin_soul_english
            } else if songListStatus[.instrumental]! {
                currentSong = .instrumental
            } else if songListStatus[.hindi]! {
                currentSong = .hindi
            } else if songListStatus[.hindi_sl_english]! {
                currentSong = .hindi_sl_english
            } else if songListStatus[.spanish]! {
                currentSong = .spanish
            } else if songListStatus[.mandarin_english_german]! {
                currentSong = .mandarin_english_german
            } else if songListStatus[.french]! {
                currentSong = .french
            } else if songListStatus[.french_antillean_creole]! {
                currentSong = .french_antillean_creole
            } else if songListStatus[.kawehi_haw]! {
                currentSong = .kawehi_haw
            } else if songListStatus[.sha_eng]! {
                currentSong = .sha_eng
            } else if songListStatus[.sha_lula_eng_ka_haw]! {
                currentSong = .sha_lula_eng_ka_haw
            }
            renderSongName()
        }

        if currentSong != nil {
            currentSongIndex = (currentSong?.rawValue)!
            labelSeekTime.text = "0.0"
            sliderMusicSeek.setValue(0, animated: true)
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentSeek, value: 0)
        } else {
            labelTotalDuration.text = "-:-"
        }
        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: currentSongIndex)
    }
    
    private func getNextSong() -> ChantFile? {
        processChantingMilestone()
        var nextSong: ChantFile?
        if currentSong != nil {
            let currentSongIndex = currentSong?.rawValue
            if isShuffleEnabled {
                var shuffledSongIndex: Int?
                for (index, song) in songListShuffled.enumerated() {
                    if song == currentSong {
                        shuffledSongIndex = index
                        break
                    }
                }
                if shuffledSongIndex != nil {
                    for (index, song) in songListShuffled.enumerated() {
                        if shuffledSongIndex! < index {
                            if songListStatus[song]! {
                                nextSong = song
                                break
                            }
                        }
                    }
                }
                
                if nextSong == nil && isRepeatEnabled {
                    for song in songListShuffled {
                        if songListStatus[song]! {
                            nextSong = song
                            break
                        }
                    }
                }
                
            } else if isRepeatEnabled {
                for (index, song) in songListOriginal.enumerated() {
                    print(song)
                    if currentSongIndex! < index {
                        if songListStatus[song]! {
                            nextSong = song
                            break
                        }
                    }
                }
                
                if nextSong == nil {
                    for song in songListOriginal {
                        print(song)
                        if songListStatus[song]! {
                            nextSong = song
                            break
                        }
                    }
                }
            } else {
                for (index, song) in songListOriginal.enumerated() {
                    print(song)
                    if currentSongIndex! < index {
                        if songListStatus[song]! {
                            nextSong = song
                            break
                        }
                    }
                }
            }
        }
        return nextSong
    }
    
    private func getPreviousSong() -> ChantFile? {
        processChantingMilestone()
        var previousSong: ChantFile?
        let songListSize = songListStatus.count
        if currentSong != nil {
            let currentSongIndex = currentSong?.rawValue
            if isShuffleEnabled {
                var shuffledSongIndex: Int?
                for (index, song) in songListShuffled.enumerated() {
                    if song == currentSong {
                        shuffledSongIndex = index
                        break
                    }
                }
                
                if shuffledSongIndex != nil {
                    for index in stride(from: shuffledSongIndex! - 1, through: 0, by: -1) {
                        if songListStatus[songListOriginal[index]]! {
                            previousSong = songListShuffled[index]
                            break
                        }
                    }
                    
                    if previousSong == nil && isRepeatEnabled {
                        for index in stride(from: songListSize - 1, through: 0, by: -1) {
                            if songListStatus[songListOriginal[index]]! {
                                previousSong = songListShuffled[index]
                                break
                            }
                        }
                    }
                }
                
            } else if isRepeatEnabled {
                for index in stride(from: currentSongIndex! - 1, through: 0, by: -1) {
                    if songListStatus[songListOriginal[index]]! {
                        previousSong = songListOriginal[index]
                        break
                    }
                }
                
                if previousSong == nil {
                    for index in stride(from: songListSize - 1, through: 0, by: -1) {
                        if songListStatus[songListOriginal[index]]! {
                            previousSong = songListOriginal[index]
                            break
                        }
                    }
                }
            } else {
                for index in stride(from: currentSongIndex! - 1, through: 0, by: -1) {
                    if songListStatus[songListOriginal[index]]! {
                        previousSong = songListOriginal[index]
                        break
                    }
                }
            }
        }
        return previousSong
    }
    
    
    private func checkAndTurnShuffleRepeatOff() -> Bool {
        var turnAllOff = true
        for song in songListStatus {
            if song.value {
                turnAllOff = false
                break
            }
        }
        if turnAllOff {
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isShuffleEnabled, value: false)
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isRepeatEnabled, value: false)
            isShuffleEnabled = false
            isRepeatEnabled = false
            buttonRepeat.tintColor = Color.disabled
            buttonShuffle.tintColor = Color.disabled
            audioPlayer = nil
            sliderTimer?.invalidate()
            togglePlayPauseButton()
        }
        return turnAllOff
    }
    
    private func resetAudioPlayer() {
        if (audioPlayer != nil && (audioPlayer?.isPlaying)!) {
            audioPlayer?.stop()
        }
        labelSeekTime.text = "0.0"
        labelTotalDuration.text = "-:-"
        sliderMusicSeek.setValue(0, animated: true)
        LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentSeek, value: 0)
    }
    
    // MARK: - AVAudioDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        sliderTimer?.invalidate()
        if currentSong != nil {
            currentSong = getNextSong()
            print(currentSong)
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentSeek, value: 0)
            if currentSong != nil {
                LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: (currentSong?.rawValue)!)
                initiateMusicPlayer()
                audioPlayer?.play()
                renderSongName()
                sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ChantNowController.updateSlider), userInfo: nil, repeats: true)
            }
            togglePlayPauseButton()
        }
    }
    
    //MARK: - IBActions
    @IBAction func onTapPlay(_ sender: UIButton) {
        
        animateMusicButton(sender, 0) {}
        
        togglePlayPauseButton()
        
//        if currentSong != nil {
//            animateMusicButton(sender, 0) {}
//
//            togglePlayPauseButton()
//
//            if (isAudioPlaying == false) {
//                AVAudioSingleton.sharedInstance.play(chantFileName: currentSongString!)
//                isAudioPlaying = true
//            } else {
//                AVAudioSingleton.sharedInstance.pause()
//                isAudioPlaying = false
//            }
//
//        } else {
//            showToast(message: NSLocalizedString(AlertMessage.enableSong, comment: ""))
//        }
    }
    
    @IBAction func onTapPreviousSong(_ sender: UIButton) {
        let previousSong = getPreviousSong()
        if (previousSong != nil && previousSong != currentSong) {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: (previousSong?.rawValue)!)
            resetAudioPlayer()
            initiateMusicPlayer()
            audioPlayer?.play()
            togglePlayPauseButton()
        } else {
            showToast(message: NSLocalizedString(AlertMessage.noPreviousSong, comment: ""))
        }
    }
    
    @IBAction func onTapNextSong(_ sender: UIButton) {
        let nextSong = getNextSong()
        if (nextSong != nil && nextSong != currentSong) {
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: (nextSong?.rawValue)!)
            resetAudioPlayer()
            initiateMusicPlayer()
            audioPlayer?.play()
            togglePlayPauseButton()
        } else {
            showToast(message: NSLocalizedString(AlertMessage.noNextSong, comment: ""))
        }
    }
    
    @IBAction func onTapShuffle(_ sender: UIButton) {
        if !checkAndTurnShuffleRepeatOff() {
            isShuffleEnabled = !isShuffleEnabled
            if isShuffleEnabled {
                showToast(message: NSLocalizedString(AlertMessage.shuffleOn, comment: ""))
                generateShuffleList()
            } else {
                showToast(message: NSLocalizedString(AlertMessage.shuffleOff, comment: ""))
            }
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isShuffleEnabled, value: isShuffleEnabled)
            if isShuffleEnabled {
                sender.tintColor = Color.orange
            } else {
                sender.tintColor = Color.disabled
            }
        } else {
            showToast(message: NSLocalizedString(AlertMessage.enableSong, comment: ""))
        }
        
    }
    
    @IBAction func onTapReplay(_ sender: UIButton) {
        if !checkAndTurnShuffleRepeatOff() {
            isRepeatEnabled = !isRepeatEnabled
            if isRepeatEnabled {
                showToast(message: NSLocalizedString(AlertMessage.repeatOn, comment: "") )
            } else {
                showToast(message: NSLocalizedString(AlertMessage.repeatOff, comment: ""))
            }
            LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isRepeatEnabled, value: isRepeatEnabled)
            if isRepeatEnabled {
                sender.tintColor = Color.orange
            } else {
                sender.tintColor = Color.disabled
            }
        } else {
            showToast(message: NSLocalizedString(AlertMessage.enableSong, comment: ""))
        }
    }
    
    @IBAction func onSliderVolumeChanged(_ sender: UISlider) {
        let volume: Float = sender.value
        audioPlayer?.volume = volume
        LPHUtils.setUserDefaultsFloat(key: UserDefaults.Keys.playerVolume, value: volume)
    }
    
    @IBAction func onSliderSeekValueChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value * 60 * totalChantDuration!)
        updateSlider()
    }
    
    @IBAction func onTapSwitchMandarinSoulEnglish(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.mandarinSoulEnglish, value: sender.isOn)
        songListStatus[.mandarin_soul_english] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .mandarin_soul_english)
    }
    
    @IBAction func onTapSwitchInstrumental(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isInstrumentalOn, value: sender.isOn)
        songListStatus[.instrumental] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .instrumental)
    }
    
    @IBAction func onTapSwitchHindi(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindiOn, value: sender.isOn)
        songListStatus[.hindi] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .hindi)
    }
    
    @IBAction func onTapSwitchHindiSLEnglish(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isHindi_SL_EnglishOn, value: sender.isOn)
        songListStatus[.hindi_sl_english] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .hindi_sl_english)
    }
    
    @IBAction func onTapSpanish(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isSpanishOn, value: sender.isOn)
        songListStatus[.spanish] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .spanish)
    }
    
    @IBAction func onTapMandarinEngGerman(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isMandarinEnglishGermanOn, value: sender.isOn)
        songListStatus[.mandarin_english_german] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .mandarin_english_german)
    }
    
    @IBAction func onTapFrench(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isFrenchOn, value: sender.isOn)
        songListStatus[.french] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .french)
    }
    
    @IBAction func onTapAntilleanCreole(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isfrenchAntilleanCreoleOn, value: sender.isOn)
        songListStatus[.french_antillean_creole] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .french_antillean_creole)
    }

    @IBAction func onTapKawehiHaw(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isKawehiHawOn, value: sender.isOn)
        songListStatus[.kawehi_haw] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .kawehi_haw)
    }
    
    @IBAction func onTapShaLulaEngKaHaw(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isShaLulaEngKaHawOn, value: sender.isOn)
        songListStatus[.sha_lula_eng_ka_haw] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .sha_lula_eng_ka_haw)
    }

    @IBAction func onTapShaEng(_ sender: UISwitch) {
        LPHUtils.setUserDefaultsBool(key: UserDefaults.Keys.isShaEngOn, value: sender.isOn)
        songListStatus[.sha_eng] = sender.isOn
        checkAndTurnShuffleRepeatOff()
        forceStopPlaying(chantSong: .sha_eng)
    }
    
// MARK: OnTap Gestures
    
    @IBAction func onTapHindiGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .hindi)
    }
    
    @IBAction func onTapInstrumentalGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .instrumental)
    }
    
    @IBAction func onTapMandarinSLEngGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .mandarin_soul_english)
    }
    
    @IBAction func onTapHindiSLEngGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .hindi_sl_english)
    }
    
    @IBAction func onTapSpanishGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .spanish)
    }
    
    @IBAction func onTapMandarinEngGerGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .mandarin_english_german)
    }
    
    @IBAction func onTapFrenchGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .french)
    }
    
    @IBAction func onTapFrenchCreoleGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .french_antillean_creole)
    }
    
    @IBAction func onTapHawaiianGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .kawehi_haw)
    }
    
    @IBAction func onTapSLEngHawaiianGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .sha_lula_eng_ka_haw)
    }
    
    @IBAction func onTapEnglishGesture(_ sender: UITapGestureRecognizer) {
        startSong(chantFile: .sha_eng)
    }
    

    private func startSong(chantFile: ChantFile) {
        if songListStatus[chantFile]! {
            
//            if audioPlayer != nil && (audioPlayer?.isPlaying)! {
//                audioPlayer?.stop()
//            }
            
            if AVAudioSingleton.sharedInstance.isPlaying() {
                AVAudioSingleton.sharedInstance.pause()
                isAudioPlaying = false
            }
            
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentSeek, value: 0)
            LPHUtils.setUserDefaultsInt(key: UserDefaults.Keys.currentChantSong, value: chantFile.rawValue)
            initiateMusicPlayer()
            
            var songName: String?
            
            switch chantFile {
            case .mandarin_soul_english:
                songName = ChantFileName.mandarinSoulEnglish
            case .instrumental:
                songName = ChantFileName.instrumental
            case .hindi:
                songName = ChantFileName.hindi
            case .hindi_sl_english:
                songName = ChantFileName.hindi_sl_english
            case .spanish:
                songName = ChantFileName.spanish
            case .mandarin_english_german:
                songName = ChantFileName.mandarin_english_german
            case .french:
                songName = ChantFileName.french
            case .french_antillean_creole:
                songName = ChantFileName.french_antillean_creole
            case .kawehi_haw:
                songName = ChantFileName.kawehi_haw
            case .sha_eng:
                songName = ChantFileName.sha_eng
            case .sha_lula_eng_ka_haw:
                songName = ChantFileName.sha_lula_eng_ka_haw

            default:
                songName = ChantFileName.mandarinSoulEnglish
            }
            
            AVAudioSingleton.sharedInstance.play(chantFileName: songName!)
             
            togglePlayPauseButton()
            
        } else {
            showToast(message: NSLocalizedString(AlertMessage.enableSong, comment: ""))
        }
    }
    
    // MARK: - Api
    private func fireMilestoneSavingApi(seconds: Int) {
        let currentDate = LPHUtils.getCurrentDate()
        let chantDate = String(currentDate)
        let userId = LPHUtils.getCurrentUserID()
        print("USER \(userId)")
        
       APIUtilities.updateMilestone(date: chantDate, seconds: seconds, userID: userId) { (lphResponse) in }
       APIUtilities.updateChantingStreak(date: chantDate, userID: userId) { (lphResponse) in }

    }
    
    func animateMusicButton(_ view: UIView, _ duration: Double, completionListener: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: (TimeInterval(0)), usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)},completion: { [weak self] finished in
                            self?.animateOutMusicButton(view, duration, completionListener)
        })
    }
    
    func animateOutMusicButton(_ view: UIView, _ duration: Double, _ completionListener: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: (TimeInterval(0)), usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1, y: 1)},completion: { finished in
                            completionListener()
                            
        })
    }
    
}
