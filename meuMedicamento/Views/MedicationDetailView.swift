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
                        Text(LocalizedStringKey("Edit"))
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
                    Label(LocalizedStringKey("Details"), systemImage: "doc.text")
                        .foregroundColor(Color("AccentColor"))
                        .font(.title3)
                    Text(LocalizedStringKey("RemainingQuantity")) +
                    Text(": \(medication.remainingQuantity)")
                    Text(LocalizedStringKey("BoxQuantity")) +
                    Text(": \(medication.boxQuantity)")
                    Text(LocalizedStringKey("NotificationType")) +
                    Text(": ") +
                    Text(LocalizedStringKey(medication.notificationType ?? ""))
                Group {
                    if medication.repeatPeriod != "Nunca" {
                        Text(LocalizedStringKey("RepeatEach")) +
                        Text(LocalizedStringKey(medication.repeatPeriod ?? ""))
                    }
                }
                Button(action: {
                    medicationManager.refreshRemainingQuantity(medication: medication)
                    dismiss()
                }) {
                    Text(LocalizedStringKey("RenewMedication"))
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
                            Label(LocalizedStringKey("Notes"), systemImage: "note.text")
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
                    Label(LocalizedStringKey("UpcomingMedications"), systemImage: "calendar")
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
