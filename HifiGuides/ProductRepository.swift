import FileProvider
import SQLite
import RxSwift
import Combine

enum ProductRepositoryError : Error {
    case cannotConnectToDatabase
}

class ProductRepository {
    let productsTable = Table("products")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let price = Expression<Int>("price")
    let url = Expression<String?>("url")
    let reviewUrl = Expression<String?>("reviewUrl")
    let imageUrl = Expression<String?>("imageUrl")
    let ampRequired = Expression<Bool>("ampRequired")
    let backType = Expression<String>("backType")
    let frequencyResponseType = Expression<String>("frequencyResponseType")
    
    static var productDatabasePath: String? = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        guard let documentsPathString = documentsURL?.absoluteString else {
            return nil
            
        }
        return documentsPathString.appending("products.sqlite3")
    }()
    
    var db: Connection?
    
    init() {
        createDatabase()
    }
    
    func createDatabase() {
        guard let productDbPath = Self.productDatabasePath else { return }
        do {
            db = try Connection(.uri(productDbPath), readonly: false)
            guard let db = db else { return }
            try db.run(productsTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name, unique: true)
                t.column(price)
                t.column(url)
                t.column(reviewUrl)
                t.column(imageUrl)
                t.column(ampRequired)
                t.column(backType)
                t.column(frequencyResponseType)
            })
        } catch {
            print(error)
        }
    }
    
    func insert(products: [Product]) {
        products.forEach { insert(product: $0) }
    }
    
    func insert(product: Product) {
        do {
            guard let db = db else { return }
            try db.transaction {
                if try db.run(productsTable
                    .filter(id == product.id)
                    .update(
                        id <- product.id,
                        name <- product.name,
                        price <- product.price,
                        url <- product.url,
                        reviewUrl <- product.reviewUrl,
                        imageUrl <- product.imageUrl,
                        ampRequired <- product.ampRequired,
                        backType <- product.backType,
                        frequencyResponseType <- product.frequencyResponseType
                    )
                ) == 0 {
                    try db.run(productsTable
                        .insert(
                            id <- product.id,
                            name <- product.name,
                            price <- product.price,
                            url <- product.url,
                            reviewUrl <- product.reviewUrl,
                            imageUrl <- product.imageUrl,
                            ampRequired <- product.ampRequired,
                            backType <- product.backType,
                            frequencyResponseType <- product.frequencyResponseType
                        )
                    )
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getProducts(with searchParameters: SearchParameters) -> [Product] {
        guard let productDbPath = Self.productDatabasePath else { return [] }
        var products = [Product]()
        do {
            let db = try Connection(.uri(productDbPath), readonly: true)
            products = try db.prepare(
                productsTable.filter(
                    searchParameters.priceRange.contains(price)
                )
            ).map { row -> Product in
                try row.decode()
            }
        } catch {
            print(error)
        }
        return products
    }
    
//    var hookConnection: Connection?
//    func dataChangedPublisher() -> AnyPublisher<Void, ProductRepositoryError> {
//        let subject = PassthroughSubject<Void, ProductRepositoryError>()
//        guard let productDbPath = Self.productDatabasePath else {
//            subject.send(completion: .failure(.cannotConnectToDatabase))
//            return subject.eraseToAnyPublisher()
//        }
//        do {
//            hookConnection = try Connection(.uri(productDbPath), readonly: true)
//            hookConnection?.commitHook {
//                subject.send()
//            }
//        } catch {
//            print(error)
//            subject.send(completion: .failure(.cannotConnectToDatabase))
//        }
//        return subject.eraseToAnyPublisher()
//    }
    
    func dataChangedPublisher() -> Deferred<AnyPublisher<Void, Never>> {
        Deferred<AnyPublisher<Void, Never>> { [weak self] in
            let subject = PassthroughSubject<Void, Never>()
//            guard let productDbPath = Self.productDatabasePath else {
//                subject.send(completion: .failure(.cannotConnectToDatabase))
//                return subject.eraseToAnyPublisher()
//            }
//            do {
                self?.db?.commitHook {
                    subject.send()
                }
//            } catch {
//                print(error)
//                subject.send(completion: .failure(.cannotConnectToDatabase))
//            }
            return subject.eraseToAnyPublisher()
        }
    }
    
    func dataChangedObservable() -> Observable<()> {
        guard let productDbPath = Self.productDatabasePath else {
            return Observable.error(ProductRepositoryError.cannotConnectToDatabase)
        }
        do {
            let db = try Connection(.uri(productDbPath), readonly: true)
            
            return Observable.create { observer in
                db.commitHook {
                    observer.onNext(())
                }
                return Disposables.create()
            }
        } catch {
            print(error)
            return Observable.error(ProductRepositoryError.cannotConnectToDatabase)
        }
    }
}
