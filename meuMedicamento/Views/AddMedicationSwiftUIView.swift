import SwiftUI
import NotificationCenter



struct AddMedicationSwiftUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
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
                    TextEditor(text: $notes).padding()
                }
            }
            .navigationBarTitle(Text("Novo Medicamento"),displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("Cancelar", action: {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }).foregroundColor(.white)
                                , trailing:
                                    Button("Salvar", action: {
                                        if addMedication() {
                                            self.presentationMode.wrappedValue.dismiss()
                                            showAlert = false
                                        } else {
                                            showAlert = true
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                        
                                    }).foregroundColor(.white)
                                    .alert(isPresented: $showAlert, content: {
                                        let alert = Alert(title: Text("Erro na criação do medicamento"), message: Text("Cadastre novamente"), dismissButton: Alert.Button.default(Text("OK")))
                                        return alert
                                    })
            )
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
            let sucess = medicationManager.addMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType, viewContext: viewContext)
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

