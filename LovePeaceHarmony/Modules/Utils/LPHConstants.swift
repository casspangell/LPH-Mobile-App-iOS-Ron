//
//  LPHConstants.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Updated by Cass Pangell on 1/14/21.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import UIKit

// Controllers
enum ViewController {
    static let login = "LoginController"
    static let loginSocialNetwork = "LoginSocialNetworkController"
    static let loginEmail = "LoginEmailController"
    static let signUp = "SignUpController"
    static let homeTab = "HomeTabController"
    static let chantNow = "ChantNowController"
    static let chantReminder = "ChantReminderController"
    static let chantReminderAddEdit = "ChantReminderAddEditController"
    static let alarmRepeat = "AlarmRepeatController"
    static let chantMilestone = "ChantMilestoneController"
    static let newsRecent = "NewsRecentController"
    static let newsCategories = "NewsCategoriesController"
    static let newsCategoryDetails = "NewsCategoryDetailsController"
    static let newsFavourites = "NewsFavouritesController"
    static let newsDetails = "NewsDetailsController"
    static let newsfavouritesList = "NewsFavouritesListController"
    static let profile = "ProfileController"
    static let profilePicEdit = "ProfilePicEditController"
    static let profileLogin = "ProfileLoginController"
    static let aboutSong = "AboutSongController"
    static let aboutMovement = "AboutMovementController"
    static let aboutMasterSha = "AboutMasterShaController"
}

enum NavigationController {
    static let alarmRepeat = "NavigationControllerAlaramRepeat"
    static let alarmSelect = "NavigationControllerAlaramSelect"
}

// Reuse identifiers
enum ReuseIdentifier {
    static let chantReminder = "ChantReminderCell"
    static let chantReminderDummy = "ChantReminderDummyCell"
    static let newsRecent = "NewsRecentCell"
    static let newsCategory = "NewsCategoryCell"
    static let newsFavourite = "NewsFavouriteCell"
    static let newsCategoryDetails = "NewsCategoryDetailsCell"
}

// Http parameters
enum HttpParam {
    static let apiToken = "token"
    static let email = "email"
    static let fullName = "name"
    static let password = "password"
    static let profileUrl = "profile_pic_url"
    static let source = "source"
    static let inviteCode = "invitation_code"
    static let deviceToken = "device_token"
    static let deviceInfo = "device_info"
    static let pageLimit = "page_limit"
    static let pageOffset = "page_offset"
    static let categoryId = "category_id"
    static let image = "image"
    static let newsId = "news_id"
    static let isFavourite = "is_favorite"
    static let isRead = "is_read"
    static let date = "date"
    static let minutes = "minutes"
}

// Color codes
enum Color {
    static let purpleDark = UIColor(red: 102, green: 45, blue: 145)
    static let purpleLight = UIColor(red: 116, green: 110, blue: 175)
    static let theme = UIColor(red: 116, green: 109, blue: 175)
    static let tabDisabled = UIColor(red: 242, green: 242, blue: 242)
    static let orange = UIColor(red: 240, green: 171, blue: 35)
    static let disabled = UIColor(red: 186, green: 190, blue: 196)
}

// Core data model
enum CoreDataProperty {
    // Reminder
    static let reminderId = "reminderId"
    static let fullTime = "fullTime"
    static let hour = "hour"
    static let minute = "minute"
    static let amPm = "amPm"
    static let repeatDays = "repeatDays"
    static let isActivated = "isActivated"
    static let day = "day"
    static let id = "id"
    static let time = "time"
    
    // News
    static let newsId = "newsId"
    static let newsTitle = "newsTitle"
    static let newsDescription = "newsDescription"
    static let newsDetailsUrl = "newsDetailsUrl"
    static let newsImageUrl = "newsImageUrl"
    static let newsTimeStamp = "newsTimeStamp"
    static let newsDate = "newsDate"
    static let isFavorite = "isFavorite"
    static let isRead = "isRead"
    
    //Category
    static let categoryId = "categoryId"
    static let categoryTitle = "title"
    static let categoryImageUrl = "imageUrl"
    static let categoryPostCount = "newsCount"
    static let categoryUnreadCount = "unreadNewsCount"
    static let categoryFavouriteCount = "favoritesCount"
    
}

enum CoreDataEntity {
    static let reminder = "Reminder"
    static let localNotification = "LocalNotification"
    static let newsRecent = "NewsRecent"
    static let newsFavourite = "NewsFavourite"
    static let newsCategory = "NewsCategory"
    static let category = "Category"
}

// NSCoding
extension UserDefaults {
    enum Keys {
        static let loginVo = "UserDefaultsItemLoginVo"
        static let email = "UserDefaultsEmail"
        static let password = "UserDefaultsPassword"
        static let token = "UserDefaultsToken"
        static let fullName = "UserDefaultsUserFullName"
        static let profilePicUrl = "UserDefaultsProfilePicUrl"
        static let isLoggedIn = "UserDefaultsIsLoggedIn"
        static let loginType = "UserDefaultsLoginType"
        static let inviteCode = "UserDefaultsInviteCode"
        static let invitedCode = "UserDefaultsInvitedCode"
        
        static let isTutorialShown = "UserDefaultsItemIsTutorialShown"
        static let currentChantSong = "UserDefaultsCurrentChantSong"
        static let currentSeek = "UserDefaultsCurrentSeek"
        
        static let mandarinSoulEnglish = "UserDefaultsMandarinSoulEnglishOn"
        static let isInstrumentalOn = "UserDefaultsInstrumentalOn"
        static let isHindiOn = "UserDefaultsHindiOn"
        static let isHindi_SL_EnglishOn = "isHindi_SL_EnglishOn"
        static let isSpanishOn = "isSpanishOn"
        static let isMandarinEnglishGermanOn = "isMandarinEnglishGermanOn"
        static let isFrenchOn = "isFrenchOn"
        static let isfrenchAntilleanCreoleOn = "isfrenchAntilleanCreoleOn"
        static let isKawehiHawOn = "isKawehiHawOn"
        static let isShaEngOn = "isShaEngOn"
        static let isShaLulaEngKaHawOn = "isShaLulaEngHawOn"
        
        static let isRepeatEnabled = "UserDefaultsRepeatEnabled"
        static let isShuffleEnabled = "UserDefaultsShuffleEnabled"
        static let playerVolume = "UserDefaultsPlayerVolume"
        static let chantMinute = "UserDefaultsChantMinute"
        static let chantDay = "UserDefaultsChantDay"
        static let inviteCount = "UserDefaultsInviteCount"
        static let chantMinutePending = "UserDefaultsChantMinutePending"
        static let chantMinutePendingTemp = "UserDefaultsChantMinutePendingTemp"
        static let appInviteShareLink = "UserDefaultsShareLink"
        
    }
}

// Json Parsing
enum Json {
    static let success = "success"
    static let message = "message"
}

// Misc
let LOADING_INDICATOR = "loading_rainbow"
let TIME_AM = "AM"
let TIME_PM = "PM"
let PAGE_LIMIT = 10
let DEVICE_INFO = "iOS"
let SESSION_EXPIRY_MESSAGE = "Your session has expired. Please log in again"

// Date patterns
enum DatePattern {
    static let display = "dd MMM, yyyy"
    static let parse = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let sql = "yyyy-MM-dd HH:mm:ss"
    static let calendar = "yyyy-MM-dd"
    static let alarm = "HH:mm"
}

// Websites
let YOUTUBE_SONG_ID = "EjMsLYlPSFU"
let WEBSITE_URL = "https://lovepeaceharmony.org"
let DONATE_URL = "https://lovepeaceharmony.org/donate/"
let DYNAMIC_LINK_DOMAIN = "https://lovepeaceharmony.page.link/jdF1" //"jf627.app.goo.gl"
let LPH_IOS_BUNDLE_ID = "org.lovepeaceharmony.ios.app"
let LPH_ANDROID_BUNDLE_ID = "org.lovepeaceharmony.androidapp"
let APP_VERSION = "2.0"

// Chanting file paths
enum ChantFileName {
    static let mandarinSoulEnglish = "mandarin-soul_language-english"
    static let instrumental = "instrumental"
    static let hindi = "hindi"
    static let french_antillean_creole = "french_antillean_creole"
    static let french = "french"
    static let hindi_sl_english = "hindi_sl_english"
    static let mandarin_english_german = "mandarin_english_german"
    static let spanish = "spanish"
    static let kawehi_haw = "kawehi_haw"
    static let sha_eng = "sha_eng"
    static let sha_lula_eng_ka_haw = "sha_lula_eng_ka_haw"
}

// Messages
enum AlertMessage {
    static let noNetwork = "Please check your internet connection!"//k
    //static let login = "Please sign in to add this article to your favorites."
    static let unKnownException = "Something went wrong, please try again."//k
    
    //Login
    static let nameEmpty = "Please enter your name"//k
    static let emailEmpty = "Please enter your email address"//k
    static let invalidEmail = "Invalid email address"//k
    static let passwordEmpty = "Please enter your password"//k
    static let passwordLength = "Password needs to be at least 6 characters"//k
    static let confirmPasswordEmpty = "Please enter confirmation password"//k
    static let passwordDoNotMatch = "Passwords do not match"//k
    
    // Showcase view
    static let showcaseSecondary = "Tap anywhere to continue." //k
    
    //Chant
    static let timeToChant = "It's time to chant!!!" //k
    static let enableSong = "Please enable your song & play."//k
    static let shuffleOn = "Shuffle turned on"//k
    static let shuffleOff = "Shuffle turned off"//k
    static let repeatOn = "Repeat turned on"//k
    static let repeatOff = "Repeat turned off"//k
    static let noPreviousSong = "No previous song"//k
    static let noNextSong = "No next song"//k
}

// About text
enum AboutDescription {
    static let songTitle = "Join together with 1.5 billion people to chant Love, Peace and Harmony by 2030."
    
    static let songDescription = "When many people join hearts and souls together to chant and meditate, this automatically creates a powerful field. We become what we chant, so as we chant to create world love, peace and harmony, each of us is transforming the message we carry within." +
    
    "\n\nLove, Peace and Harmony, a song received by Dr. and Master Sha from the Divine, carries the high frequency and vibration of love, forgiveness, compassion and light. Your body naturally resonates with this elevated frequency, and responds by activating love, peace and harmony throughout your being." +
        
    "\n\nBy 2020, we hope to inspire 1.5 billion people to sing Love, Peace and Harmony for 15 minutes every day. Play and chant this song to create a world of love, peace and harmony." +
        
    "\n\nTogether, we’ll celebrate the power of the human spirit and its ability to transcend, transform and triumph to create miracles. Imagine a world where everyone holds the message of love, peace and harmony."
    
    static let movement = "Love Peace Harmony Foundation was founded in 2006 and formally registered in the United States as a nonprofit in 2008. The mission of Love Peace Harmony Foundation is to offer assistance and support to various local and global humanitarian efforts. We strive to initiate and support projects that create happy, healthy, and peaceful families and communities. On a philosophical level, the Foundation’s mission is to serve all humanity and to make others happier and healthier. The goal is to raise the consciousness of humanity by chanting the Divine Soul Song Love, Peace and Harmony to uplift the frequency and vibration of Mother Earth and to improve humanity’s health and happiness by teaching of self-healing techniques." +
        
    "\n\nSome of our numerous initiatives have included working with the Tarayana Foundation in Bhutan, a remote kingdom in the Himalayas. We are helping to support access to education, health care, and proper nutrition and creating a pilot project there that we hope will be replicated in many other areas of the world." +
        
    "\n\nIn Toronto, Canada, we have supported low-income families so they could send their children to the Harbourfront Centre summer camp to experience the many benefits of enjoying a variety of activities with their peers and engaging actively with the environment." +
    
    "\n\nWe have also contributed to the nonprofit WandAid to help families in earthquake damaged zones in Nepal. We are very honored to help support communities impacted by natural disasters, political crises, and other disadvantages." +
    
    "\n\nLove Peace Harmony Foundation has numerous additional ongoing projects and is actively expanding efforts worldwide to help people live happier and healthier lives." +
    
    "\n\nThe Divine Soul Song Love, Peace and Harmony has been credited with many deeply transformative experiences by the people who have experienced it, lowering crime rates, incidences of physical abuse, and improving the health for women in low income homes in Mumbai, as well as increasing children’s intelligence and school performance. Chanting Love, Peace and Harmony for children in the slums of Mumbai (Dharavi, Asia’s largest slum) also resulted in greater emotional balance, happiness and other emotional benefits."
    
    static let drSha = "Dr. and Master Zhi Gang Sha is a world-renowned healer, Tao Grandmaster, philanthropist, humanitarian, and creator of Tao Calligraphy. He is the founder of Soul Mind Body Medicine™ and an eleven-time New York Times bestselling author of 24 books. An M.D. in China and a doctor of traditional Chinese medicine in China and Canada, Master Sha is the founder of Tao Academy™ and Love Peace Harmony Foundation™, which is dedicated to helping families worldwide create happier and healthier lives." +
        
    "\n\nA grandmaster of many ancient disciplines, including tai chi, qigong, kung fu, feng shui, and the I Ching, Master Sha was named Qigong Master of the Year at the Fifth World Congress on Qigong. In 2006, he was honored with the prestigious Martin Luther King, Jr. Commemorative Commission Award for his humanitarian efforts, and in 2016 Master Sha received rare and prestigious appointments as Shu Fa Jia (National Chinese Calligrapher Master) and Yan Jiu Yuan (Honorable Researcher Professor), the highest titles a Chinese calligrapher can receive, by the State Ethnic of Academy of Painting in China." +
    
    "\n\nMaster Sha was named Honorary Member of the Club of Budapest Foundation, an organization dedicated to resolving the social, political, economic, and ecological challenges of the twenty-first century. Officially launching in 2015, Master Sha has been invited to become one of the Founding Signatories of the Fuji Declaration, whose mission is to create lasting peace on Earth. Master Sha is a member of Rotary E-Club of World Peace and is a founding signatory of the Conscious Business Declaration, which aims to define a new standard for business in the twenty-first century that will increase economic prosperity while healing the environment and improving humanity’s well-being. In 2016, Master Sha received a Commendation from Los Angeles County for his humanitarian efforts both locally and worldwide, and a Commendation from the Hawaii Senate as a selfless humanitarian who celebrates the power of the human spirit as he travels the world tirelessly to create a Love Peace Harmony World Family. In 2017, he received the International Tara Award from Ven. Mae Chee Sansanee Sthirasuta of Sathira-Dhammasathan, for being a person who acts like a Boddhisattva, doing good for society. He continues to deliver free webcasts, teleconferences, and events that attract viewers and listeners from around the world."
}

