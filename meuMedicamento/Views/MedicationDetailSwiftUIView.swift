import SwiftUI

struct MedicationDetailSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showModal = false
    @StateObject var medication: Medication
    @State private var historicCount = 7
    @ObservedObject var medicationManager: MedicationManager
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                medicationInformation(forMedication: medication)
                medicationNotes(forMedication: medication)
                stepperHistory
                ScrollView {
                    ForEach(medicationManager.fetchHistoric(forMedication: medication).prefix(historicCount) , id: \.self){ historic in
                        medicationDateHistory(forHistoric: historic)
                    }
                }
            }.padding()
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
        .environmentObject(medicationManager)
    }
    
    private func medicationInformation(forMedication medication: Medication) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 5.0) {
                Text("Medicamentos restantes: \(medication.remainingQuantity)")
                Text("Quantidade de medicamentos na caixa: \(medication.boxQuantity)")
                Button(action: {
                    refreshQuantity(medication)
                    dismiss()
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
    }
    
    private func medicationNotes(forMedication medication: Medication) -> some View {
        Group {
            if medication.notes != "" {
                GroupBox {
                    VStack(alignment: .leading, spacing: 5.0){
                        Text("Notas").font(.title2)
                        Text("\(medication.notes ?? "")").frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func medicationDateHistory(forHistoric historic: Historic) -> some View {
        GroupBox {
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
        GroupBox {
            Stepper(value: $historicCount, in: 0...31) {
                Text("Histórico dos últimos ") + Text("\(historicCount)").bold().foregroundColor(.orange) + Text(" medicamentos")
            }
        }
        
    }
    
    private func refreshQuantity(_ medication: FetchedResults<Medication>.Element) {
        withAnimation {
            
            medicationManager.refreshRemainingQuantity(medication: medication)
        }
    }
    
}


struct MedicationDetailSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationDetailSwiftUIView(medication: Medication(), medicationManager: MedicationManager())
    }
}
