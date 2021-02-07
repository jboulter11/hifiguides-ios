import Combine
import RxSwift
import Foundation

class ContentModel : ObservableObject {
    // events
    @Published var productCategory:ProductCategory?
    @Published var priceRange = 0...2000
    
    // state
    @Published var products: [Product] = []
}

class ContentPresenter {
    let sheetsDataProvider: SheetsDataProvider
    let productRepository: ProductRepository
    let searchStateRepository: SearchStateRepository
    let disposeBag = DisposeBag()
    
    @Published var model: ContentModel = ContentModel()
    
    var cancelBag = Set<AnyCancellable>()
    
    init(sheetsDataProvider: SheetsDataProvider,
         productRepository: ProductRepository,
         searchStateRepository: SearchStateRepository) {
        self.sheetsDataProvider = sheetsDataProvider
        self.productRepository = productRepository
        self.searchStateRepository = searchStateRepository
        
        self.searchStateRepository.$searchModel.assign(to: \.model, on: self).store(in: &cancelBag)
        
        // TODO: move me and query more data
        sheetsDataProvider.getHeadphones(with: HeadphoneSearchParameters(priceRange: 0...2000))
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] headphones in
                guard let self = self else { return }
                
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.productRepository.insert(headphones: headphones)
                }
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
}
