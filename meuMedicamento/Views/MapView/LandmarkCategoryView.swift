import SwiftUI

struct LandmarkCategoryView: View {
    
    let categories = ["Farmácias", "Hospitais"]
    let onSelectedCategory: (String) -> ()
    @State private var selectedCategory: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
            
            HStack {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        onSelectedCategory(category)
                    }, label: {
                        Text(LocalizedStringKey(category))
                    }).padding(15)
                    .foregroundColor(Color.white)
                    .background(selectedCategory == category ? Color("AccentColor"): Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                    
                    
                }
            
        }
    }
}

struct LandmarkCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkCategoryView(onSelectedCategory: { _ in })
    }
}

