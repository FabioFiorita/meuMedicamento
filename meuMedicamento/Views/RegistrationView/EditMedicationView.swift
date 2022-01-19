import SwiftUI

struct EditMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var medication: Medication
    @State private var name: String
    @State private var remainingQuantity: String
    @State private var boxQuantity: String
    @State private var notificationType: String
    @State private var date: Date
    @State private var repeatPeriod: String
    @State private var notes: String
    @State var showAlert = false
    @EnvironmentObject var medicationManager: MedicationManager
    
    init(medication: Medication) {
        self.medication = medication
        _name = State(initialValue: medication.name ?? "")
        _remainingQuantity = State(initialValue: String(medication.remainingQuantity))
        _boxQuantity = State(initialValue: String(medication.boxQuantity))
        _notificationType = State(initialValue: medication.notificationType ?? "Regularmente")
        _date = State(initialValue: medication.date ?? Date())
        _repeatPeriod = State(initialValue: medication.repeatPeriod ?? "Nunca")
        _notes = State(initialValue: medication.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            RegistrationComponents(name: $name, remainingQuantity: $remainingQuantity, boxQuantity: $boxQuantity, notificationType: $notificationType, date: $date, repeatPeriod: $repeatPeriod, notes: $notes)
            .navigationBarTitle(LocalizedStringKey("Editar Medicamento"))
            .toolbar(content: {
                ToolbarItem {
                    Button(LocalizedStringKey("Salvar"), action: {
                        if editMedication(medication: medication) == .sucess {
                            dismiss()
                            showAlert = false
                        } else {
                            showAlert = true
                            dismiss()
                        }
                        
                    })
                    .alert(isPresented: $showAlert, content: {
                        let alert = Alert(title: Text(LocalizedStringKey("Erro na edição do medicamento")), message: Text(LocalizedStringKey("Cadastre novamente")), dismissButton: Alert.Button.default(Text(LocalizedStringKey("OK"))))
                        return alert
                    })
                    .keyboardShortcut("s")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("Cancelar"), action: {
                        dismiss()
                    })
                }
            })
        }
    }
    
    
    
    private func editMedication(medication: Medication) -> medicationResult {
        withAnimation {
            let remainingQuantity = Int32(remainingQuantity) ?? 1
            let boxQuantity = Int32(boxQuantity) ?? 0
            var situation: medicationResult = .sucess
            situation = medicationManager.editMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType, medication: medication)
            return situation
        }
    }
    
}


struct EditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        EditMedicationView(medication: Medication())
            .environmentObject(MedicationManager())
    }
}
