import Combine
import RxSwift
import Foundation

class ContentPresenter : ObservableObject {
    @Published var products: [Product] = []
    
    let sheetsDataProvider: SheetsDataProvider
    let disposeBag = DisposeBag()
    
    init(sheetsDataProvider: SheetsDataProvider) {
        self.sheetsDataProvider = sheetsDataProvider
        sheetsDataProvider.getData(with: SearchParameters(productCategory: "Headphones", priceRange: 0...2000)).subscribe { [weak self] sheetData in
            DispatchQueue.main.async { [weak self] in
                self?.products = sheetData?.products ?? []
            }
        } onFailure: { error in
            print(error)
        }.disposed(by: disposeBag)

    }
}
