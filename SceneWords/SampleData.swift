import Foundation

enum SampleData {
    static let userProfile = UserProfile(name: "Mia", role: "Real-life English learner", level: .everyday, goal: .realLife, calibrationScore: 12)

    static let levelProbeWords: [LevelProbeWord] = [
        LevelProbeWord(text: "milk", category: .food, difficulty: 1),
        LevelProbeWord(text: "receipt", category: .dailyLife, difficulty: 2),
        LevelProbeWord(text: "surcharge", category: .food, difficulty: 4),
        LevelProbeWord(text: "redeem", category: .food, difficulty: 5),
        LevelProbeWord(text: "permit", category: .transport, difficulty: 4),
        LevelProbeWord(text: "tow-away", category: .transport, difficulty: 5),
        LevelProbeWord(text: "prescription", category: .medical, difficulty: 5),
        LevelProbeWord(text: "referral", category: .medical, difficulty: 6),
        LevelProbeWord(text: "cabinet food", category: .food, difficulty: 6),
        LevelProbeWord(text: "loading zone", category: .transport, difficulty: 7),
    ]

    static let scannedWords: [VocabularyWord] = [
        VocabularyWord(text: "surcharge", meaning: "额外收费", note: "Often appears on public holiday cafe menus.", sourceScene: "Cafe menu · Extras", contextLine: "Public holiday surcharge 15%", nextUse: "Explain an extra charge to a customer.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 3, reviewCount: 1, nextReview: "today"),
        VocabularyWord(text: "decaf", meaning: "低咖啡因咖啡", note: "A common customer request in cafes.", sourceScene: "Cafe menu · Extras", contextLine: "Decaf +0.6", nextUse: "Ask whether a customer wants decaf.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 4, reviewCount: 2, nextReview: "tomorrow"),
        VocabularyWord(text: "gluten-free", meaning: "无麸质", note: "Used for food options and allergy questions.", sourceScene: "Cafe menu · Food", contextLine: "Gluten-free options +1.0", nextUse: "Answer allergy and food-option questions.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 5, reviewCount: 1, nextReview: "today"),
        VocabularyWord(text: "redeem", meaning: "兑换", note: "Used with loyalty rewards and coupons.", sourceScene: "Cafe menu · Loyalty", contextLine: "Redeem loyalty points", nextUse: "Explain how customers use loyalty rewards.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today"),
        VocabularyWord(text: "cabinet food", meaning: "柜台陈列食品", note: "A very local cafe phrase in New Zealand.", sourceScene: "Cafe menu · Food", contextLine: "Cabinet food from 4.0", nextUse: "Talk about food displayed at the counter.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today"),
        VocabularyWord(text: "extra shot", meaning: "额外一份浓缩", note: "A phrase baristas hear often.", sourceScene: "Cafe menu · Extras", contextLine: "Extra shot +0.6", nextUse: "Confirm a coffee customization.", category: .work, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 4, reviewCount: 1, nextReview: "tomorrow"),
        VocabularyWord(text: "take away", meaning: "外带", note: "Common service phrase.", sourceScene: "Cafe menu · Extras", contextLine: "Dine in / take away", nextUse: "Ask a customer how they want their order.", category: .work, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 6, reviewCount: 2, nextReview: "in 3 days"),
        VocabularyWord(text: "loyalty points", meaning: "会员积分", note: "Useful when explaining rewards.", sourceScene: "Cafe menu · Loyalty", contextLine: "Redeem loyalty points", nextUse: "Explain a cafe membership system.", category: .food, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 4, reviewCount: 1, nextReview: "tomorrow"),
        VocabularyWord(text: "coffee", meaning: "咖啡", note: "Hidden because it is likely already known.", sourceScene: "Cafe menu · Coffee", contextLine: "Coffee", nextUse: "Basic cafe word.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 9, reviewCount: 4, nextReview: "light review"),
        VocabularyWord(text: "milk", meaning: "牛奶", note: "Hidden because it is likely already known.", sourceScene: "Cafe menu · Extras", contextLine: "Soy / oat / almond milk +0.5", nextUse: "Basic cafe ingredient.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 9, reviewCount: 5, nextReview: "light review"),
        VocabularyWord(text: "cup", meaning: "杯子", note: "Hidden because it is likely already known.", sourceScene: "Cafe menu · Extras", contextLine: "Keep cup discount -0.5", nextUse: "Basic service word.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 9, reviewCount: 4, nextReview: "light review"),
        VocabularyWord(text: "latte", meaning: "拿铁", note: "Hidden unless the user wants cafe basics.", sourceScene: "Cafe menu · Coffee", contextLine: "Latte 4.5", nextUse: "Coffee order word.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 8, reviewCount: 3, nextReview: "light review"),
    ]

    static let photos: [ScenePhoto] = [
        ScenePhoto(title: "Cafe menu", subtitle: "Today", suggestedScene: "Cafe menu", category: .food, wordCount: 24, symbol: "menucard.fill"),
        ScenePhoto(title: "Parking sign", subtitle: "2 days ago", suggestedScene: "Parking sign", category: .transport, wordCount: 12, symbol: "parkingsign.circle.fill"),
        ScenePhoto(title: "Clinic form", subtitle: "3 days ago", suggestedScene: "Clinic form", category: .medical, wordCount: 18, symbol: "doc.text.fill"),
        ScenePhoto(title: "Supermarket label", subtitle: "5 days ago", suggestedScene: "Product label", category: .dailyLife, wordCount: 9, symbol: "tag.fill"),
    ]

    static let packs: [SharedPack] = [
        SharedPack(title: "NZ Cafe Menu", owner: "Mia", location: "Auckland, NZ", savedCount: 842, words: ["surcharge", "decaf", "cabinet food", "loyalty points", "dine in"], isPublic: true),
        SharedPack(title: "Parking Signs", owner: "Lina", location: "Wellington, NZ", savedCount: 309, words: ["loading zone", "permit", "tow-away", "clearway"], isPublic: true),
        SharedPack(title: "Clinic Forms", owner: "Sam", location: "Christchurch, NZ", savedCount: 214, words: ["prescription", "referral", "dose", "symptom"], isPublic: false),
    ]
}
