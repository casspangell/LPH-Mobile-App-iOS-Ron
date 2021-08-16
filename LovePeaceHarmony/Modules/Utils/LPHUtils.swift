//
//  LPHUtils.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 08/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import SystemConfiguration
import UIKit
import CoreData
import MaterialShowcase
import Firebase
import AVFoundation


public class LPHUtils {
    
    public static func isConnectedToNetwork(showAlert: Bool, vc: UIViewController) -> Bool {
        var isConnected = true
        if(!checkNetworkConnection()) {
            if showAlert {
                showToast(message: "Please check your internet connection", height: Int(CGFloat(vc.view.frame.size.height - 100)), width: Int(CGFloat(vc.view.frame.width - 50)), view: vc.view)
            }
            isConnected = false
        }
        return isConnected
    }
    
    public static func checkNetworkConnection() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    static func getStoryboard(type: StoryboardType) -> UIStoryboard {
        var storyboard: UIStoryboard?
        if type == .login {
            storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        } else if type == .home {
            storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        }
        return storyboard!
    }
    
    public static func showToast(message: String, view: UIView) {
        showToast(message: message, height: Int(CGFloat(view.frame.size.height - 100)), width: Int(CGFloat(view.frame.width - 50)), view: view)
    }
    
    private static func showToast(message : String, height: Int, width: Int, view: UIView) {
        
        let toastLabel = UILabel(frame: CGRect(x: 25, y: height, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        toastLabel.text = message
        toastLabel.alpha = 0.8
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    public static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func getLoginVo() -> LoginVo {
        var loginVo: LoginVo?
        let userDefault = UserDefaults.standard
        let savedObject = userDefault.object(forKey: UserDefaults.Keys.loginVo)
        if savedObject != nil {
            if let savedLogin = NSKeyedUnarchiver.unarchiveObject(with: savedObject as! Data) as? LoginVo {
                loginVo = savedLogin
            } else {
                loginVo = LoginVo.getDefaultObject()
            }
        } else {
            loginVo = LoginVo.getDefaultObject()
        }
        
        return loginVo!
    }
    
    static func setLoginVo(loginVo: LoginVo) {
        let userDefault = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: loginVo)
        userDefault.set(encodedData, forKey: UserDefaults.Keys.loginVo)
        userDefault.synchronize()
    }
    
    static func showAlertSingleButton(title: String, message: String, vc: UIViewController) {
        var title = title
        if title.count == 0 {
            title = "Alert"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func getUserDefaultsString(key: String) -> String {
        var value: String?
        let userDefaults = UserDefaults.standard
        value = userDefaults.string(forKey: key)
        return value ?? ""
    }
    
    static func setUserDefaultsString(key: String, value: String) {
        let userDefaults =  UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    static func getUserDefaultsInt(key: String) -> Int {
        var value: Int?
        let userDefaults = UserDefaults.standard
        value = userDefaults.integer(forKey: key)
        return value!
    }
    
    static func setUserDefaultsInt(key: String, value: Int) {
        let userDefaults =  UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    static func getUserDefaultsFloat(key: String) -> Float {
        var value: Float?
        let userDefaults = UserDefaults.standard
        value = userDefaults.float(forKey: key)
        return value!
    }
    
    static func setUserDefaultsFloat(key: String, value: Float) {
        let userDefaults =  UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    static func getUserDefaultsBool(key: String) -> Bool {
        var value: Bool?
        let userDefaults = UserDefaults.standard
        value = userDefaults.bool(forKey: key)
        return value!
    }
    
    static func setUserDefaultsBool(key: String, value: Bool) {
        let userDefaults =  UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
//    static func getSecondsInString(seconds: Float) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = DatePattern.sql
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        
//        let secondsInString = String(seconds)
//        
//        return secondsInString
//    }
    
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DatePattern.parse
        let date = dateFormatter.string(from: Date())
        
        return date
    }
    
    static func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DatePattern.parse
        let date = dateFormatter.string(from: Date())
        let timeStamp = date.components(separatedBy: "T") //grabs date
        
        return timeStamp[0]
    }
    
//    static func getMonthCalendar() -> [String:String] {
//        let calendar = [
//            "1":"31",
//            "2":"28",
//            "3":"31",
//            "4":"30",
//            "5":"31",
//            "6":"30",
//            "7":"31",
//            "8":"31",
//            "9":"30",
//            "10":"31",
//            "11":"30",
//            "12":"31"
//        ]
//
//        return calendar
//    }
    
    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    static func createChantDate(theDate:String) -> ChantDate {
        let currentDayArr = theDate.components(separatedBy: "-")
        let formattedDate = ChantDate(day: Int(currentDayArr[2])!, month: Int(currentDayArr[1])!, year: Int(currentDayArr[0])!)
        
        return formattedDate
    }
    
    static func getCurrentChantingStreak() -> Int {
        return 1
    }
    
    static func getCurrentUserToken() -> String {
        var deviceToken = LPHUtils.getLoginVo().token
        return deviceToken
    }
    
    static func getCurrentUserID() -> String {
        var userId:String
        if Auth.auth().currentUser != nil {
          // User is signed in.
            userId = Auth.auth().currentUser!.uid
        } else {
          // No user is signed in.
          userId = ""
        }
        
        return userId
    }
    
    static func renderShowcaseView(title: String, view: UIView, delegate: MaterialShowcaseDelegate?, secondaryText: String = NSLocalizedString(AlertMessage.showcaseSecondary, comment: "") ) {
        let showcase = MaterialShowcase()
        showcase.targetHolderColor = Color.orange
        showcase.backgroundPromptColor = Color.purpleLight
        showcase.setTargetView(view: view) // always required to set targetView
        showcase.aniRippleAlpha = 1
        showcase.primaryText = title
        showcase.secondaryText = secondaryText
        showcase.delegate = delegate
        showcase.show(completion: nil)
    }

}

// MARK: - LPH application "Extensions"
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

// MARK: - AVAudioPlayer
class AVAudioSingleton {
    static let sharedInstance = AVAudioSingleton()
    private var player: AVAudioPlayer?

    func prepare() {
        player?.prepareToPlay()
    }
    
    func startNewSong(chantFileName: String) {

        guard let url = Bundle.main.url(forResource: chantFileName, withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.stop()
    }
    
    func isPlaying() -> Bool {
        if player != nil {
            return true
        } else {
            return false
        }
    }
    
    func getCurrentTime() -> Double {
        if player != nil {
            return player!.currentTime
        } else {
            return 0.0
        }
    }
    
}

@IBDesignable
class RoundedCornerView: UIView {
    
    // if cornerRadius variable is set/changed, change the corner radius of the UIView
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
}


extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension UIImage {
    //Changing image orientation
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}

// MARK: Enum
enum StoryboardType: Int {
    case login
    case home
}

enum ChantFile: Int {
    case mandarin_soul_english
    case instrumental
    case hindi
    case hindi_sl_english
    case spanish
    case mandarin_english_german
    case french
    case french_antillean_creole
    case kawehi_haw
    case sha_eng
    case sha_lula_eng_ka_haw
}

