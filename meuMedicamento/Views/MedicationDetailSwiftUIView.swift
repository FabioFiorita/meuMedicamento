import SwiftUI

struct MedicationDetailSwiftUIView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showModal = false
    @StateObject var medication: Medication
    @State private var historicCount = 7
    @ObservedObject var medicationManager: MedicationManager
    @State private var dates: [Date] = []
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading) {
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
                        EditMedicationSwiftUIView(medication: medication)
                    }
                })
            .environmentObject(medicationManager)
            }
        }
    }
    
    private func medicationInformation(forMedication medication: Medication) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10.0) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(Color("main"))
                        .font(.title)
                    Text("Detalhes")
                        .foregroundColor(Color("main"))
                        .font(.title3)
                        .bold()
                }.accessibilityElement(children: .combine)
                Text("Quantidade restantes: \(medication.remainingQuantity)")
                Text("Quantidade na caixa: \(medication.boxQuantity)")
                Text("Modo de Injestão: \(medication.notificationType ?? "modo inderteminado")")
                Group {
                    if medication.repeatPeriod != "Nunca" {
                        Text("Repetição: A Cada \(medication.repeatPeriod ?? "repetição inderteminado")")
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
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
    private func medicationNotes(forMedication medication: Medication) -> some View {
        Group {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10.0){
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(Color("main"))
                                .font(.title)
                            Text("Notas")
                                .foregroundColor(Color("main"))
                                .font(.title3)
                                .bold()
                        }.accessibilityElement(children: .combine)
                        Text("\(medication.notes ?? "")").frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                            .padding()
                    }
                }
                .groupBoxStyle(PrimaryGroupBoxStyle())
        }
    }
    
    private func medicationNextDates(forMedication medication: Medication) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color("main"))
                        .font(.title)
                    Text("Próximos Medicamentos")
                        .foregroundColor(Color("main"))
                        .font(.title3)
                        .bold()
                    Spacer()
                }.accessibilityElement(children: .combine)
                ForEach(dates, id: \.self){ date in
                        Text("\(date, formatter: itemFormatter)")
                    }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
}


struct MedicationDetailSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationDetailSwiftUIView(medication: Medication(), medicationManager: MedicationManager())
    }
}
