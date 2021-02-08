import FileProvider
import SQLite
import RxSwift
import Combine

protocol TableHelper {
    associatedtype ObjectType: Codable
    associatedtype SearchParametersType
    
    var table: Table { get }
    
    func buildTableQuery() -> String
    func updateQuery(object: ObjectType) -> Update
    func insertQuery(object: ObjectType) -> Insert
    func searchQuery(with searchParameters: SearchParametersType) -> Table
}

fileprivate struct HeadphonesTableHelper: TableHelper {
    typealias ObjectType = Headphone
    typealias SearchParametersType = HeadphoneSearchParameters
    
    let table = Table("headphones")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let price = Expression<Int>("price")
    private let url = Expression<String?>("url")
    private let reviewUrl = Expression<String?>("reviewUrl")
    private let imageUrl = Expression<String?>("imageUrl")
    private let ampRequired = Expression<Bool>("ampRequired")
    private let backType = Expression<String>("backType")
    private let frequencyResponseType = Expression<String>("frequencyResponseType")
    
    init() { }
    
    func buildTableQuery() -> String {
        table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(price)
            t.column(url)
            t.column(reviewUrl)
            t.column(imageUrl)
            t.column(ampRequired)
            t.column(backType)
            t.column(frequencyResponseType)
        }
    }
    
    func updateQuery(object: ObjectType) -> Update {
        table.filter(id == object.id)
            .update(
                id <- object.id,
                name <- object.name,
                price <- object.price,
                url <- object.url,
                reviewUrl <- object.reviewUrl,
                imageUrl <- object.imageUrl,
                ampRequired <- object.ampRequired,
                backType <- object.backType,
                frequencyResponseType <- object.frequencyResponseType
            )
    }
    
    func insertQuery(object: ObjectType) -> Insert {
        table.insert(
            id <- object.id,
            name <- object.name,
            price <- object.price,
            url <- object.url,
            reviewUrl <- object.reviewUrl,
            imageUrl <- object.imageUrl,
            ampRequired <- object.ampRequired,
            backType <- object.backType,
            frequencyResponseType <- object.frequencyResponseType
        )
    }
    
    func searchQuery(with searchParameters: SearchParametersType) -> Table {
        table.filter(
            searchParameters.priceRange.contains(price)
        ).order(name.asc)
    }
}

fileprivate struct InEarMonitorsTableHelper: TableHelper {
    typealias ObjectType = InEarMonitor
    typealias SearchParametersType = InEarMonitorSearchParameters
    
    let table = Table("inears")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let price = Expression<Int>("price")
    private let url = Expression<String?>("url")
    private let imageUrl = Expression<String?>("imageUrl")
    private let frequencyResponseType = Expression<String>("frequencyResponseType")
    
    init() { }
    
    func buildTableQuery() -> String {
        table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(price)
            t.column(url)
            t.column(imageUrl)
            t.column(frequencyResponseType)
        }
    }
    
    func updateQuery(object: ObjectType) -> Update {
        table.filter(id == object.id)
            .update(
                id <- object.id,
                name <- object.name,
                price <- object.price,
                url <- object.url,
                imageUrl <- object.imageUrl,
                frequencyResponseType <- object.frequencyResponseType
            )
    }
    
    func insertQuery(object: ObjectType) -> Insert {
        table.insert(
            id <- object.id,
            name <- object.name,
            price <- object.price,
            url <- object.url,
            imageUrl <- object.imageUrl,
            frequencyResponseType <- object.frequencyResponseType
        )
    }
    
    func searchQuery(with searchParameters: SearchParametersType) -> Table {
        table.filter(
            searchParameters.priceRange.contains(price)
        ).order(name.asc)
    }
}

fileprivate struct SpeakerTableHelper: TableHelper {
    typealias ObjectType = Speaker
    typealias SearchParametersType = SpeakerSearchParameters
    
    let table = Table("speakers")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let price = Expression<Int>("price")
    private let url = Expression<String?>("url")
    private let imageUrl = Expression<String?>("imageUrl")
    private let selfPowered = Expression<Bool>("selfPowered")
    
    init() { }
    
    func buildTableQuery() -> String {
        table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(price)
            t.column(url)
            t.column(imageUrl)
            t.column(selfPowered)
        }
    }
    
    func updateQuery(object: ObjectType) -> Update {
        table.filter(id == object.id)
            .update(
                id <- object.id,
                name <- object.name,
                price <- object.price,
                url <- object.url,
                imageUrl <- object.imageUrl,
                selfPowered <- object.selfPowered
            )
    }
    
    func insertQuery(object: ObjectType) -> Insert {
        table.insert(
            id <- object.id,
            name <- object.name,
            price <- object.price,
            url <- object.url,
            imageUrl <- object.imageUrl,
            selfPowered <- object.selfPowered
        )
    }
    
    func searchQuery(with searchParameters: SearchParametersType) -> Table {
        table.filter(
            searchParameters.priceRange.contains(price)
        ).order(name.asc)
    }
}

fileprivate struct SubwoofersTableHelper: TableHelper {
    typealias ObjectType = Subwoofer
    typealias SearchParametersType = SubwooferSearchParameters
    
    let table = Table("subwoofers")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let price = Expression<Int>("price")
    private let url = Expression<String?>("url")
    private let imageUrl = Expression<String?>("imageUrl")
    private let style = Expression<String>("style")
    
    init() { }
    
    func buildTableQuery() -> String {
        table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(price)
            t.column(url)
            t.column(imageUrl)
            t.column(style)
        }
    }
    
    func updateQuery(object: ObjectType) -> Update {
        table.filter(id == object.id)
            .update(
                id <- object.id,
                name <- object.name,
                price <- object.price,
                url <- object.url,
                imageUrl <- object.imageUrl,
                style <- object.style
            )
    }
    
    func insertQuery(object: ObjectType) -> Insert {
        table.insert(
            id <- object.id,
            name <- object.name,
            price <- object.price,
            url <- object.url,
            imageUrl <- object.imageUrl,
            style <- object.style
        )
    }
    
    func searchQuery(with searchParameters: SearchParametersType) -> Table {
        table.filter(
            searchParameters.priceRange.contains(price)
        ).order(name.asc)
    }
}

fileprivate struct HeadphoneSourcesTableHelper: TableHelper {
    typealias ObjectType = HeadphoneSource
    typealias SearchParametersType = HeadphoneSourceSearchParameters
    
    let table = Table("headphone_sources")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let price = Expression<Int>("price")
    private let url = Expression<String?>("url")
    private let imageUrl = Expression<String?>("imageUrl")
    private let formFactor = Expression<String>("formFactor")
    private let unitType = Expression<String>("unitType")
    private let topology = Expression<String>("topology")
    private let balanced = Expression<Bool>("balanced")
    
    init() { }
    
    func buildTableQuery() -> String {
        table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(price)
            t.column(url)
            t.column(imageUrl)
            t.column(formFactor)
            t.column(unitType)
            t.column(topology)
            t.column(balanced)
        }
    }
    
    func updateQuery(object: ObjectType) -> Update {
        table.filter(id == object.id)
            .update(
                id <- object.id,
                name <- object.name,
                price <- object.price,
                url <- object.url,
                imageUrl <- object.imageUrl,
                formFactor <- object.formFactor,
                unitType <- object.unitType,
                topology <- object.topology,
                balanced <- object.balanced
            )
    }
    
    func insertQuery(object: ObjectType) -> Insert {
        table.insert(
            id <- object.id,
            name <- object.name,
            price <- object.price,
            url <- object.url,
            imageUrl <- object.imageUrl,
            formFactor <- object.formFactor,
            unitType <- object.unitType,
            topology <- object.topology,
            balanced <- object.balanced
        )
    }
    
    func searchQuery(with searchParameters: SearchParametersType) -> Table {
        table.filter(
            searchParameters.priceRange.contains(price)
        ).order(name.asc)
    }
}

class ProductRepository {
    static var productDatabasePath: String? = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        guard let documentsPathString = documentsURL?.absoluteString else {
            return nil
            
        }
        return documentsPathString.appending("products.sqlite3")
    }()
    
    var db: Connection?
    fileprivate let headphonesTableHelper = HeadphonesTableHelper()
    fileprivate let inEarMonitorsTableHelper = InEarMonitorsTableHelper()
    fileprivate let speakersTableHelper = SpeakerTableHelper()
    fileprivate let subwoofersTableHelper = SubwoofersTableHelper()
    fileprivate let headphoneSourcesTableHelper = HeadphoneSourcesTableHelper()
    
    init() {
        createDatabase(tableHelper: headphonesTableHelper)
        createDatabase(tableHelper: inEarMonitorsTableHelper)
        createDatabase(tableHelper: speakersTableHelper)
        createDatabase(tableHelper: subwoofersTableHelper)
        createDatabase(tableHelper: headphoneSourcesTableHelper)
    }
    
    private func createDatabase<T: TableHelper>(tableHelper: T) {
        guard let productDbPath = Self.productDatabasePath else { return }
        do {
            db = try Connection(.uri(productDbPath), readonly: false)
            guard let db = db else { return }
            try db.run(tableHelper.buildTableQuery())
        } catch {
            print(error)
        }
    }
    
    // MARK: Upsert
    
    func upsert(headphones: [Headphone]) {
        headphones.forEach { upsert(object: $0, using: headphonesTableHelper) }
    }
    
    func upsert(inEarMonitors: [InEarMonitor]) {
        inEarMonitors.forEach { upsert(object: $0, using: inEarMonitorsTableHelper) }
    }
    
    func upsert(speakers: [Speaker]) {
        speakers.forEach { upsert(object: $0, using: speakersTableHelper) }
    }
    
    func upsert(subwoofers: [Subwoofer]) {
        subwoofers.forEach { upsert(object: $0, using: subwoofersTableHelper) }
    }
    
    func upsert(headphoneSources: [HeadphoneSource]) {
        headphoneSources.forEach { upsert(object: $0, using: headphoneSourcesTableHelper) }
    }
    
    private func upsert<T: TableHelper>(object: T.ObjectType, using tableHelper: T) {
            do {
                guard let db = db else { return }
                try db.transaction {
                    if try db.run(tableHelper.updateQuery(object: object)) == 0 {
                        try db.run(tableHelper.insertQuery(object: object))
                    }
                }
            } catch {
                print(error)
            }
    }
    
    // MARK: Get
    
    func getHeadphones(with searchParameters: HeadphoneSearchParameters) -> [Headphone] {
        self.getProducts(tableHelper: headphonesTableHelper, with: searchParameters)
    }
    
    func getInEarMonitors(with searchParameters: InEarMonitorSearchParameters) -> [InEarMonitor] {
        self.getProducts(tableHelper: inEarMonitorsTableHelper, with: searchParameters)
    }
    
    func getSpeakers(with searchParameters: SpeakerSearchParameters) -> [Speaker] {
        self.getProducts(tableHelper: speakersTableHelper, with: searchParameters)
    }
    
    func getSubwoofers(with searchParameters: SubwooferSearchParameters) -> [Subwoofer] {
        self.getProducts(tableHelper: subwoofersTableHelper, with: searchParameters)
    }
    
    func getHeadphoneSources(with searchParameters: HeadphoneSourceSearchParameters) -> [HeadphoneSource] {
        self.getProducts(tableHelper: headphoneSourcesTableHelper, with: searchParameters)
    }
    
    private func getProducts<T: TableHelper>(tableHelper: T, with searchParameters: T.SearchParametersType) -> [T.ObjectType] {
        guard let productDbPath = Self.productDatabasePath else { return [] }
        var products = [T.ObjectType]()
        do {
            let db = try Connection(.uri(productDbPath), readonly: true)
            products = try db.prepare(tableHelper.searchQuery(with: searchParameters)).map { row -> T.ObjectType in
                try row.decode()
            }
        } catch {
            print(error)
        }
        return products
    }
    
    // Observing
    
    func dataChangedPublisher() -> AnyPublisher<Void, Never> {
        Deferred { [weak self] () -> PassthroughSubject<Void, Never> in
            let subject = PassthroughSubject<Void, Never>()
            self?.db?.commitHook {
                subject.send()
            }
            return subject
        }.eraseToAnyPublisher()
    }
}
