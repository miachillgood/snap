import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case simplifiedChinese
    case japanese
    case korean
    case spanish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .spanish: "Español"
        }
    }

    var nativeTitle: String {
        switch self {
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .spanish: "Español"
        }
    }

    var shortTitle: String {
        switch self {
        case .english: "EN"
        case .simplifiedChinese: "简中"
        case .japanese: "日"
        case .korean: "한"
        case .spanish: "ES"
        }
    }

    func description(_ language: AppLanguage) -> String {
        switch self {
        case .english:
            language.text(en: "English", zh: "英语", ja: "英語", ko: "영어", es: "Inglés")
        case .simplifiedChinese:
            language.text(en: "Simplified Chinese", zh: "简体中文", ja: "簡体字中国語", ko: "중국어 간체", es: "Chino simplificado")
        case .japanese:
            language.text(en: "Japanese", zh: "日语", ja: "日本語", ko: "일본어", es: "Japonés")
        case .korean:
            language.text(en: "Korean", zh: "韩语", ja: "韓国語", ko: "한국어", es: "Coreano")
        case .spanish:
            language.text(en: "Spanish", zh: "西班牙语", ja: "スペイン語", ko: "스페인어", es: "Español")
        }
    }

    func text(en: String, zh: String, ja: String? = nil, ko: String? = nil, es: String? = nil) -> String {
        switch self {
        case .english: en
        case .simplifiedChinese: zh
        case .japanese: ja ?? en
        case .korean: ko ?? en
        case .spanish: es ?? en
        }
    }
}

extension WordCategory {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .food: language.text(en: "Food", zh: "饮食")
        case .transport: language.text(en: "Transport", zh: "交通")
        case .medical: language.text(en: "Medical", zh: "医疗")
        case .dailyLife: language.text(en: "Daily Life", zh: "日常生活")
        case .work: language.text(en: "Work", zh: "工作")
        }
    }
}

extension WordGroup {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .recommended: language.text(en: "Recommended", zh: "推荐学习")
        case .phrases: language.text(en: "Scene phrases", zh: "场景短语")
        case .hidden: language.text(en: "Hidden simple words", zh: "已隐藏的简单词")
        }
    }

    func subtitle(_ language: AppLanguage) -> String {
        switch self {
        case .recommended: language.text(en: "Worth learning from this photo", zh: "这张照片里值得学习的词")
        case .phrases: language.text(en: "Useful in this situation", zh: "这个场景里常会用到")
        case .hidden: language.text(en: "Already easy for you", zh: "对你来说可能已经很简单")
        }
    }
}

extension ReviewRating {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .forgot: language.text(en: "Forgot", zh: "忘了")
        case .unsure: language.text(en: "Unsure", zh: "不确定")
        case .remembered: language.text(en: "Remembered", zh: "记住了")
        case .easy: language.text(en: "Too easy", zh: "太简单")
        }
    }

    func interval(_ language: AppLanguage) -> String {
        switch self {
        case .forgot: language.text(en: "again today", zh: "今天再看一次")
        case .unsure: language.text(en: "tomorrow", zh: "明天")
        case .remembered: language.text(en: "in 3 days", zh: "3 天后")
        case .easy: language.text(en: "in 7 days", zh: "7 天后")
        }
    }

    func guidance(_ language: AppLanguage) -> String {
        switch self {
        case .forgot: language.text(en: "See it again after a short break.", zh: "休息一下后再遇见它。")
        case .unsure: language.text(en: "Bring it back tomorrow.", zh: "明天再巩固一次。")
        case .remembered: language.text(en: "Strengthen it in a few days.", zh: "过几天再加强记忆。")
        case .easy: language.text(en: "Move it to light review.", zh: "放进轻量复习。")
        }
    }
}

extension EnglishLevel {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .gettingStarted: language.text(en: "Getting Started", zh: "刚开始")
        case .everyday: language.text(en: "Everyday", zh: "日常可用")
        case .working: language.text(en: "Working", zh: "工作可用")
        case .confident: language.text(en: "Confident", zh: "比较自信")
        }
    }

    func shortTitle(_ language: AppLanguage) -> String {
        switch self {
        case .gettingStarted: language.text(en: "Starter", zh: "入门")
        case .everyday: language.text(en: "Everyday", zh: "日常")
        case .working: language.text(en: "Work-ready", zh: "工作")
        case .confident: language.text(en: "Confident", zh: "自信")
        }
    }
}

extension LearningGoal {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .realLife: language.text(en: "Real-life English", zh: "海外生活英语")
        case .cafeWork: language.text(en: "Cafe work", zh: "咖啡店工作")
        case .dailyLife: language.text(en: "Daily life", zh: "日常生活")
        case .medicalVisits: language.text(en: "Medical visits", zh: "看病就医")
        case .transport: language.text(en: "Transport", zh: "交通出行")
        }
    }
}

extension VocabularyWord {
    func sourceSceneText(_ language: AppLanguage) -> String {
        switch sourceScene {
        case "Cafe menu · Extras": language.text(en: "Cafe menu · Extras", zh: "咖啡店菜单 · 加项")
        case "Cafe menu · Food": language.text(en: "Cafe menu · Food", zh: "咖啡店菜单 · 食物")
        case "Cafe menu · Loyalty": language.text(en: "Cafe menu · Loyalty", zh: "咖啡店菜单 · 会员奖励")
        case "Cafe counter sign": language.text(en: "Cafe counter sign", zh: "咖啡店柜台标识")
        case "Cafe menu · Coffee": language.text(en: "Cafe menu · Coffee", zh: "咖啡店菜单 · 咖啡")
        case "Cafe counter": language.text(en: "Cafe counter", zh: "咖啡店柜台")
        case "Cafe shift note": language.text(en: "Cafe shift note", zh: "咖啡店班次记录")
        case "Parking sign": language.text(en: "Parking sign", zh: "停车标识")
        case "Clinic form": language.text(en: "Clinic form", zh: "诊所表格")
        case "Supermarket label": language.text(en: "Supermarket label", zh: "超市标签")
        default: sourceScene
        }
    }

    func noteText(_ language: AppLanguage) -> String {
        switch text {
        case "surcharge": language.text(en: note, zh: "在公共假期菜单上经常会出现。")
        case "decaf": language.text(en: note, zh: "咖啡店顾客很常见的要求。")
        case "gluten-free": language.text(en: note, zh: "常用于食物选择和过敏相关问题。")
        case "redeem": language.text(en: note, zh: "常和会员奖励、优惠券一起出现。")
        case "cabinet food": language.text(en: note, zh: "新西兰咖啡店里很本地化的说法。")
        case "extra shot": language.text(en: note, zh: "咖啡师经常会听到的加项。")
        case "take away": language.text(en: note, zh: "服务场景里很常用的说法。")
        case "loyalty points": language.text(en: note, zh: "解释会员奖励时很有用。")
        case "coffee", "milk", "cup": language.text(en: note, zh: "因为可能已经认识，所以先隐藏。")
        case "latte": language.text(en: note, zh: "除非用户想复习咖啡基础词，否则先隐藏。")
        default: note
        }
    }

    func nextUseText(_ language: AppLanguage) -> String {
        switch text {
        case "surcharge": language.text(en: nextUse, zh: "向顾客解释为什么有额外收费。")
        case "decaf": language.text(en: nextUse, zh: "询问顾客是否需要低咖啡因。")
        case "gluten-free": language.text(en: nextUse, zh: "回答过敏和食物选择相关问题。")
        case "redeem": language.text(en: nextUse, zh: "解释顾客如何使用会员奖励。")
        case "cabinet food": language.text(en: nextUse, zh: "介绍柜台里陈列的食物。")
        case "extra shot": language.text(en: nextUse, zh: "确认顾客的咖啡加项。")
        case "take away": language.text(en: nextUse, zh: "询问顾客堂食还是外带。")
        case "loyalty points": language.text(en: nextUse, zh: "解释咖啡店会员积分。")
        case "coffee": language.text(en: nextUse, zh: "咖啡店基础词。")
        case "milk": language.text(en: nextUse, zh: "咖啡店常见配料。")
        case "cup": language.text(en: nextUse, zh: "服务场景基础词。")
        case "latte": language.text(en: nextUse, zh: "点咖啡时常见的词。")
        default: nextUse
        }
    }

    func nextReviewText(_ language: AppLanguage) -> String {
        switch nextReview {
        case "today": language.text(en: "today", zh: "今天")
        case "tomorrow": language.text(en: "tomorrow", zh: "明天")
        case "in 3 days": language.text(en: "in 3 days", zh: "3 天后")
        case "in 7 days": language.text(en: "in 7 days", zh: "7 天后")
        case "light review": language.text(en: "light review", zh: "轻量复习")
        case "again today": language.text(en: "again today", zh: "今天再看一次")
        default: nextReview
        }
    }
}

extension ScenePhoto {
    func title(_ language: AppLanguage) -> String {
        switch title {
        case "Cafe menu": language.text(en: "Cafe menu", zh: "咖啡店菜单")
        case "Parking sign": language.text(en: "Parking sign", zh: "停车标识")
        case "Clinic form": language.text(en: "Clinic form", zh: "诊所表格")
        case "Supermarket label": language.text(en: "Supermarket label", zh: "超市标签")
        case "Cafe shift note": language.text(en: "Cafe shift note", zh: "咖啡店班次记录")
        case "Captured scene": language.text(en: "Captured scene", zh: "拍摄场景")
        case "Gallery scene": language.text(en: "Gallery scene", zh: "图库场景")
        default: title
        }
    }

    func subtitle(_ language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale(for: language)
        formatter.dateFormat = language == .simplifiedChinese ? "HH:mm" : "h:mm a"
        return formatter.string(from: captureDate)
    }

    func dayTitle(_ language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale(for: language)
        formatter.dateFormat = language == .simplifiedChinese ? "M月d日" : "MMM d"
        return formatter.string(from: captureDate)
    }

    private func locale(for language: AppLanguage) -> Locale {
        switch language {
        case .simplifiedChinese: Locale(identifier: "zh_Hans")
        case .japanese: Locale(identifier: "ja_JP")
        case .korean: Locale(identifier: "ko_KR")
        case .spanish: Locale(identifier: "es_ES")
        case .english: Locale(identifier: "en_US")
        }
    }
}
