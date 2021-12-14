import SwiftUI

struct AddMedicationSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var remainingQuantity = ""
    @State private var boxQuantity = ""
    @State private var notificationType = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State private var pickerView = true
    @State var showAlert = false
    @EnvironmentObject var medicationManager: MedicationManager    
    
    var body: some View {
        NavigationView {
            RegistrationComponents(name: $name, remainingQuantity: $remainingQuantity, boxQuantity: $boxQuantity, notificationType: $notificationType, date: $date, repeatPeriod: $repeatPeriod, notes: $notes, pickerView: $pickerView)
            .navigationBarTitle("Novo Medicamento")
            .toolbar {
                ToolbarItem {
                    Button("Salvar", action: {
                        if addMedication() == .sucess {
                            showAlert = false
                            dismiss()
                        } else {
                            showAlert = true
                            dismiss()
                        }
                        
                    })
                    .alert(isPresented: $showAlert, content: {
                        let alert = Alert(title: Text("Erro na criação do medicamento"), message: Text("Cadastre novamente"), dismissButton: Alert.Button.default(Text("OK")))
                        return alert
                    })
                    .keyboardShortcut("s")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar", action: {
                        dismiss()
                    })
                }
            }
            }
        }
    
    private func addMedication() -> medicationResult {
        withAnimation {
            let remainingQuantity = Int32(remainingQuantity) ?? 0
            let boxQuantity = Int32(boxQuantity) ?? 0
            var situation: medicationResult = .sucess
            situation = medicationManager.addMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType)
            return situation
        }
    }
}


struct AddEditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationSwiftUIView().environmentObject(MedicationManager())
    }
}
