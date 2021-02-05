import Foundation
import RxSwift
import SwiftyJSON

struct SearchParameters {
    var productCategory: String
    var priceRange: ClosedRange<Int>
    
}

struct SheetData {
    var products: [Product]
}

struct Product: Identifiable, Equatable, Codable {
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

protocol SheetsDataProvider {
    func getData(with parameters: SearchParameters) -> Single<SheetData?>
}

enum SheetsDataProviderError : Error {
    case invalidUrl
    case networkRequestReturnedError(error: Error?)
    case invalidResponse
}

class SheetsDataProviderImpl : SheetsDataProvider {
    static let key = "AIzaSyDn0C2RHLogw09oF5zt10DMQZSSmGseUQg"
    
    init() { }
    
    func getData(with parameters: SearchParameters) -> Single<SheetData?> {
        return Single.create { observer -> Disposable in
            let urlString = "https://sheets.googleapis.com/v4/spreadsheets/1e6qXF1Ihw98aWZlGO9jVdLJr8tUvTztxQTsSutYLYpU/values/"
                + parameters.productCategory
                + "?valueRenderOption=FORMATTED_VALUE&key=\(Self.key)"
            guard let url = URL(string: urlString) else {
                observer(.failure(SheetsDataProviderError.invalidUrl))
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    observer(.failure(SheetsDataProviderError.networkRequestReturnedError(error: error)))
                    return
                }
                
                guard let sheetData = SheetDataParser.parse(data: data) else {
                    observer(.failure(SheetsDataProviderError.invalidResponse))
                    return
                }
                observer(.success(sheetData))
            }.resume()
            
            return Disposables.create()
        }.subscribe(on: SerialDispatchQueueScheduler(qos: .userInteractive))
    }
    
    private class SheetDataParser {
        struct MetadataMapping {
            var nameIndex: Int?
            var priceIndex: Int?
            var urlIndex: Int?
            var ampIndex: Int?
            var backTypeIndex: Int?
            var categoryIndex: Int?
            var reviewIndex: Int?
        }
        
        static func parse(data: Data) -> SheetData? {
            let json = JSON(data)
            
            let values = json["values"]
            
            var metadataMapping = [String:Int]()
            for (index, label) in values[0].arrayValue.enumerated() {
                metadataMapping[label.stringValue] = index
            }
            guard values[0].arrayValue.contains("name"),
                  values[0].arrayValue.contains("url"),
                  values[0].arrayValue.contains("img"),
                  values[0].arrayValue.contains("price"),
                  values[0].arrayValue.contains("amp"),
                  values[0].arrayValue.contains("back_type"),
                  values[0].arrayValue.contains("category"),
                  values[0].arrayValue.contains("review") else {
                return nil
            }
            
            let products = values.dropFirst().compactMap { string, row in
                return parse(row: row, metadataMapping: metadataMapping)
            }
            
            return SheetData(products: products)
        }
        
        static func parse(row: JSON, metadataMapping: [String:Int]) -> Product? {
            guard row.count == 8 else {
                return nil
            }
            
            return Product(
                name: row[metadataMapping["name"]!].stringValue,
                price: row[metadataMapping["price"]!].intValue,
                url: row[metadataMapping["url"]!].string,
                reviewUrl: row[metadataMapping["review"]!].string,
                imageUrl: row[metadataMapping["img"]!].string,
                ampRequired: row[metadataMapping["amp"]!].boolValue,
                backType: row[metadataMapping["back_type"]!].stringValue,
                frequencyResponseType: row[metadataMapping["category"]!].stringValue
            )
        }
    }
}
