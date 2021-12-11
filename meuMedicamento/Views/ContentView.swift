import SwiftUI

struct ContentView: View {
    @State private var showModalAdd = false
    @State private var showModalEdit = false
    @State private var showModalHistory = false
    @State private var showTimeIntervalAlert = false
    @State private var showDeleteAlert = false
    @State private var showViewContextAlert = false
    @State private var authorizationDenied = false
    @State private var searchMedication = ""
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var delegate = NotificationDelegate()
    @ObservedObject var userSettings = UserSettings()
    @StateObject private var medicationManager = MedicationManager()
    @AppStorage("OnboardingView") var isOnboardingViewShowing = true
    
    
    var body: some View {
        Group {
            if isOnboardingViewShowing {
                OnboardingView(isOnboardingViewShowing: $isOnboardingViewShowing)
            } else {
                TabView {
                    NavigationView {
                            List {
                                Section {
                                    ForEach(searchResults, id: \.self) { medication in
                                        if medicationManager.checkMedicationDate(forMedication: medication) == .today {
                                            sections(forMedication: medication)
                                        }
                                    }
                                } header: {
                                    Text("Hoje")
                                }
                                Section {
                                    ForEach(searchResults, id: \.self) { medication in
                                        if medicationManager.checkMedicationDate(forMedication: medication) == .next {
                                            sections(forMedication: medication)
                                        }
                                    }
                                } header: {
                                    Text("Próximos")
                                }

                            }
                            .refreshable {
                                medicationManager.fetchMedications()
                            }
                            .navigationBarTitle("Medicamentos",displayMode: .automatic)
                            .searchable(text: $searchMedication)
                            .listStyle(.insetGrouped)
                            .toolbar(content: {
                                ToolbarItem {
                                    Button {
                                        self.showModalAdd = true
                                    } label: {
                                        Image(systemName: "plus").imageScale(.large).accessibility(label: Text("Adicionar novo medicamento"))
                                    }.sheet(isPresented: $showModalAdd, onDismiss: medicationManager.fetchMedications) {
                                        AddMedicationSwiftUIView()
                                    }
                                }
                            })
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
                        .environmentObject(medicationManager)
                    }
                    .tabItem {
                        Image(systemName: "pills")
                        Text("Medicamentos")
                    }.badge(medicationManager.calculateLateMedications())
                    HistoricSwiftUIView(medicationManager: medicationManager)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Histórico")
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
            }
        }
    }
    
    var searchResults: [Medication] {
        if searchMedication.isEmpty {
            return medicationManager.savedMedications
        } else {
            return medicationManager.savedMedications.filter(
                {
                    if let name = $0.name {
                        return name.contains(searchMedication)
                    } else {
                        return false
                    }
                })
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
            switch medicationManager.updateRemainingQuantity(medication: medication) {
            case .notificationTimeIntervalError:
                showTimeIntervalAlert = true
            case .viewContextError:
                showViewContextAlert = true
            case .sucess:
                print("updateQuantity Sucess!")
            default:
                break
            }
        }
    }
    
    private func sections(forMedication medication: Medication) -> some View {
        HStack {
            checkmark(forMedication: medication)
            NavigationLink(destination: MedicationDetailSwiftUIView(medication: medication, medicationManager: medicationManager)) {
                row(forMedication: medication)
            }
            .contextMenu(menuItems: {
                Button {
                    updateQuantity(medication: medication)
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Tomar Medicamento")
                    }.accessibilityElement(children: .combine)
                }
                Button {
                    medicationManager.refreshRemainingQuantity(medication: medication)
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Renovar Quantidade")
                    }.accessibilityElement(children: .combine)
                }
                Button {
                    showModalHistory = true
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Ver Histórico")
                    }.accessibilityElement(children: .combine)
                }
            })
            .sheet(isPresented: $showModalHistory, onDismiss: {
                medicationManager.fetchMedications()
            }, content: {
                MedicationHistoricSwiftUIView(medicationManager: medicationManager, medication: medication)
            })
        }
        .swipeActions(edge: .trailing ,allowsFullSwipe: false) {
            Button("Apagar", role: .destructive) {
                medicationManager.deleteMedication(medication: medication)
            }
        }
    }
    
    private func checkmark(forMedication medication: Medication) -> some View {
        Button {
            updateQuantity(medication: medication)
            if medication.remainingQuantity >= 1 {
                medication.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        medication.isSelected = false
                        medicationManager.fetchMedications()
                    }
                }
            }
            medicationManager.fetchMedications()
        } label: {
            Image(systemName: "checkmark.circle").font(.system(size: 35, weight: .regular)).accessibility(label: Text("Tomar Medicamento"))
                .foregroundColor(medication.isSelected ? Color.green : Color.primary)
        }
        .buttonStyle(.plain)
        .alert("Erro na hora de agendar a notificação", isPresented: $showTimeIntervalAlert) {
            Button {
                self.showModalEdit = true
            } label: {
                Text("Editar Medicamento")
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Configure a data de início novamente")
        }
        .sheet(isPresented: $showModalEdit, onDismiss: medicationManager.fetchMedications, content: {
            EditMedicationSwiftUIView(medication: medication)
        })
        .alert("Erro na hora de cadastrar o medicamento", isPresented: $showViewContextAlert) {
            Button("OK",role: .destructive) { }
        } message: {
            Text("Reinicie o aplicativo")
        }
                        
        
    }
    private func medicationName(forMedication medication: Medication) -> some View {
        Text(medication.name ?? "Untitled").font(.title)
    }
    private func medicationRemainingQuantity(forMedication medication: Medication) -> some View {
        Group {
            HStack {
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
                VStack(alignment: .leading, spacing: 5) {
                    medicationName(forMedication: medication)
                    medicationRemainingQuantity(forMedication: medication)
                    medicationDate(forMedication: medication)
                }
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
