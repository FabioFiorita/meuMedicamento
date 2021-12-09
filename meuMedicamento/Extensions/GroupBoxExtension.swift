import Foundation
import SwiftUI

struct PrimaryGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(Color("GroupBox"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
