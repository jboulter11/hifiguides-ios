import Foundation
import Combine

class SearchStateRepository {
    @Published var searchModel = ContentModel()
    
    var cancelBag: Set<AnyCancellable> = []
    
    init(productRepository: ProductRepository) {
        Publishers.CombineLatest3(searchModel.$priceRange, searchModel.$productCategory, productRepository.dataChangedPublisher())
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .map { (priceRange, productCategory, dataDidChange) -> [Product] in
                guard let productCategory = productCategory else {
                    return []
                }
                
                switch productCategory {
                case .Headphones:
                    return productRepository.getHeadphones(with: HeadphoneSearchParameters(priceRange: priceRange))
                        .map { Product(headphone: $0) }
                case .InEars:
                    return productRepository.getInEarMonitors(with: InEarMonitorSearchParameters(priceRange: priceRange))
                        .map { Product(inEarMonitor: $0) }
                case .Speakers:
                    return productRepository.getSpeakers(with: SpeakerSearchParameters(priceRange: priceRange))
                        .map { Product(speaker: $0) }
                case .Subwoofers:
                    return productRepository.getSubwoofers(with: SubwooferSearchParameters(priceRange: priceRange))
                        .map { Product(subwoofer: $0) }
                case .HeadphoneSources:
                    return productRepository.getHeadphoneSources(with: HeadphoneSourceSearchParameters(priceRange: priceRange))
                        .map { Product(headphoneSource: $0) }
                }
                
            }.receive(on: RunLoop.main)
            .sink { [weak self] products in
                self?.searchModel.products = products
            }.store(in: &cancelBag)
    }
}
