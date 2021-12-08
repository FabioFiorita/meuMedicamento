import SwiftUI
import StoreKit
import EmailComposer

struct SettingsSwiftUIView: View {
    
    @ObservedObject var userSettings = UserSettings()
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 50.0) {
                        medicationAlertSettings
                        links
                        policies
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitle("Ajustes")
                }
        }
    }
    private var medicationAlertSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10.0) {
                Toggle(isOn: $limitNotification) {
                    Text("Deseja ser notificado quando estiver acabando seus remédios?")
                }
                    .accessibility(identifier: "Toggle")
                HStack {
                    Text("Começar a notificar quando a quantidade chegar em: ") + Text("\(Int(limitMedication))%").foregroundColor(.red).bold() + Text(" do total")
                    Spacer()
                    Stepper("Porcentagem do Total", value: $limitMedication, in: 0.0...100.0)
                        .labelsHidden()
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Text("Horario para as notificações:")
                    Spacer()
                    DatePicker("Seletor de Horário", selection: $limitDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .accessibilityElement(children: .combine)
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
                    Text("Avalie!")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                }
                Divider()
                Button(action: {
                    openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento")!)
                }) {
                    Text("Sobre-nós")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                }
                Divider()
                Button(action: {
                    showEmailComposer = true
                }) {
                    Text("Fale Conosco")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                }
                .emailComposer(isPresented: $showEmailComposer, emailData: EmailData(recipients: ["fabiolfp@gmail.com"]), result:  { result in
                    print("Email sucess")
                })
            }
        }
        .foregroundColor(.primary)
    }
    
    private var policies: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 15.0) {
                Button(action: {
                    openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento/Terms&Conditions.html")!)
                }) {
                    Text("Termos de Uso")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                }
                Divider()
                Button(action: {
                    openURL(URL(string: "https://fabiofiorita.github.io/meuMedicamento/privacyPolicy.html")!)
                }, label: {
                    Text("Política de Privacidade")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.secondary)
                })
            }
        }
        .foregroundColor(.primary)
    }
}


struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView()
    }
}
