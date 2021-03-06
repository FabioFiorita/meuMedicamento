import SwiftUI

struct ListView: View {
    @State private var showModalAdd = false
    @State private var authorizationDenied = false
    @State private var searchMedication = ""
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var delegate = NotificationDelegate()
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var medicationManager: MedicationManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(searchResults, id: \.self) { medication in
                        if medicationManager.checkMedicationDate(forMedication: medication) == .today {
                            CellView(medication: medication, userSettings: userSettings, medicationManager: medicationManager)
                        }
                    }
                } header: {
                    Text(LocalizedStringKey("Today"))
                }
                Section {
                    ForEach(searchResults, id: \.self) { medication in
                        if medicationManager.checkMedicationDate(forMedication: medication) == .next {
                            CellView(medication: medication, userSettings: userSettings, medicationManager: medicationManager)
                        }
                    }
                } header: {
                    Text(LocalizedStringKey("Upcoming"))
                }
                
            }
            .refreshable {
                medicationManager.fetchMedications()
            }
            .navigationBarTitle(LocalizedStringKey("Medications"),displayMode: .automatic)
            .searchable(text: $searchMedication)
            .listStyle(.insetGrouped)
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        self.showModalAdd = true
                    } label: {
                        Label(LocalizedStringKey("AddNewMedication"), systemImage: "plus")
                    }.sheet(isPresented: $showModalAdd, onDismiss: medicationManager.fetchMedications) {
                        AddMedicationView()
                    }
                    .keyboardShortcut("n")
                }
            })
            .onAppear(perform: {
                medicationManager.fetchMedications()
                notificationManager.reloadAuthorizationStatus()
                UNUserNotificationCenter.current().delegate = delegate
                medicationManager.reloadNotifications()
            })
            .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
                switch authorizationStatus {
                case .notDetermined:
                    notificationManager.requestAuthorization()
                case .authorized:
                    break
                case .denied:
                    self.authorizationDenied = true
                default:
                    break
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                notificationManager.reloadAuthorizationStatus()
            }
            .alert(LocalizedStringKey("DisabledNotifications"), isPresented: $authorizationDenied, actions: {
                Button(LocalizedStringKey("Cancel"), role: .cancel) { }
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedStringKey("OpenSettingsAlertTitle"))
                }
            }, message: {
                Text(LocalizedStringKey("OpenSettingsAlertBody"))
            })
            .environmentObject(medicationManager)
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
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(userSettings: UserSettings(), medicationManager: MedicationManager())
    }
}
