import SwiftUI

struct LandmarkListView: View {
    
    let landmarks: [LandmarkViewModel]
    
    var body: some View {
        List(landmarks, id: \.id) { landmark in
            VStack(alignment: .leading, spacing: 10) {
                Text(landmark.name)
                    .font(.headline)
                Text(landmark.title)
            }.onTapGesture(perform: {
                guard let url = URL(string:"http://maps.apple.com/?daddr=\(landmark.coordinate.latitude),\(landmark.coordinate.longitude)") else { return }
                UIApplication.shared.open(url)
            })
        }
    }
}
