//
//  MedicationHistoricSwiftUIView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 09/12/21.
//

import SwiftUI

struct MedicationHistoricView: View {
    @ObservedObject var medicationManager: MedicationManager
    @ObservedObject var medication: Medication
    @State private var onTime7 = 0
    @State private var late7 = 0
    @State private var missed7 = 0
    @State private var onTime30 = 0
    @State private var late30 = 0
    @State private var missed30 = 0
    @State private var historicCount = 7
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack {
                    HStack {
                        GroupBox {
                            VStack(alignment: .center, spacing: 5) {
                                Text(LocalizedStringKey("Last7Days"))
                                    HistoricComponents(onTime: $onTime7, late: $late7, missed: $missed7, isTotal: false)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .groupBoxStyle(PrimaryGroupBoxStyle())
                        GroupBox {
                            VStack(alignment: .center, spacing: 5) {
                                Text(LocalizedStringKey("Last30Days"))
                                    HistoricComponents(onTime: $onTime30, late: $late30, missed: $missed30, isTotal: false)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .groupBoxStyle(PrimaryGroupBoxStyle())
                    }
                stepperHistory
                ScrollView {
                    ForEach(medicationManager.fetchHistoric(forMedication: medication).prefix(historicCount) , id: \.self){ historic in
                        medicationDateHistory(forHistoric: historic)
                    }
                }
                    Spacer()
                }
                .padding()
                .onAppear {
                    onTime7 = medicationManager.fetchHistoric(forStatus: .onTime, forType: .medication7Days, medication: medication)
                    late7 = medicationManager.fetchHistoric(forStatus: .late, forType: .medication7Days, medication: medication)
                    missed7 = medicationManager.fetchHistoric(forStatus: .missed, forType: .medication7Days, medication: medication)
                    onTime30 = medicationManager.fetchHistoric(forStatus: .onTime, forType: .medication30Days, medication: medication)
                    late30 = medicationManager.fetchHistoric(forStatus: .late, forType: .medication30Days, medication: medication)
                    missed30 = medicationManager.fetchHistoric(forStatus: .missed, forType: .medication30Days, medication: medication)
                }
            
        }
        .navigationTitle(("\(medication.name ?? "Medication")"))
    }
    
    private func medicationDateHistory(forHistoric historic: Historic) -> some View {
        GroupBox {
            HStack {
                Text("\(historic.dates ?? Date(),formatter: itemFormatter)" )
                Spacer()
                Group {
                    switch historic.medicationStatus {
                    case "Sem Atraso":
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green).accessibility(label: Text(LocalizedStringKey("OnTime")))
                    case "Atrasado":
                        Image(systemName: "clock.fill").foregroundColor(.yellow).accessibility(label: Text(LocalizedStringKey("Late")))
                    case "Não tomou":
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red).accessibility(label: Text(LocalizedStringKey("Missed")))
                    default:
                        Image(systemName: "questionmark").foregroundColor(.red).accessibility(label: Text(LocalizedStringKey("SituationNotFound")))
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(historic.dates ?? Date(), formatter: itemFormatter) \(historic.medicationStatus ?? "Indeterminate Status")")
            
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
    
    private var stepperHistory : some View {
        GroupBox {
            HStack {
                Text(LocalizedStringKey("HistoricOfTheLast")) + Text(" \(historicCount) ").bold().foregroundColor(.orange) + Text(LocalizedStringKey("medications"))
                Spacer()
                Stepper(LocalizedStringKey("HistoricQuantity"), value: $historicCount, in: 0...31).labelsHidden()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .accessibilityElement()
            .accessibilityLabel(LocalizedStringKey("Histórico dos últimos medicamentos"))
            .accessibilityValue(String(historicCount))
            .accessibilityAdjustableAction { value in
                switch value {
                case .increment:
                    if historicCount < 31 {
                        historicCount += 1
                    }
                case .decrement:
                    if historicCount > 0 {
                        historicCount -= 1
                    }
                default:
                    print("Não utilizado")
                }
            }
        }
        .groupBoxStyle(PrimaryGroupBoxStyle())
    }
}

struct MedicationHistoricSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationHistoricView(medicationManager: MedicationManager(), medication: Medication())
    }
}
