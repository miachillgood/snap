import Foundation
import SwiftUI

enum SampleData {
    static let userProfile = UserProfile(name: "Mia", role: "Real-life English learner", level: .everyday, goal: .realLife, calibrationScore: 12)

    static let calibrationScenes: [CalibrationScene] = [
        CalibrationScene(
            id: "food-cafe",
            sceneNumber: "01",
            title: "FOOD / CAFE",
            subtitle: "Ordering, menu words, and cafe shift basics",
            category: .food,
            icon: "cup.and.saucer.fill",
            highlightColor: Color(red: 0.89, green: 0.686, blue: 0.22),
            backgroundColor: Color(red: 0.976, green: 0.847, blue: 0.651),
            imageName: "CafeOrderingFox",
            words: [
                LevelProbeWord(text: "appetizer", translation: "开胃菜", category: .food, difficulty: 4),
                LevelProbeWord(text: "main", translation: "主菜", category: .food, difficulty: 2),
                LevelProbeWord(text: "side", translation: "配菜", category: .food, difficulty: 3),
                LevelProbeWord(text: "combo", translation: "套餐", category: .food, difficulty: 4),
                LevelProbeWord(text: "portion", translation: "份量", category: .food, difficulty: 4),
                LevelProbeWord(text: "spicy", translation: "辣的", category: .food, difficulty: 2),
                LevelProbeWord(text: "mild", translation: "温和的", category: .food, difficulty: 3),
                LevelProbeWord(text: "crispy", translation: "酥脆的", category: .food, difficulty: 4),
                LevelProbeWord(text: "grilled", translation: "烤的", category: .food, difficulty: 4),
                LevelProbeWord(text: "fried", translation: "油炸的", category: .food, difficulty: 3),
                LevelProbeWord(text: "poached", translation: "水波/水煮", category: .food, difficulty: 5),
                LevelProbeWord(text: "scrambled", translation: "炒蛋式", category: .food, difficulty: 5),
                LevelProbeWord(text: "dressing", translation: "沙拉酱", category: .food, difficulty: 4),
                LevelProbeWord(text: "topping", translation: "加料", category: .food, difficulty: 4),
                LevelProbeWord(text: "refill", translation: "续杯/补充", category: .food, difficulty: 4),
                LevelProbeWord(text: "takeaway", translation: "外带", category: .food, difficulty: 3),
                LevelProbeWord(text: "dine-in", translation: "堂食", category: .food, difficulty: 3),
                LevelProbeWord(text: "surcharge", translation: "额外收费", category: .food, difficulty: 4),
                LevelProbeWord(text: "dairy-free", translation: "不含乳制品", category: .food, difficulty: 5),
                LevelProbeWord(text: "gluten-free", translation: "无麸质", category: .food, difficulty: 5)
            ]
        ),
        CalibrationScene(
            id: "transport-signs",
            sceneNumber: "02",
            title: "TRANSPORT / SIGNS",
            subtitle: "Buses, parking signs, stations, and street notices",
            category: .transport,
            icon: "tram.fill",
            highlightColor: Color(red: 0.08, green: 0.52, blue: 0.66),
            backgroundColor: Color(red: 0.788, green: 0.969, blue: 0.996),
            imageName: "TrafficScene",
            words: [
                LevelProbeWord(text: "platform", translation: "站台", category: .transport, difficulty: 3),
                LevelProbeWord(text: "stop", translation: "站点", category: .transport, difficulty: 2),
                LevelProbeWord(text: "route", translation: "路线", category: .transport, difficulty: 3),
                LevelProbeWord(text: "transfer", translation: "换乘", category: .transport, difficulty: 4),
                LevelProbeWord(text: "fare", translation: "票价", category: .transport, difficulty: 4),
                LevelProbeWord(text: "ticket", translation: "票", category: .transport, difficulty: 2),
                LevelProbeWord(text: "pass", translation: "通票/月票", category: .transport, difficulty: 3),
                LevelProbeWord(text: "timetable", translation: "时刻表", category: .transport, difficulty: 5),
                LevelProbeWord(text: "departure", translation: "出发", category: .transport, difficulty: 4),
                LevelProbeWord(text: "arrival", translation: "到达", category: .transport, difficulty: 4),
                LevelProbeWord(text: "delay", translation: "延误", category: .transport, difficulty: 3),
                LevelProbeWord(text: "cancelled", translation: "取消", category: .transport, difficulty: 4),
                LevelProbeWord(text: "boarding", translation: "登车/登机", category: .transport, difficulty: 4),
                LevelProbeWord(text: "gate", translation: "登机口", category: .transport, difficulty: 3),
                LevelProbeWord(text: "terminal", translation: "航站楼", category: .transport, difficulty: 4),
                LevelProbeWord(text: "luggage", translation: "行李", category: .transport, difficulty: 3),
                LevelProbeWord(text: "pedestrian", translation: "行人", category: .transport, difficulty: 5),
                LevelProbeWord(text: "crossing", translation: "人行横道", category: .transport, difficulty: 4),
                LevelProbeWord(text: "detour", translation: "绕路", category: .transport, difficulty: 5),
                LevelProbeWord(text: "tow-away", translation: "拖车移走", category: .transport, difficulty: 5)
            ]
        ),
        CalibrationScene(
            id: "medical-pharmacy",
            sceneNumber: "03",
            title: "MEDICAL / PHARMACY",
            subtitle: "Clinic forms, pharmacy labels, symptoms, and appointments",
            category: .medical,
            icon: "cross.case.fill",
            highlightColor: Color(red: 0.78, green: 0.23, blue: 0.48),
            backgroundColor: Color(red: 0.98, green: 0.86, blue: 0.9),
            imageName: nil,
            words: [
                LevelProbeWord(text: "symptom", translation: "症状", category: .medical, difficulty: 3),
                LevelProbeWord(text: "fever", translation: "发烧", category: .medical, difficulty: 2),
                LevelProbeWord(text: "cough", translation: "咳嗽", category: .medical, difficulty: 2),
                LevelProbeWord(text: "rash", translation: "皮疹", category: .medical, difficulty: 4),
                LevelProbeWord(text: "swelling", translation: "肿胀", category: .medical, difficulty: 4),
                LevelProbeWord(text: "nausea", translation: "恶心", category: .medical, difficulty: 5),
                LevelProbeWord(text: "dizzy", translation: "头晕", category: .medical, difficulty: 3),
                LevelProbeWord(text: "allergy", translation: "过敏", category: .medical, difficulty: 3),
                LevelProbeWord(text: "prescription", translation: "处方", category: .medical, difficulty: 5),
                LevelProbeWord(text: "dosage", translation: "剂量", category: .medical, difficulty: 5),
                LevelProbeWord(text: "tablet", translation: "药片", category: .medical, difficulty: 3),
                LevelProbeWord(text: "ointment", translation: "药膏", category: .medical, difficulty: 5),
                LevelProbeWord(text: "antibiotic", translation: "抗生素", category: .medical, difficulty: 5),
                LevelProbeWord(text: "painkiller", translation: "止痛药", category: .medical, difficulty: 4),
                LevelProbeWord(text: "side effect", translation: "副作用", category: .medical, difficulty: 4),
                LevelProbeWord(text: "referral", translation: "转诊", category: .medical, difficulty: 6),
                LevelProbeWord(text: "appointment", translation: "预约", category: .medical, difficulty: 3),
                LevelProbeWord(text: "walk-in", translation: "无需预约", category: .medical, difficulty: 4),
                LevelProbeWord(text: "urgent care", translation: "急诊/急救门诊", category: .medical, difficulty: 5),
                LevelProbeWord(text: "pharmacist", translation: "药剂师", category: .medical, difficulty: 4)
            ]
        ),
        CalibrationScene(
            id: "daily-life",
            sceneNumber: "04",
            title: "DAILY LIFE",
            subtitle: "Supermarket labels, returns, errands, and notices",
            category: .dailyLife,
            icon: "basket.fill",
            highlightColor: Color(red: 0.78, green: 0.52, blue: 0.08),
            backgroundColor: Color(red: 0.98, green: 0.9, blue: 0.7),
            imageName: nil,
            words: [
                LevelProbeWord(text: "receipt", translation: "收据", category: .dailyLife, difficulty: 2),
                LevelProbeWord(text: "refund", translation: "退款", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "exchange", translation: "换货", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "clearance", translation: "清仓", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "discount", translation: "折扣", category: .dailyLife, difficulty: 2),
                LevelProbeWord(text: "aisle", translation: "过道/货架通道", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "checkout", translation: "收银台", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "self-service", translation: "自助服务", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "expiry", translation: "有效期", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "perishable", translation: "易腐坏的", category: .dailyLife, difficulty: 5),
                LevelProbeWord(text: "household", translation: "家用的", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "laundry", translation: "洗衣", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "detergent", translation: "洗衣液/清洁剂", category: .dailyLife, difficulty: 5),
                LevelProbeWord(text: "parcel", translation: "包裹", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "pickup", translation: "取货/接送", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "drop-off", translation: "投递/放下", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "queue", translation: "排队", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "counter", translation: "柜台", category: .dailyLife, difficulty: 3),
                LevelProbeWord(text: "out of stock", translation: "缺货", category: .dailyLife, difficulty: 4),
                LevelProbeWord(text: "fragile", translation: "易碎", category: .dailyLife, difficulty: 4)
            ]
        ),
        CalibrationScene(
            id: "work-housing",
            sceneNumber: "05",
            title: "WORK / HOUSING",
            subtitle: "Shifts, forms, rent, inspections, and everyday admin",
            category: .work,
            icon: "briefcase.fill",
            highlightColor: Color(red: 0.78, green: 0.32, blue: 0.2),
            backgroundColor: Color(red: 0.98, green: 0.82, blue: 0.72),
            imageName: nil,
            words: [
                LevelProbeWord(text: "shift", translation: "班次", category: .work, difficulty: 3),
                LevelProbeWord(text: "roster", translation: "排班表", category: .work, difficulty: 5),
                LevelProbeWord(text: "timesheet", translation: "工时表", category: .work, difficulty: 5),
                LevelProbeWord(text: "pay slip", translation: "工资单", category: .work, difficulty: 4),
                LevelProbeWord(text: "break", translation: "休息", category: .work, difficulty: 2),
                LevelProbeWord(text: "uniform", translation: "制服", category: .work, difficulty: 3),
                LevelProbeWord(text: "training", translation: "培训", category: .work, difficulty: 3),
                LevelProbeWord(text: "manager", translation: "经理", category: .work, difficulty: 2),
                LevelProbeWord(text: "availability", translation: "可上班时间", category: .work, difficulty: 5),
                LevelProbeWord(text: "cover", translation: "代班", category: .work, difficulty: 5),
                LevelProbeWord(text: "lease", translation: "租约", category: .work, difficulty: 5),
                LevelProbeWord(text: "rent", translation: "租金", category: .work, difficulty: 3),
                LevelProbeWord(text: "bond", translation: "押金", category: .work, difficulty: 5),
                LevelProbeWord(text: "landlord", translation: "房东", category: .work, difficulty: 4),
                LevelProbeWord(text: "tenant", translation: "租客", category: .work, difficulty: 4),
                LevelProbeWord(text: "inspection", translation: "检查/验房", category: .work, difficulty: 5),
                LevelProbeWord(text: "maintenance", translation: "维修", category: .work, difficulty: 5),
                LevelProbeWord(text: "utilities", translation: "水电网等费用", category: .work, difficulty: 5),
                LevelProbeWord(text: "notice period", translation: "通知期", category: .work, difficulty: 6),
                LevelProbeWord(text: "reference", translation: "推荐人/证明", category: .work, difficulty: 4)
            ]
        )
    ]

    static let levelProbeWords: [LevelProbeWord] = calibrationScenes.flatMap(\.words)

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
