import SwiftUI

@main
struct HifiGuidesApp: App {
    let productRepository: ProductRepository
    let presenter: ContentPresenter
    let searchStateRepository: SearchStateRepository
    init() {
        productRepository = ProductRepository()
        searchStateRepository = SearchStateRepository(productRepository: productRepository)
        presenter = ContentPresenter(sheetsDataProvider: SheetsDataProviderImpl(), productRepository: productRepository, searchStateRepository: searchStateRepository)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(contentModel: presenter.model)
        }
    }
}
