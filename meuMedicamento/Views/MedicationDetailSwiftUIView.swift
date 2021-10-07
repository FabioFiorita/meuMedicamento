import SwiftUI
import CoreData

struct MedicationDetailSwiftUIView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var showModal = false
    let medication: Medication
    @State private var historicCount = 7
    @StateObject private var medicationManager = MedicationManager()
    
    var body: some View {
            ZStack {
                Color(colorScheme == .dark ? .systemBackground : .systemGray6)
                VStack(alignment: .leading) {
                    VStack {
                        medicationInformation(forMedication: medication)
                        medicationNotes(forMedication: medication)
                        stepperHistory
                    }.padding()
                    List {
                        ForEach(medicationManager.fetchHistoric(forMedication: medication).prefix(historicCount) , id: \.self){ historic in
                            medicationDateHistory(forHistoric: historic)
                        }
                    }
                    Spacer()
                }
                
            }
        .navigationTitle(("\(medication.name ?? "Medicamento")"))
        .toolbar(content: {
            Button(action: {
                self.showModal = true
            }) {
                Text("Editar").foregroundColor(.white)
            }.sheet(isPresented: self.$showModal) {
                EditMedicationSwiftUIView(medication: medication)
            }
        })
    }
    
    private func medicationInformation(forMedication medication: Medication) -> some View {
        VStack(alignment: .leading, spacing: 5.0) {
            Group {
                Text("Medicamentos restantes: \(medication.remainingQuantity)")
                Text("Quantidade de medicamentos na caixa: \(medication.boxQuantity)")
                Button(action: {
                    refreshQuantity(medication)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Renovar Medicamentos")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("main"))
                        .cornerRadius(10.0)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
        .cornerRadius(10.0)
    }
    
    private func medicationNotes(forMedication medication: Medication) -> some View {
        Group {
            if medication.notes != "" {
                VStack(alignment: .leading, spacing: 5.0){
                    Text("Notas").font(.title2)
                    Text("\(medication.notes ?? "")").frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .padding()
                }.padding()
                .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
                .cornerRadius(10.0)
            }
        }
    }
    
    private func medicationDateHistory(forHistoric historic: Historic) -> some View {
        Group {
            HStack {
                Text("\(historic.dates ?? Date(),formatter: itemFormatter)" )
                Spacer()
                Group {
                    switch historic.medicationStatus {
                    case "Sem Atraso":
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    case "Atrasado":
                        Image(systemName: "clock.fill").foregroundColor(.yellow)
                    case "Não tomou":
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                    default:
                        Image(systemName: "questionmark").foregroundColor(.red)
                    }
                }
                
            }
        }
    }
    
    private var stepperHistory : some View {
            Stepper(value: $historicCount, in: 0...31) {
                Text("Histórico dos últimos ") + Text("\(historicCount)").bold().foregroundColor(.orange) + Text(" medicamentos")
            }
            .padding()
            .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
            .cornerRadius(10.0)
        
    }
    
    private func refreshQuantity(_ medication: FetchedResults<Medication>.Element) {
        withAnimation {
            
            medicationManager.refreshRemainingQuantity(medication: medication)
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "pt-BR")
    return formatter
}()


struct MedicationDetailSwiftUIView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let medication = Medication(context: moc)
        
        return NavigationView {
            MedicationDetailSwiftUIView(medication: medication)
        }
    }
}
