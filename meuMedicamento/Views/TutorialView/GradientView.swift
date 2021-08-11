import SwiftUI

struct GradientView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [
        Color("main"),
        Color("lightBlue"),
        Color("second")
        ]), startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView()
    }
}
