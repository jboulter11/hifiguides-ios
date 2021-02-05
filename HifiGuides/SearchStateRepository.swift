import Foundation
import Combine

class SearchStateRepository {
    @Published var searchModel = ContentModel()
    
    var cancelBag: Set<AnyCancellable> = []
    
    init(productRepository: ProductRepository) {
        Publishers.CombineLatest3(searchModel.$priceRange, searchModel.$productCategory, productRepository.dataChangedPublisher())
            .map { (priceRange, productCategory, dataDidChange) -> [Product] in
                guard let productCategory = productCategory else {
                    return [Product]()
                }
                return productRepository.getProducts(with: SearchParameters(productCategory: productCategory, priceRange: priceRange))
            }.sink { [weak self] products in
                self?.searchModel.products = products
            }.store(in: &cancelBag)
    }
}
