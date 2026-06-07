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

    private static let cafePhotoID = UUID()
    private static let workPhotoID = UUID()
    private static let parkingPhotoID = UUID()
    private static let clinicPhotoID = UUID()
    private static let supermarketPhotoID = UUID()

    static let scannedWords: [VocabularyWord] = [
        VocabularyWord(text: "surcharge", meaning: "额外收费", note: "Often appears on public holiday cafe menus.", sourceScene: "Cafe menu · Extras", contextLine: "Public holiday surcharge 15%", nextUse: "Explain an extra charge to a customer.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 3, reviewCount: 1, nextReview: "today", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "decaf", meaning: "低咖啡因咖啡", note: "A common customer request in cafes.", sourceScene: "Cafe menu · Extras", contextLine: "Decaf +0.6", nextUse: "Ask whether a customer wants decaf.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 4, reviewCount: 2, nextReview: "tomorrow", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "gluten-free", meaning: "无麸质", note: "Used for food options and allergy questions.", sourceScene: "Cafe menu · Food", contextLine: "Gluten-free options +1.0", nextUse: "Answer allergy and food-option questions.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 5, reviewCount: 1, nextReview: "today", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "redeem", meaning: "兑换", note: "Used with loyalty rewards and coupons.", sourceScene: "Cafe menu · Loyalty", contextLine: "Redeem loyalty points", nextUse: "Explain how customers use loyalty rewards.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "cabinet food", meaning: "柜台陈列食品", note: "A very local cafe phrase in New Zealand.", sourceScene: "Cafe menu · Food", contextLine: "Cabinet food from 4.0", nextUse: "Talk about food displayed at the counter.", category: .food, group: .recommended, isSelected: true, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "loyalty points", meaning: "会员积分", note: "Useful when explaining rewards.", sourceScene: "Cafe menu · Loyalty", contextLine: "Redeem loyalty points", nextUse: "Explain a cafe membership system.", category: .food, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 4, reviewCount: 1, nextReview: "tomorrow", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "extra shot", meaning: "额外一份浓缩", note: "A phrase baristas hear often.", sourceScene: "Cafe shift note", contextLine: "Customer asked for an extra shot", nextUse: "Confirm a coffee customization.", category: .work, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 4, reviewCount: 1, nextReview: "tomorrow", sourcePhotoID: workPhotoID, encounteredAt: daysAgo(0).addingTimeInterval(-1800)),
        VocabularyWord(text: "take away", meaning: "外带", note: "Common service phrase.", sourceScene: "Cafe shift note", contextLine: "Dine in or take away?", nextUse: "Ask a customer how they want their order.", category: .work, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 6, reviewCount: 2, nextReview: "in 3 days", sourcePhotoID: workPhotoID, encounteredAt: daysAgo(0).addingTimeInterval(-1800)),
        VocabularyWord(text: "rush hour", meaning: "高峰时段", note: "Useful when talking about busy shifts.", sourceScene: "Cafe shift note", contextLine: "Rush hour starts around 8:30", nextUse: "Talk about a busy work period.", category: .work, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 3, reviewCount: 0, nextReview: "today", sourcePhotoID: workPhotoID, encounteredAt: daysAgo(0).addingTimeInterval(-1800)),
        VocabularyWord(text: "loading zone", meaning: "装卸区", note: "Common on street parking signs.", sourceScene: "Parking sign", contextLine: "Loading zone 8am-6pm", nextUse: "Understand where cars can stop briefly.", category: .transport, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 3, reviewCount: 1, nextReview: "today", sourcePhotoID: parkingPhotoID, encounteredAt: daysAgo(2)),
        VocabularyWord(text: "permit", meaning: "许可证", note: "Often appears on parking and access signs.", sourceScene: "Parking sign", contextLine: "Permit holders only", nextUse: "Check whether you are allowed to park.", category: .transport, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 4, reviewCount: 1, nextReview: "tomorrow", sourcePhotoID: parkingPhotoID, encounteredAt: daysAgo(2)),
        VocabularyWord(text: "tow-away", meaning: "拖车移走", note: "A warning on restricted parking signs.", sourceScene: "Parking sign", contextLine: "Tow-away area", nextUse: "Avoid parking where the car may be removed.", category: .transport, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today", sourcePhotoID: parkingPhotoID, encounteredAt: daysAgo(2)),
        VocabularyWord(text: "prescription", meaning: "处方", note: "Common in clinic and pharmacy visits.", sourceScene: "Clinic form", contextLine: "Current prescription medicines", nextUse: "Talk to a doctor or pharmacist.", category: .medical, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 3, reviewCount: 1, nextReview: "today", sourcePhotoID: clinicPhotoID, encounteredAt: daysAgo(2).addingTimeInterval(-3600)),
        VocabularyWord(text: "referral", meaning: "转诊", note: "Used when one doctor sends you to a specialist.", sourceScene: "Clinic form", contextLine: "Do you need a referral?", nextUse: "Ask about seeing a specialist.", category: .medical, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today", sourcePhotoID: clinicPhotoID, encounteredAt: daysAgo(2).addingTimeInterval(-3600)),
        VocabularyWord(text: "side effect", meaning: "副作用", note: "Important when reading medicine information.", sourceScene: "Clinic form", contextLine: "Report any side effect", nextUse: "Describe a medicine reaction.", category: .medical, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 4, reviewCount: 1, nextReview: "tomorrow", sourcePhotoID: clinicPhotoID, encounteredAt: daysAgo(2).addingTimeInterval(-3600)),
        VocabularyWord(text: "clearance", meaning: "清仓", note: "Often appears on supermarket labels.", sourceScene: "Supermarket label", contextLine: "Clearance price", nextUse: "Spot discounted items.", category: .dailyLife, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 3, reviewCount: 0, nextReview: "today", sourcePhotoID: supermarketPhotoID, encounteredAt: daysAgo(4)),
        VocabularyWord(text: "perishable", meaning: "易腐坏的", note: "Used for food that expires quickly.", sourceScene: "Supermarket label", contextLine: "Keep perishable items chilled", nextUse: "Understand food storage labels.", category: .dailyLife, group: .recommended, isSelected: false, isKnown: false, memoryStrength: 2, reviewCount: 0, nextReview: "today", sourcePhotoID: supermarketPhotoID, encounteredAt: daysAgo(4)),
        VocabularyWord(text: "receipt", meaning: "收据", note: "Useful for returns and proof of purchase.", sourceScene: "Supermarket label", contextLine: "Keep your receipt", nextUse: "Ask about returns or refunds.", category: .dailyLife, group: .phrases, isSelected: false, isKnown: false, memoryStrength: 5, reviewCount: 1, nextReview: "in 3 days", sourcePhotoID: supermarketPhotoID, encounteredAt: daysAgo(4)),
        VocabularyWord(text: "coffee", meaning: "咖啡", note: "Hidden because it is likely already known.", sourceScene: "Cafe menu · Coffee", contextLine: "Coffee", nextUse: "Basic cafe word.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 9, reviewCount: 4, nextReview: "light review", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "milk", meaning: "牛奶", note: "Hidden because it is likely already known.", sourceScene: "Cafe menu · Extras", contextLine: "Soy / oat / almond milk +0.5", nextUse: "Basic cafe ingredient.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 9, reviewCount: 5, nextReview: "light review", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "cup", meaning: "杯子", note: "Hidden because it is likely already known.", sourceScene: "Cafe menu · Extras", contextLine: "Keep cup discount -0.5", nextUse: "Basic service word.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 9, reviewCount: 4, nextReview: "light review", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
        VocabularyWord(text: "latte", meaning: "拿铁", note: "Hidden unless the user wants cafe basics.", sourceScene: "Cafe menu · Coffee", contextLine: "Latte 4.5", nextUse: "Coffee order word.", category: .food, group: .hidden, isSelected: false, isKnown: true, memoryStrength: 8, reviewCount: 3, nextReview: "light review", sourcePhotoID: cafePhotoID, encounteredAt: daysAgo(0)),
    ]

    static let photos: [ScenePhoto] = [
        ScenePhoto(id: cafePhotoID, title: "Cafe menu", suggestedScene: "Cafe menu", category: .food, wordCount: 24, symbol: "menucard.fill", captureDate: daysAgo(0)),
        ScenePhoto(id: workPhotoID, title: "Cafe shift note", suggestedScene: "Cafe shift", category: .work, wordCount: 8, symbol: "briefcase.fill", captureDate: daysAgo(0).addingTimeInterval(-1800)),
        ScenePhoto(id: parkingPhotoID, title: "Parking sign", suggestedScene: "Parking sign", category: .transport, wordCount: 12, symbol: "parkingsign.circle.fill", captureDate: daysAgo(2)),
        ScenePhoto(id: clinicPhotoID, title: "Clinic form", suggestedScene: "Clinic form", category: .medical, wordCount: 18, symbol: "doc.text.fill", captureDate: daysAgo(2).addingTimeInterval(-3600)),
        ScenePhoto(id: supermarketPhotoID, title: "Supermarket label", suggestedScene: "Product label", category: .dailyLife, wordCount: 9, symbol: "tag.fill", captureDate: daysAgo(4)),
    ]

    static let packs: [SharedPack] = [
        SharedPack(
            title: "NZ Cafe Menu Vocabulary",
            description: "For ordering or working in Auckland cafes, with menu words like surcharge, decaf, and cabinet food.",
            owner: "Mia",
            ownerAvatarInitial: "M",
            creatorId: "mia",
            location: "Auckland, NZ",
            savedCount: 842,
            words: ["surcharge", "decaf", "cabinet food", "loyalty points", "dine in", "gluten-free", "redeem"],
            category: .food,
            tags: ["New Zealand", "cafe menu", "barista", "everyday", "real photo"],
            sourceScenes: ["Cafe menu", "Cafe shift note"],
            visibility: .publicPack,
            shareSlug: "nz-cafe-menu-vocabulary"
        ),
        SharedPack(
            title: "Parking Signs",
            description: "Street parking words for Wellington signs, including loading zone, permit, tow-away, and clearway.",
            owner: "Lina",
            ownerAvatarInitial: "L",
            creatorId: "lina",
            location: "Wellington, NZ",
            savedCount: 309,
            words: ["loading zone", "permit", "tow-away", "clearway"],
            category: .transport,
            tags: ["New Zealand", "parking", "transport", "street signs"],
            sourceScenes: ["Parking sign"],
            visibility: .publicPack,
            shareSlug: "parking-signs-wellington"
        ),
        SharedPack(
            title: "Clinic Forms",
            description: "Health visit vocabulary for reading forms and explaining symptoms at a clinic.",
            owner: "Sam",
            ownerAvatarInitial: "S",
            creatorId: "sam",
            location: "Christchurch, NZ",
            savedCount: 214,
            words: ["prescription", "referral", "dose", "symptom", "side effect"],
            category: .medical,
            tags: ["clinic", "health", "forms", "unlisted"],
            sourceScenes: ["Clinic form"],
            visibility: .unlisted,
            shareSlug: "clinic-forms-basics"
        ),
        SharedPack(
            title: "Supermarket Label Draft",
            description: "",
            owner: "Mia",
            ownerAvatarInitial: "M",
            creatorId: "mia",
            location: "Auckland, NZ",
            savedCount: 0,
            words: ["clearance", "perishable", "receipt"],
            category: .dailyLife,
            tags: ["supermarket", "daily life", "draft"],
            sourceScenes: ["Supermarket label"],
            visibility: .privatePack,
            shareSlug: "supermarket-label-draft"
        ),
    ]

    static func reviewEvents(for words: [VocabularyWord]) -> [ReviewEvent] {
        words
            .filter { $0.group != .hidden }
            .prefix(11)
            .enumerated()
            .map { index, word in
                ReviewEvent(
                    wordID: word.id,
                    reviewedAt: daysAgo(min(index / 2, 5)).addingTimeInterval(Double(index % 2) * 1800),
                    outcome: index % 3 == 0 ? .needsAnotherLook : .recognized
                )
            }
    }

    private static func daysAgo(_ count: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -count, to: Date()) ?? Date()
    }
}
