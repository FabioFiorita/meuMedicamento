import SwiftUI

struct TabDetailsView: View {
    let index: Int
    var body: some View {
        VStack {
            Image(tabs[index].image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
            
            Text(tabs[index].title)
                .font(.title)
                .bold()
            
            Text(tabs[index].text)
                .padding()
                .allowsTightening(true)
                .minimumScaleFactor(0.01)
                .lineLimit(8)
    
    }
        .foregroundColor(.white)
}
}

struct TabDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientView()
            TabDetailsView(index: 0)
        }
    }
}
