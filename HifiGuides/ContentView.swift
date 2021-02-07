import SwiftUI
import Sliders
import SDWebImageSwiftUI

protocol SelectableRow {
    var text: String { get }
    var isSelected: Bool { get set }
}

struct SelectionCell: View {
    let category: ProductCategory
    @Binding var selected: ProductCategory?

    var body: some View {
        HStack {
            Text(category.rawValue)
            Spacer()
            if category == selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selected = self.category
        }
    }
}

struct CuteHeader: View {
    var text:String
    var body: some View {
        Text(text)
            .padding(6)
            .background(Color.accentColor)
            .cornerRadius(6)
            .foregroundColor(.white)
            .font(.title3)
            .alignmentGuide(HorizontalAlignment.center, computeValue: { dimension in
                dimension[HorizontalAlignment.center]
            })
    }
}

struct ContentView: View {
    @ObservedObject var contentModel: ContentModel
        
    var productCategories = ProductCategory.allCases
    
    init(contentModel: ContentModel) {
        self.contentModel = contentModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        CuteHeader(text: "Looking for:")
                        List {
                            ForEach(productCategories, id: \.self) { item in
                                SelectionCell(category: item, selected: $contentModel.productCategory)
                                    .padding(4)
                            }
                        }
                    }.frame(maxWidth: .infinity)
                }
                if contentModel.productCategory != nil {
                    Section {
                        VStack {
                            CuteHeader(text: "Price Range:")
                            RangeSlider(range: $contentModel.priceRange, in: 0...2000, step: Int.Stride(1.0))
                            HStack {
                                Text("$\(Int($contentModel.priceRange.wrappedValue.lowerBound))")
                                Spacer()
                                Text("$\(Int($contentModel.priceRange.wrappedValue.upperBound))")
                            }
                        }.frame(maxWidth: .infinity)
                    }
                    Section {
                        List(contentModel.products) { product in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(product.name)")
                                    Spacer()
                                    Text("$\(product.price)")
                                }
                                WebImage(url: URL(string: product.imageUrl ?? ""))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }.padding()
                        }
                    }
                    
                }
            }.navigationTitle("Hifi Guides")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(contentModel: ContentModel())
    }
}
