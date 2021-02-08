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
    
    let interactorQueue = DispatchQueue.global(qos: .userInitiated)
    
    @Published var model: ContentModel = ContentModel()
    
    var cancelBag = Set<AnyCancellable>()
    
    init(sheetsDataProvider: SheetsDataProvider,
         productRepository: ProductRepository,
         searchStateRepository: SearchStateRepository) {
        self.sheetsDataProvider = sheetsDataProvider
        self.productRepository = productRepository
        self.searchStateRepository = searchStateRepository
        
        self.searchStateRepository.$searchModel.assign(to: \.model, on: self).store(in: &cancelBag)
        
        // TODO: move me
        sheetsDataProvider.getHeadphones()
            .receive(on: interactorQueue)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                self?.productRepository.upsert(headphones: response)
            }.store(in: &cancelBag)
        
        sheetsDataProvider.getInEarMonitors()
            .receive(on: interactorQueue)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                self?.productRepository.upsert(inEarMonitors: response)
            }.store(in: &cancelBag)
        
        sheetsDataProvider.getSpeakers()
            .receive(on: interactorQueue)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                self?.productRepository.upsert(speakers: response)
            }.store(in: &cancelBag)
        
        sheetsDataProvider.getSubwoofers()
            .receive(on: interactorQueue)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                self?.productRepository.upsert(subwoofers: response)
            }.store(in: &cancelBag)
        
        sheetsDataProvider.getHeadphoneSources()
            .receive(on: interactorQueue)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                self?.productRepository.upsert(headphoneSources: response)
            }.store(in: &cancelBag)

        
//        sheetsDataProvider.getInEarMonitors()
//            .observe(on: MainScheduler.instance)
//            .subscribe { [weak self] inEarMonitors in
//                guard let self = self else { return }
//
//                DispatchQueue.global(qos: .background).async { [weak self] in
//                    self?.productRepository.insert(inEarMonitors: inEarMonitors)
//                }
//            } onFailure: { error in
//                print(error)
//            }.disposed(by: disposeBag)
    }
}
