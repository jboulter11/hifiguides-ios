import SwiftUI

@main
struct HifiGuidesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(contentPresenter: ContentPresenter(sheetsDataProvider: SheetsDataProviderImpl()))
        }
    }
}
