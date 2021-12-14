import SwiftUI

struct EditMedicationSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var medication: Medication
    @State private var name = ""
    @State private var remainingQuantity = ""
    @State private var boxQuantity = ""
    @State private var notificationType = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State var showAlert = false
    @State private var pickerView = true
    @EnvironmentObject var medicationManager: MedicationManager
    
    var body: some View {
        NavigationView {
                RegistrationComponents(name: $name, remainingQuantity: $remainingQuantity, boxQuantity: $boxQuantity, notificationType: $notificationType, date: $date, repeatPeriod: $repeatPeriod, notes: $notes, pickerView: $pickerView)
                .onAppear {
                    if pickerView {
                        self.name = self.medication.name != nil ? "\(self.medication.name!)" : ""
                        self.remainingQuantity = (self.medication.remainingQuantity != 0) ? "\(self.medication.remainingQuantity)" : ""
                        self.boxQuantity = (self.medication.boxQuantity != 0) ? "\(self.medication.boxQuantity)" : ""
                        self.date = self.medication.date ?? Date()
                        self.repeatPeriod = self.medication.repeatPeriod ?? "Nunca"
                        self.notes = self.medication.notes != nil ? "\(self.medication.notes!)" : ""
                    }
                }
            .navigationBarTitle("Editar Medicamento")
            .toolbar(content: {
                ToolbarItem {
                    Button("Salvar", action: {
                        if editMedication(medication: medication) == .sucess {
                            dismiss()
                            showAlert = false
                        } else {
                            showAlert = true
                            dismiss()
                        }
                        
                    })
                    .alert(isPresented: $showAlert, content: {
                        let alert = Alert(title: Text("Erro na edição do medicamento"), message: Text("Cadastre novamente"), dismissButton: Alert.Button.default(Text("OK")))
                        return alert
                    })
                    .keyboardShortcut("s")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar", action: {
                        dismiss()
                    })
                }
            })
        }
    }
    
    
    
    private func editMedication(medication: Medication) -> medicationResult {
        withAnimation {
            let remainingQuantity = Int32(remainingQuantity) ?? 0
            let boxQuantity = Int32(boxQuantity) ?? 0
            var situation: medicationResult = .sucess
            situation = medicationManager.editMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType, medication: medication)
            return situation
        }
    }
    
}


struct EditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        EditMedicationSwiftUIView(medication: Medication()).environmentObject(MedicationManager())
    }
}
