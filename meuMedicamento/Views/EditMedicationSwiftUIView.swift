import SwiftUI
import CoreData


struct EditMedicationSwiftUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    let medication: Medication
    @State private var name = ""
    @State private var boxQuantity = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State private var remainingQuantity = ""
    @State private var notificationType = ""
    @State var showAlert = false
    @State private var pickerView = true
    @StateObject private var medicationManager = MedicationManager()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView{
            Form {
                Group {
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
            }
            .navigationBarTitle("Editar Medicamento",displayMode: .inline)
            .toolbar(content: {
                ToolbarItem {
                    Button("Salvar", action: {
                        if editMedication(medication: medication) {
                            self.presentationMode.wrappedValue.dismiss()
                            showAlert = false
                        } else {
                            showAlert = true
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    }).foregroundColor(.white)
                    .alert(isPresented: $showAlert, content: {
                        let alert = Alert(title: Text("Erro na edição do medicamento"), message: Text("Cadastre novamente"), dismissButton: Alert.Button.default(Text("OK")))
                        return alert
                    })
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar", action: {
                        self.presentationMode.wrappedValue.dismiss()
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
                    notificationType = medication.notificationType ?? "Após Conclusão"
                }
            }
            if notificationType == "Regularmente" {
                Text("O próximo medicamento será agendando seguindo a data definida")
            } else {
                Text("O próximo medicamento será agendando seguindo a data da última conclusão")
            }
        }
        
    }
    
    
    
    private func editMedication(medication: Medication) -> Bool {
        withAnimation {
            let remainingQuantity = Int32(remainingQuantity) ?? 0
            let boxQuantity = Int32(boxQuantity) ?? 0
            let sucess = medicationManager.editMedication(name: name, remainingQuantity: remainingQuantity, boxQuantity: boxQuantity, date: date, repeatPeriod: repeatPeriod, notes: notes, notificationType: notificationType, viewContext: viewContext, medication: medication)
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


struct EditMedicationSwiftUIView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let medication = Medication(context: moc)
        
        return NavigationView {
            EditMedicationSwiftUIView(medication: medication)
        }
        
        
    }
}
