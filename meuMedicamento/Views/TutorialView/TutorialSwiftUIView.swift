import SwiftUI

struct TutorialSwiftUIView: View {
    @State private var selection = 0
    @Binding var isWalkthroughViewShowing: Bool
    
    var body: some View {
        ZStack {
            GradientView()
            
            VStack {
                PageTabView(selection: $selection)
                ButtonsView(selection: $selection)
                StartButtonView(isWalkthroughViewShowing: $isWalkthroughViewShowing)
            }
        }
        .transition(.move(edge: .bottom))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
}

struct TutorialSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialSwiftUIView(isWalkthroughViewShowing: Binding.constant(true))
    }
}
