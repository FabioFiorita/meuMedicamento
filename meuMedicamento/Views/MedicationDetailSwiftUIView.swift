import SwiftUI

struct MedicationDetailSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showModal = false
    @StateObject var medication: Medication
    @State private var historicCount = 7
    @ObservedObject var medicationManager: MedicationManager
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
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
                    Text("Editar")
                }.sheet(isPresented: self.$showModal) {
                    EditMedicationSwiftUIView(medication: medication)
                }
            })
        .environmentObject(medicationManager)
        }
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
        .groupBoxStyle(PrimaryGroupBoxStyle())
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
                .groupBoxStyle(PrimaryGroupBoxStyle())
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
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green).accessibility(label: Text("Sem atraso"))
                    case "Atrasado":
                        Image(systemName: "clock.fill").foregroundColor(.yellow).accessibility(label: Text("Atrasado"))
                    case "Não tomou":
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red).accessibility(label: Text("Não tomou"))
                    default:
                        Image(systemName: "questionmark").foregroundColor(.red).accessibility(label: Text("Situação não encontrada"))
                    }
                }
            }
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
    private var stepperHistory : some View {
        GroupBox {
            HStack {
                Text("Histórico dos últimos ") + Text("\(historicCount)").bold().foregroundColor(.orange) + Text(" medicamentos")
                Spacer()
                Stepper("Quantidade no Histórico", value: $historicCount, in: 0...31)
                    .labelsHidden()
                    .accessibility(identifier: "stepper")
            }.frame(minWidth: 0, maxWidth: .infinity)
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
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
