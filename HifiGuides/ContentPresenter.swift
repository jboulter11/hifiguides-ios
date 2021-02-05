import Combine
import RxSwift
import Foundation

class ContentModel : ObservableObject {
    // events
    @Published var productCategory:String?
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
        sheetsDataProvider.getData(with: SearchParameters(productCategory: "Headphones", priceRange: 0...2000))
            .observe(on: SerialDispatchQueueScheduler(qos: .userInteractive))
            .subscribe { [weak self] sheetData in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self,
                          let products = sheetData?.products else { return }
                    
                    self.productRepository.insert(products: products)
                }
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
}
