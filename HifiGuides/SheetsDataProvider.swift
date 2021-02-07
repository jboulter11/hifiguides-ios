import Foundation
import RxSwift
import SwiftyJSON

protocol SheetsDataProvider {
    func getHeadphones(with parameters: HeadphoneSearchParameters) -> Single<[Headphone]>
}

enum SheetsDataProviderError : Error {
    case invalidUrl
    case networkRequestReturnedError(error: Error?)
    case invalidResponse
}

class SheetsDataProviderImpl : SheetsDataProvider {
    static let key = "AIzaSyDn0C2RHLogw09oF5zt10DMQZSSmGseUQg"
    static let sheetUrl = "https://sheets.googleapis.com/v4/spreadsheets/1e6qXF1Ihw98aWZlGO9jVdLJr8tUvTztxQTsSutYLYpU/values/"
    static let queryParams = "?valueRenderOption=FORMATTED_VALUE&key="
    
    init() { }
    
    func getHeadphones(with parameters: HeadphoneSearchParameters) -> Single<[Headphone]> {
        return getData(with: getUrlString(for: .Headphones))
            .map { data in
                guard let headphones = SheetDataParser.parseHeadphones(from: data) else {
                    throw SheetsDataProviderError.invalidResponse
                }
                return headphones
            }.subscribe(on: SerialDispatchQueueScheduler(qos: .userInteractive))
    }
    
    private func getUrlString(for category: ProductCategory) -> String {
        let urlString =
            Self.sheetUrl
            + category.rawValue
            + Self.queryParams
            + Self.key
        
        return urlString
    }
    
    func getData(with urlString: String) -> Single<Data> {
        Single.create { observer -> Disposable in
            guard let url = URL(string: urlString) else {
                observer(.failure(SheetsDataProviderError.invalidResponse))
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    observer(.failure(SheetsDataProviderError.networkRequestReturnedError(error: error)))
                    return
                }
                observer(.success(data))
            }.resume()
            
            return Disposables.create()
        }
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
        
        static func parseHeadphones(from data: Data) -> [Headphone]? {
            let json = JSON(data)["values"]
            let mapping = metadataMapping(from: json)
            guard validateLabels(from: json, requiredFields: Headphone.requiredFields()) else {
                return nil
            }
            return parseHeadphones(rowsWithLabels: json, metadataMapping: mapping)
        }
        
        static func metadataMapping(from json: JSON) -> [String:Int] {
            var metadataMapping = [String:Int]()
            for (index, label) in json[0].arrayValue.enumerated() {
                metadataMapping[label.stringValue] = index
            }
            return metadataMapping
        }
        
        static func validateLabels(from json: JSON, requiredFields: [String]) -> Bool {
            let arrayOfLabels = json[0].arrayValue.map { $0.stringValue }
            for field in requiredFields {
                guard arrayOfLabels.contains(field) else {
                    return false
                }
            }
            return true
        }
        
        private static func parseHeadphones(rowsWithLabels: JSON, metadataMapping: [String:Int]) -> [Headphone] {
            let rowsWithoutLabels = rowsWithLabels.arrayValue.dropFirst()
            return rowsWithoutLabels.compactMap { row in
                guard row.count == 8 else {
                    return nil
                }
                
                return Headphone(
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
        
        private static func parse(rowsWithLabels: JSON, metadataMapping: [String:Int]) -> [InEarMonitor] {
            let rows = JSON(rowsWithLabels.dropFirst()).arrayValue
            return rows.compactMap { row in
                guard row.count == 5 else {
                    return nil
                }
                
                return InEarMonitor(
                    name: row[metadataMapping["name"]!].stringValue,
                    price: row[metadataMapping["price"]!].intValue,
                    url: row[metadataMapping["url"]!].string,
                    imageUrl: row[metadataMapping["img"]!].string,
                    frequencyResponseType: row[metadataMapping["category"]!].stringValue
                )
            }
        }
    }
}

fileprivate extension Headphone {
    static func requiredFields() -> [String] {
        [
            "name",
            "url",
            "img",
            "price",
            "amp",
            "back_type",
            "category",
            "review",
        ]
    }
}
