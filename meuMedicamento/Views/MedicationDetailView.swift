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
                .navigationTitle(("\(medication.name ?? "Medicamento")"))
                .toolbar(content: {
                    Button(action: {
                        self.showModal = true
                    }) {
                        Text("Editar")
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
                    Label("Detalhes", systemImage: "doc.text")
                        .foregroundColor(Color("main"))
                        .font(.title3)
                        .accessibilityHidden(true)
                Text("Quantidade restantes: \(medication.remainingQuantity)")
                Text("Quantidade na caixa: \(medication.boxQuantity)")
                Text("Modo de Ingestão: \(medication.notificationType ?? "")")
                Group {
                    if medication.repeatPeriod != "Nunca" {
                        Text("Repetição: A Cada \(medication.repeatPeriod ?? "")")
                    }
                }
                Button(action: {
                    medicationManager.refreshRemainingQuantity(medication: medication)
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
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
    private func medicationNotes(forMedication medication: Medication) -> some View {
        Group {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10.0){
                            Label("Notas", systemImage: "note.text")
                                .foregroundColor(Color("main"))
                                .font(.title3)
                                .accessibilityHidden(true)
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
                    Label("Próximos Medicamentos", systemImage: "calendar")
                        .foregroundColor(Color("main"))
                        .font(.title3)
                        .accessibilityHidden(true)
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
