import SwiftUI

struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var remainingQuantity = ""
    @State private var boxQuantity = ""
    @State private var notificationType = "Após Conclusão"
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State var showAlert = false
    @EnvironmentObject var medicationManager: MedicationManager    
    
    var body: some View {
        NavigationView {
            RegistrationComponents(name: $name, remainingQuantity: $remainingQuantity, boxQuantity: $boxQuantity, notificationType: $notificationType, date: $date, repeatPeriod: $repeatPeriod, notes: $notes)
            .navigationBarTitle(LocalizedStringKey("NewMedication"))
            .toolbar {
                ToolbarItem {
                    Button(LocalizedStringKey("Save"), action: {
                        if addMedication() == .sucess {
                            showAlert = false
                            dismiss()
                        } else {
                            showAlert = true
                            dismiss()
                        }
                        
                    })
                    .alert(isPresented: $showAlert, content: {
                        let alert = Alert(title: Text(LocalizedStringKey("CreationMedicationAlertTitle")), message: Text(LocalizedStringKey("CreationMedicationAlertBody")), dismissButton: Alert.Button.default(Text(LocalizedStringKey("OK"))))
                        return alert
                    })
                    .keyboardShortcut("s")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("Cancel"), action: {
                        dismiss()
                    })
                }
            }
            }
        }
    
    private func addMedication() -> medicationResult {
        withAnimation {
            let remainingQuantity = Int32(remainingQuantity) ?? 1
            let boxQuantity = Int32(boxQuantity) ?? 0
            var situation: medicationResult = .sucess
            situation = medicationManager.addMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType)
            return situation
        }
    }
}


struct AddEditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationView().environmentObject(MedicationManager())
    }
}
