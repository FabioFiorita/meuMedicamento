import SwiftUI

struct MedicationDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showModal = false
    @ObservedObject var medication: Medication
    @State private var historicCount = 7
    @ObservedObject var medicationManager: MedicationManager
    @State private var dates: [Date] = []
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack {
                        medicationNextDates(forMedication: medication)
                        medicationInformation(forMedication: medication)
                        medicationNotes(forMedication: medication)
                        Spacer()
                    }
                .padding()
                .onAppear {
                    dates = medicationManager.nextDates(forMedication: medication)
                }
                .navigationTitle(("\(medication.name ?? "Medication")"))
                .toolbar(content: {
                    Button(action: {
                        self.showModal = true
                    }) {
                        Text(LocalizedStringKey("Editar"))
                    }.sheet(isPresented: self.$showModal) {
                        EditMedicationView(medication: medication)
                    }
                    .keyboardShortcut("e")
                })
            .environmentObject(medicationManager)
            }
        }
    }
    
    private func medicationInformation(forMedication medication: Medication) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10.0) {
                    Label(LocalizedStringKey("Detalhes"), systemImage: "doc.text")
                        .foregroundColor(Color("AccentColor"))
                        .font(.title3)
                HStack {
                    Text(LocalizedStringKey("Quantidade restante:"))
                    Text(" \(medication.remainingQuantity)")
                }
                HStack {
                    Text(LocalizedStringKey("Quantidade na caixa:"))
                    Text(" \(medication.boxQuantity)")
                }
                HStack {
                    Text(LocalizedStringKey("Modo de Ingestão:"))
                    Text(LocalizedStringKey(" \(medication.notificationType ?? "")"))
                }
                Group {
                    if medication.repeatPeriod != "Nunca" {
                        HStack {
                            Text(LocalizedStringKey("Repetição: A Cada"))
                            Text(LocalizedStringKey(" \(medication.repeatPeriod ?? "")"))
                        }
                    }
                }
                Button(action: {
                    medicationManager.refreshRemainingQuantity(medication: medication)
                    dismiss()
                }) {
                    Text(LocalizedStringKey("Renovar Medicamentos"))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("AccentColor"))
                        .cornerRadius(10.0)
                        .foregroundColor(.white)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
    private func medicationNotes(forMedication medication: Medication) -> some View {
        Group {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10.0){
                            Label(LocalizedStringKey("Notas"), systemImage: "note.text")
                                .foregroundColor(Color("AccentColor"))
                                .font(.title3)
                        Text("\(medication.notes ?? "")")
                            .padding()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .groupBoxStyle(PrimaryGroupBoxStyle())
        }
    }
    
    private func medicationNextDates(forMedication medication: Medication) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10.0) {
                    Label(LocalizedStringKey("Próximos Medicamentos"), systemImage: "calendar")
                        .foregroundColor(Color("AccentColor"))
                        .font(.title3)
                ForEach(dates, id: \.self){ date in
                        Text("\(date, formatter: itemFormatter)")
                    }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
}


struct MedicationDetailSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationDetailView(medication: Medication(), medicationManager: MedicationManager())
    }
}
