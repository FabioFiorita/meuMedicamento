import SwiftUI


struct ContentView: View {
    @State private var showModalAdd = false
    @State private var showModalEdit = false
    @State private var showTimeIntervalAlert = false
    @State private var authorizationDenied = false
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var delegate = NotificationDelegate()
    @ObservedObject var userSettings = UserSettings()
    @StateObject private var medicationManager = MedicationManager()
    @AppStorage("TutorialView") var isWalkthroughViewShowing = true
    
    init(){
        let coloredNavAppearance = UINavigationBarAppearance()
        //coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor(Color("main"))
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if isWalkthroughViewShowing {
                TutorialSwiftUIView(isWalkthroughViewShowing: $isWalkthroughViewShowing)
            } else {
                TabView {
                    NavigationView {
                        List {
                            ForEach(medicationManager.savedMedications, id: \.self) { (medication: Medication) in
                                row(forMedication: medication)
                            }
                            .onDelete(perform: deleteMedication)
                        }
                        .navigationBarTitle("Medicamentos",displayMode: .inline)
                        .toolbar(content: {
                            ToolbarItem {
                                Button {
                                    self.showModalAdd = true
                                } label: {
                                    Image(systemName: "plus").imageScale(.large).foregroundColor(.white)
                                }.sheet(isPresented: $showModalAdd, onDismiss: medicationManager.fetchMedications) {
                                    AddMedicationSwiftUIView()
                                }
                            }
                        })
                        .listStyle(InsetGroupedListStyle())
                        .onAppear(perform: {
                            notificationManager.reloadAuthorizationStatus()
                            UNUserNotificationCenter.current().delegate = delegate
                            medicationManager.fetchMedications()
                        })
                        .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
                            switch authorizationStatus {
                            case .notDetermined:
                                notificationManager.requestAuthorization()
                            case .authorized:
                                notificationManager.reloadLocalNotifications()
                            case .denied:
                                self.authorizationDenied = true
                            default:
                                break
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                            notificationManager.reloadAuthorizationStatus()
                        }
                        .alert("Notificações desativadas", isPresented: $authorizationDenied, actions: {
                            Button("Cancelar", role: .cancel) { }
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            } label: {
                                Text("Abrir Ajustes")
                            }
                        }, message: {
                            Text("Abra o App Ajustes e habilite as notificações para monitorar seus medicamentos")
                        })
                    }
                    .accentColor(.white)
                    .tabItem {
                        Image(systemName: "pills")
                        Text("Medicamentos")
                    }
                    MapSwiftUIView()
                        .tabItem {
                            Image(systemName: "map")
                            Text("Mapa")
                        }
                    SettingsSwiftUIView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Ajustes")
                        }
                }
                .accentColor(Color("main"))
            }
        }
    }
    
    
    private func deleteMedication(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let medication = medicationManager.savedMedications[index]
                medicationManager.deleteMedication(medication: medication)
            }
        }
    }
    
    
    private func updateQuantity(medication: FetchedResults<Medication>.Element) {
        withAnimation {
            if !medicationManager.updateRemainingQuantity(medication: medication) {
                showTimeIntervalAlert = true
            }
        }
    }
    
    private func checkmark(forMedication medication: Medication) -> some View {
        Image(systemName: "checkmark.circle").font(.system(size: 35, weight: .regular))
            .foregroundColor(medication.isSelected ? Color.green : Color.primary)
            .onTapGesture {
                updateQuantity(medication: medication)
                withAnimation(.easeInOut(duration: 2.0)) {
                    medication.isSelected = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 2)) {
                        medication.isSelected = false
                        medicationManager.fetchMedications()
                    }
                }
            }
            .alert("Erro na hora de agendar a notificação", isPresented: $showTimeIntervalAlert, actions: {
                Button {
                    self.showModalEdit = true
                } label: {
                    Text("Editar Medicamento")
                }
                Button("Cancelar", role: .cancel) { }
            }, message: {
                Text("Configure a data de início novamente")
            })
            .sheet(isPresented: $showModalEdit, onDismiss: medicationManager.fetchMedications, content: {
                EditMedicationSwiftUIView(medication: medication)
            })
        
    }
    private func medicationName(forMedication medication: Medication) -> some View {
        Text(medication.name ?? "Untitled").font(.title)
    }
    private func medicationRemainingQuantity(forMedication medication: Medication) -> some View {
        Group {
            Text("Medicamentos restantes:")
                .font(.body)
                .fontWeight(.light)
            if Double(medication.remainingQuantity) <= Double(medication.boxQuantity) * (userSettings.limitMedication/100.0) {
                Text("\(medication.remainingQuantity)")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(.red)
            } else {
                Text("\(medication.remainingQuantity)")
                    .font(.body)
                    .fontWeight(.light)
            }
        }
    }
    private func medicationDate(forMedication medication: Medication) -> some View {
        Group {
            if medication.date?.timeIntervalSinceNow ?? Date().timeIntervalSinceNow < 0 {
                Text("Proximo: ") +
                    Text("\(medication.date ?? Date() ,formatter: itemFormatter)")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.red)
            } else {
                Text("Proximo: \(medication.date ?? Date() ,formatter: itemFormatter)")
                    .font(.body)
                    .fontWeight(.light)
            }
        }
    }
    
    private func row(forMedication medication: Medication) -> some View {
        HStack {
            HStack {
                checkmark(forMedication: medication)
                VStack(alignment: .leading, spacing: 5) {
                    medicationName(forMedication: medication)
                    HStack {
                        medicationRemainingQuantity(forMedication: medication)
                    }
                    medicationDate(forMedication: medication)
                }
            }
            Spacer()
            NavigationLink(destination: MedicationDetailSwiftUIView(medication: medication)) {
                EmptyView()
            }.frame(width: 0, height: 0)
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt-BR")
        return formatter
    }()
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
