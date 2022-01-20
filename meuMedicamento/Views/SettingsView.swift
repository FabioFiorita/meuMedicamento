import SwiftUI
import StoreKit
import EmailComposer

struct SettingsView: View {
    
    @ObservedObject var userSettings: UserSettings
    @State private var showModalTutorial = false
    @Environment(\.openURL) var openURL
    @State private var isOnboardingViewShowing = false
    @State private var limitNotification = true
    @State private var limitMedication = 20.0
    @State private var limitDate = Date()
    @State private var didSave = false
    @State private var showEmailComposer = false
    
    var body: some View {
        NavigationView {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                        ScrollView {
                            VStack(alignment: .leading, spacing: 50.0) {
                                medicationAlertSettings
                                links
                                policies
                                Spacer()
                            }
                        }
                    .padding()
                }
                .navigationBarTitle(LocalizedStringKey("Settings"))
        }
        .navigationViewStyle(.stack)
    }
    private var medicationAlertSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10.0) {
                Toggle(isOn: $limitNotification) {
                    Text(LocalizedStringKey("MedicationsRunningOut"))
                }
                .accessibility(identifier: "Toggle")
                HStack {
                    Text(LocalizedStringKey("StartNotifying")) + Text("\(Int(limitMedication))%").foregroundColor(.red).bold() + Text(LocalizedStringKey("FromTotal"))
                    Spacer()
                    Stepper(LocalizedStringKey("PercentageOfTotal"), value: $limitMedication, in: 0.0...100.0)
                        .labelsHidden()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(LocalizedStringKey("AccessibilityLabelStartNotifying"))
                .accessibilityValue(String(limitMedication))
                .accessibilityAdjustableAction { value in
                    switch value {
                    case .increment:
                        limitMedication += 1
                    case .decrement:
                        limitMedication -= 1
                    default:
                        print("Não utilizado")
                    }
                }
                
                HStack {
                    Text(LocalizedStringKey("NotificationTime"))
                    Spacer()
                    DatePicker(LocalizedStringKey("TimeSelector"), selection: $limitDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .accessibilityElement(children: .combine)
                Button(action: {
                    userSettings.limitNotification = limitNotification
                    userSettings.limitMedication = limitMedication
                    userSettings.limitDate = limitDate
                    didSave = true
                }) {
                    Text(LocalizedStringKey("SaveSettings"))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("AccentColor"))
                        .cornerRadius(10.0)
                        .foregroundColor(.white)
                }
                .alert(isPresented: $didSave, content: {
                    Alert(title: Text(LocalizedStringKey("SettingsAlertTitle")), message: nil, dismissButton: .cancel(Text(LocalizedStringKey("OK"))))
                })
            }
            .onAppear {
                self.limitNotification = self.userSettings.limitNotification
                self.limitMedication = self.userSettings.limitMedication
                self.limitDate = self.userSettings.limitDate
            }
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
    private var links: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 15.0) {
                Button(action: {
                    if userSettings.reviewCount <= 3 {
                        if let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                            userSettings.reviewCount += 1
                        } else {
                            print("Review Error")
                        }
                    } else {
                        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1580757092?action=write-review")
                        else {
                            fatalError("Expected a valid URL")
                        }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                        userSettings.reviewCount += 1
                    }
                }) {
                    Text(LocalizedStringKey("Rate"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                        .accessibilityHidden(true)
                }
                Divider()
                Button(action: {
                    openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento")!)
                }) {
                    Text(LocalizedStringKey("AboutUs"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                        .accessibilityHidden(true)
                }
                Divider()
                Button(action: {
                    showEmailComposer = true
                }) {
                    Text(LocalizedStringKey("ContactUs"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                        .accessibilityHidden(true)
                }
                .emailComposer(isPresented: $showEmailComposer, emailData: EmailData(recipients: ["fabiolfp@gmail.com"]), result:  { result in
                    print("Email sucess")
                })
            }
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
        .foregroundColor(.primary)
    }
    
    private var policies: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 15.0) {
                Button(action: {
                    openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento/Terms&Conditions.html")!)
                }) {
                    Text(LocalizedStringKey("TermsOfUsafe"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                        .accessibilityHidden(true)
                }
                Divider()
                Button(action: {
                    openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento/privacyPolicy.html")!)
                }, label: {
                    Text(LocalizedStringKey("PrivacyPolicy"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                        .accessibilityHidden(true)
                })
            }
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
        .foregroundColor(.primary)
    }
}


struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userSettings: UserSettings())
    }
}
