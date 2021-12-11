import SwiftUI

struct RecenterButton: View {
    
    let onTapped: () -> ()
    
    var body: some View {
        Button(action: onTapped, label: {
            Label("Centralizar", systemImage: "triangle")
        }).padding(10)
        .foregroundColor(.white)
        .background(Color("main"))
        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
    }
}

struct RecenterButton_Previews: PreviewProvider {
    static var previews: some View {
        RecenterButton(onTapped: {})
    }
}
