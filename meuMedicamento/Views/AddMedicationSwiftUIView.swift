import SwiftUI

struct AddMedicationSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var boxQuantity = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State private var remainingQuantity = ""
    @State private var notificationType = ""
    @State var showAlert = false
    @State private var pickerView = true
    @ObservedObject var userSettings = UserSettings()
    @StateObject private var medicationManager = MedicationManager()
    @State private var showDatePicker = false
    
    
    var body: some View {
        NavigationView{
            Form {
                TextField("Nome do Medicamento", text: $name).disableAutocorrection(true)
                TextField("Quantidade Restante", text: $remainingQuantity).keyboardType(.numberPad)
                TextField("Quantidade na Caixa", text: $boxQuantity).keyboardType(.numberPad)
                Section {
                    notificationTypePicker
                    Group {
                        Text("Data de Início: ") + Text("\(date, formatter: itemFormatter)").foregroundColor(showDatePicker ? .blue : .secondary)
                    }.onTapGesture(perform: {
                        self.dismissKeyboard()
                        showDatePicker.toggle()
                    })
                    if showDatePicker {
                        DatePicker("", selection: $date, in: Date()...).datePickerStyle(GraphicalDatePickerStyle())
                    }
                    Picker(selection: $repeatPeriod, label: Text("Repetir")) {
                        ForEach(RepeatPeriod.periods, id: \.self) { periods in
                            Text(periods).tag(periods)
                        }
                    }
                    .onAppear {
                        pickerView = false
                    }
                }
                Section{
                    Text("Notas")
                    TextField("",text: $notes).padding()
                }
            }
            .navigationBarTitle("Novo Medicamento",displayMode: .inline)
            .toolbar(content: {
                ToolbarItem {
                    Button("Salvar", action: {
                        if addMedication() {
                            showAlert = false
                            dismiss()
                        } else {
                            showAlert = true
                            dismiss()
                        }
                        
                    }).foregroundColor(.white)
                    .alert(isPresented: $showAlert, content: {
                        let alert = Alert(title: Text("Erro na criação do medicamento"), message: Text("Cadastre novamente"), dismissButton: Alert.Button.default(Text("OK")))
                        return alert
                    })
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar", action: {
                        dismiss()
                    }).foregroundColor(.white)
                }
            })
        }
    }
    
    private var notificationTypePicker: some View {
        Group {
            Picker(selection: $notificationType, label: Text("Tipo de Notificação")) {
                ForEach(NotificationType.type, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onAppear {
                if pickerView {
                    notificationType = "Após Conclusão"
                }
            }
            if notificationType == "Regularmente" {
                Text("O próximo medicamento será agendando seguindo a data definida")
            } else {
                Text("O próximo medicamento será agendando seguindo a data da última conclusão")
            }
        }
        
    }
    
    private func addMedication() -> Bool {
        withAnimation {
            let remainingQuantity = Int32(remainingQuantity) ?? 0
            let boxQuantity = Int32(boxQuantity) ?? 0
            let sucess = medicationManager.addMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType)
            return sucess
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







struct AddEditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationSwiftUIView()
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
