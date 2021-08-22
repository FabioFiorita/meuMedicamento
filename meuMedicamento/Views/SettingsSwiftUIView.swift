import SwiftUI
import StoreKit

struct SettingsSwiftUIView: View {
    
    @ObservedObject var userSettings = UserSettings()
    @State private var showModalTutorial = false
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @State private var isWalkthroughViewShowing = false
    @State private var limitNotification = true
    @State private var limitMedication = 20.0
    @State private var limitDate = Date()
    @State private var didSave = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(colorScheme == .dark ? .systemBackground : .systemGray6)
                ScrollView {
                    VStack(alignment: .leading, spacing: 50.0) {
                        VStack(alignment: .leading, spacing: 5.0) {
                            medicationAlertSettings
                        }
                        .padding()
                        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
                        .cornerRadius(10.0)
                        links
                        policies
                        Spacer()
                    }
                    .navigationBarTitle("Ajustes")
                    .padding()
                    .cornerRadius(10.0)
                }
            }
        }
    }
    private var medicationAlertSettings: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Toggle(isOn: $limitNotification) {
                Text("Deseja ser notificado quando estiver acabando seus remédios?")
            }
            Stepper(value: $limitMedication, in: 0.0...100.0) {
                Text("Começar a notificar quando a quantidade chegar em: ") + Text("\(Int(limitMedication))%").foregroundColor(.red).bold() + Text(" do total")
            }
            DatePicker("Horario para as notificações:", selection: $limitDate, displayedComponents: .hourAndMinute)
            Button(action: {
                userSettings.limitNotification = limitNotification
                userSettings.limitMedication = limitMedication
                userSettings.limitDate = limitDate
                didSave = true
            }) {
                Text("Salvar Configurações")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color("main"))
                    .cornerRadius(10.0)
                    .foregroundColor(.white)
            }
            .alert(isPresented: $didSave, content: {
                Alert(title: Text("Configurações atualizadas com sucesso"), message: nil, dismissButton: .cancel(Text("OK")))
            })
        }
        .onAppear {
            self.limitNotification = self.userSettings.limitNotification
            self.limitMedication = self.userSettings.limitMedication
            self.limitDate = self.userSettings.limitDate
        }
    }
    
    private var links: some View {
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
                Text("Avalie!")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            Divider()
            HStack {
                NavigationLink("Tutorial", destination: TutorialSwiftUIView(isWalkthroughViewShowing: $isWalkthroughViewShowing))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
                
                
            }
            Divider()
            Button(action: {
                openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento")!)
            }) {
                Text("Sobre-nós")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            Divider()
            Button(action: {
                EmailHelper.shared.sendEmail(subject: "", body: "", to: "fabiolfp@gmail.com")
            }) {
                Text("Fale Conosco")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            
            
            
        }
        .padding()
        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
        .cornerRadius(10.0)
    }
    private var policies: some View {
        VStack(alignment: .leading, spacing: 15.0) {
            Button(action: {
                openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento/Terms&Conditions.html")!)
            }) {
                Text("Termos de Uso")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            Divider()
            Button(action: {
                openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento/privacyPolicy.html")!)
            }, label: {
                Text("Política de Privacidade")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            })
        }
        .padding()
        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
        .cornerRadius(10.0)
    }
}


struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView()
    }
}
