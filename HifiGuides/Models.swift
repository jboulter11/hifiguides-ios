import Foundation

struct SheetData {
    var headphones: [Headphone]
}

// MARK: Headphones

struct Headphone: Identifiable, Equatable, Codable {
    var id: Int {
        name.hash
    }
    
    var name: String
    var price: Int
    var url: String?
    var reviewUrl: String?
    var imageUrl: String?
    var ampRequired: Bool
    var backType: String
    var frequencyResponseType: String
}

struct HeadphoneSearchParameters {
    var priceRange: ClosedRange<Int>
    
}

// MARK: IEMs

struct InEarMonitor: Identifiable, Equatable, Codable {
    var id: Int {
        name.hash
    }
    
    var name: String
    var price: Int
    var url: String?
    var imageUrl: String?
    var frequencyResponseType: String
}

struct InEarMonitorSearchParameters {
    var priceRange: ClosedRange<Int>
}

// MARK: Speakers

struct Speaker: Identifiable, Equatable, Codable {
    var id: Int {
        name.hash
    }
    
    var name: String
    var price: Int
    var url: String?
    var imageUrl: String?
    var selfPowered: Bool
}

struct SpeakerSearchParameters {
    var priceRange: ClosedRange<Int>
    
}

// MARK: Subwoofers

struct Subwoofer: Identifiable, Equatable, Codable {
    var id: Int {
        name.hash
    }
    
    var name: String
    var price: Int
    var url: String?
    var imageUrl: String?
    var style: String
}

struct SubwooferSearchParameters {
    var priceRange: ClosedRange<Int>
    
}

// MARK: Source Components

struct HeadphoneSource: Identifiable, Equatable, Codable {
    var id: Int {
        name.hash
    }
    
    var name: String
    var price: Int
    var url: String?
    var imageUrl: String?
    var formFactor: String
    var unitType: String
    var topology: String
    var balanced: Bool
}

struct HeadphoneSourceSearchParameters {
    var priceRange: ClosedRange<Int>
    
}

// MARK: Product

enum ProductCategory: String, CaseIterable {
    case Headphones
    case InEars = "In-Ears"
    case Speakers
    case Subwoofers
    case HeadphoneSources = "Headphone sources"
}

struct Product: Identifiable, Equatable {
    var id: Int {
        name.hash
    }
    
    var name: String
    var price: Int
    var url: String?
    var imageUrl: String?
    
    init(headphone: Headphone) {
        self.name = headphone.name
        self.price = headphone.price
        self.url = headphone.url
        self.imageUrl = headphone.imageUrl
    }
    
    init(inEarMonitor: InEarMonitor) {
        self.name = inEarMonitor.name
        self.price = inEarMonitor.price
        self.url = inEarMonitor.url
        self.imageUrl = inEarMonitor.imageUrl
    }
    
    init(speaker: Speaker) {
        self.name = speaker.name
        self.price = speaker.price
        self.url = speaker.url
        self.imageUrl = speaker.imageUrl
    }
    
    init(subwoofer: Subwoofer) {
        self.name = subwoofer.name
        self.price = subwoofer.price
        self.url = subwoofer.url
        self.imageUrl = subwoofer.imageUrl
    }
    
    init(headphoneSource: HeadphoneSource) {
        self.name = headphoneSource.name
        self.price = headphoneSource.price
        self.url = headphoneSource.url
        self.imageUrl = headphoneSource.imageUrl
    }
}
