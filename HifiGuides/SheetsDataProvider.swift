import Foundation
import RxSwift
import SwiftyJSON
import Combine

protocol SheetsDataProvider {
    func getHeadphones() -> AnyPublisher<[Headphone], Error>
    func getInEarMonitors() -> AnyPublisher<[InEarMonitor], Error>
    func getSpeakers() -> AnyPublisher<[Speaker], Error>
    func getSubwoofers() -> AnyPublisher<[Subwoofer], Error>
    func getHeadphoneSources() -> AnyPublisher<[HeadphoneSource], Error>
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
    
    func getHeadphones() -> AnyPublisher<[Headphone], Error> {
        getData(with: getUrlString(for: .Headphones))
            .tryMap { data in
                guard let parsedResponse = SheetDataParser.parseHeadphones(from: data) else {
                    throw SheetsDataProviderError.invalidResponse
                }
                return parsedResponse
            }.eraseToAnyPublisher()
    }
    
    func getInEarMonitors() -> AnyPublisher<[InEarMonitor], Error> {
        getData(with: getUrlString(for: .InEars))
            .tryMap { data in
                guard let parsedResponse = SheetDataParser.parseInEarMonitors(from: data) else {
                    throw SheetsDataProviderError.invalidResponse
                }
                return parsedResponse
            }.eraseToAnyPublisher()
    }
    
    func getSpeakers() -> AnyPublisher<[Speaker], Error> {
        getData(with: getUrlString(for: .Speakers))
            .tryMap { data in
                guard let parsedResponse = SheetDataParser.parseSpeakers(from: data) else {
                    throw SheetsDataProviderError.invalidResponse
                }
                return parsedResponse
            }.eraseToAnyPublisher()
    }
    
    func getSubwoofers() -> AnyPublisher<[Subwoofer], Error> {
        getData(with: getUrlString(for: .Subwoofers))
            .tryMap { data in
                guard let parsedResponse = SheetDataParser.parseSubwoofers(from: data) else {
                    throw SheetsDataProviderError.invalidResponse
                }
                return parsedResponse
            }.eraseToAnyPublisher()
    }
    
    func getHeadphoneSources() -> AnyPublisher<[HeadphoneSource], Error> {
        getData(with: getUrlString(for: .HeadphoneSources))
            .tryMap { data in
                guard let parsedResponse = SheetDataParser.parseHeadphoneSources(from: data) else {
                    throw SheetsDataProviderError.invalidResponse
                }
                return parsedResponse
            }.eraseToAnyPublisher()
    }
    
    private func getData(with urlString: String) -> Deferred<Future<Data, SheetsDataProviderError>> {
        Deferred {
            Future { promise in
                guard let url = URL(string: urlString) else {
                    promise(.failure(SheetsDataProviderError.invalidResponse))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else {
                        promise(.failure(SheetsDataProviderError.networkRequestReturnedError(error: error)))
                        return
                    }
                    promise(.success(data))
                }.resume()
            }
        }
    }
    
    private func getUrlString(for category: ProductCategory) -> String {
        let urlString =
            Self.sheetUrl
            + (category.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            + Self.queryParams
            + Self.key
        
        return urlString
    }
    
    private class SheetDataParser {
        static func parseHeadphones(from data: Data) -> [Headphone]? {
            guard let (json, mapping) = prepare(data: data, for: .Headphones) else {
                return nil
            }
            return parseHeadphones(rows: json, metadataMapping: mapping)
        }
        
        static func parseInEarMonitors(from data: Data) -> [InEarMonitor]? {
            guard let (json, mapping) = prepare(data: data, for: .InEars) else {
                return nil
            }
            return parseInEarMonitors(rows: json, metadataMapping: mapping)
        }
        
        static func parseSpeakers(from data: Data) -> [Speaker]? {
            guard let (json, mapping) = prepare(data: data, for: .Speakers) else {
                return nil
            }
            return parseSpeakers(rows: json, metadataMapping: mapping)
        }
        
        static func parseSubwoofers(from data: Data) -> [Subwoofer]? {
            guard let (json, mapping) = prepare(data: data, for: .Subwoofers) else {
                return nil
            }
            return parseSubwoofers(rows: json, metadataMapping: mapping)
        }
        
        static func parseHeadphoneSources(from data: Data) -> [HeadphoneSource]? {
            guard let (json, mapping) = prepare(data: data, for: .HeadphoneSources) else {
                return nil
            }
            return parseHeadphoneSources(rows: json, metadataMapping: mapping)
        }
        
        static func prepare(data: Data, for productCategory: ProductCategory) -> ([JSON], [String:Int])? {
            let json = JSON(data)["values"]
            let mapping = metadataMapping(from: json)
            guard validateLabels(from: json, requiredFields: Self.requiredFields(for: productCategory)) else {
                return nil
            }
            return (Array(json.arrayValue.dropFirst()), mapping)
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
        
        private static func parseHeadphones(rows: [JSON], metadataMapping: [String:Int]) -> [Headphone] {
            return rows.compactMap { row in
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
        
        private static func parseInEarMonitors(rows: [JSON], metadataMapping: [String:Int]) -> [InEarMonitor] {
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
        
        private static func parseSpeakers(rows: [JSON], metadataMapping: [String:Int]) -> [Speaker] {
            return rows.compactMap { row in
                guard row.count == 5 else {
                    return nil
                }
                
                return Speaker(
                    name: row[metadataMapping["name"]!].stringValue,
                    price: row[metadataMapping["price"]!].intValue,
                    url: row[metadataMapping["url"]!].string,
                    imageUrl: row[metadataMapping["img"]!].string,
                    selfPowered: row[metadataMapping["Self Powered"]!].boolValue
                )
            }
        }
        
        private static func parseSubwoofers(rows: [JSON], metadataMapping: [String:Int]) -> [Subwoofer] {
            return rows.compactMap { row in
                guard row.count == 5 else {
                    return nil
                }
                
                return Subwoofer(
                    name: row[metadataMapping["name"]!].stringValue,
                    price: row[metadataMapping["price"]!].intValue,
                    url: row[metadataMapping["url"]!].string,
                    imageUrl: row[metadataMapping["img"]!].string,
                    style: row[metadataMapping["style"]!].stringValue
                )
            }
        }
        
        private static func parseHeadphoneSources(rows: [JSON], metadataMapping: [String:Int]) -> [HeadphoneSource] {
            return rows.compactMap { row in
                guard row.count == 8 else {
                    return nil
                }
                
                return HeadphoneSource(
                    name: row[metadataMapping["name"]!].stringValue,
                    price: row[metadataMapping["price"]!].intValue,
                    url: row[metadataMapping["url"]!].string,
                    imageUrl: row[metadataMapping["img"]!].string,
                    formFactor: row[metadataMapping["form factor"]!].stringValue,
                    unitType: row[metadataMapping["unit type"]!].stringValue,
                    topology: row[metadataMapping["topology"]!].stringValue,
                    balanced: row[metadataMapping["balanced"]!].boolValue
                )
            }
        }
        
        private static func requiredFields(for productCategory: ProductCategory) -> [String] {
            switch productCategory {
            case .Headphones:
                return [
                    "name",
                    "url",
                    "img",
                    "price",
                    "amp",
                    "back_type",
                    "category",
                    "review",
                ]
            case .InEars:
                return [
                    "name",
                    "url",
                    "img",
                    "price",
                    "category",
                ]
            case .Speakers:
                return [
                    "name",
                    "url",
                    "img",
                    "price",
                    "Self Powered"
                ]
            case .Subwoofers:
                return [
                    "name",
                    "url",
                    "img",
                    "price",
                    "style",
                ]
            case .HeadphoneSources:
                return [
                    "name",
                    "url",
                    "img",
                    "price",
                    "form factor",
                    "unit type",
                    "topology",
                    "balanced",
                ]
            }
        }
    }
}
