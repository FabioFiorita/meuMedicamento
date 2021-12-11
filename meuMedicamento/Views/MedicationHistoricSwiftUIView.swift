//
//  MedicationHistoricSwiftUIView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 09/12/21.
//

import SwiftUI

struct MedicationHistoricSwiftUIView: View {
    @ObservedObject var medicationManager: MedicationManager
    @StateObject var medication: Medication
    @State private var inTime = 0
    @State private var late = 0
    @State private var missed = 0
    @State private var inTime7 = 0
    @State private var late7 = 0
    @State private var missed7 = 0
    @State private var inTime30 = 0
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
                                Text("Últimos 7 dias")
                                HStack {
                                    historicGroupBox7Days()
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .groupBoxStyle(PrimaryGroupBoxStyle())
                        GroupBox {
                            VStack(alignment: .center, spacing: 5) {
                                Text("Últimos 30 dias")
                                HStack {
                                    historicGroupBox30Days()
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
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
                    inTime = medicationManager.fetchHistoric(forStatus: .inTime, forType: .medication, medication: medication)
                    late = medicationManager.fetchHistoric(forStatus: .late, forType: .medication, medication: medication)
                    missed = medicationManager.fetchHistoric(forStatus: .missed, forType: .medication, medication: medication)
                    inTime7 = medicationManager.fetchHistoric(forStatus: .inTime, forType: .medication7Days, medication: medication)
                    late7 = medicationManager.fetchHistoric(forStatus: .late, forType: .medication7Days, medication: medication)
                    missed7 = medicationManager.fetchHistoric(forStatus: .missed, forType: .medication7Days, medication: medication)
                    inTime30 = medicationManager.fetchHistoric(forStatus: .inTime, forType: .medication30Days, medication: medication)
                    late30 = medicationManager.fetchHistoric(forStatus: .late, forType: .medication30Days, medication: medication)
                    missed30 = medicationManager.fetchHistoric(forStatus: .missed, forType: .medication30Days, medication: medication)
                }
            
        }
        .navigationTitle(("\(medication.name ?? "Medicamento")"))
    }
    private func historicGroupBox() -> some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text("Sem atraso"))
                    .font(.largeTitle)
                Text("\(inTime)")
                    .font(.largeTitle)
            }
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text("Atrasado"))
                .font(.largeTitle)
                Text("\(late)")
                    .font(.largeTitle)
            }
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(label: Text("Não tomou"))
                .font(.largeTitle)
                Text("\(missed)")
                    .font(.largeTitle)
            }
        }
    }
    private func historicGroupBox7Days() -> some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text("Sem atraso"))
                    .font(.title)
                Text("\(inTime7)")
                    .font(.title)
            }
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text("Atrasado"))
                .font(.title)
                Text("\(late7)")
                    .font(.title)
            }
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(label: Text("Não tomou"))
                .font(.title)
                Text("\(missed7)")
                    .font(.title)
            }
        }
    }
    private func historicGroupBox30Days() -> some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text("Sem atraso"))
                    .font(.title)
                Text("\(inTime30)")
                    .font(.title)
            }
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text("Atrasado"))
                .font(.title)
                Text("\(late30)")
                    .font(.title)
            }
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(label: Text("Não tomou"))
                .font(.title)
                Text("\(missed30)")
                    .font(.title)
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
}

struct MedicationHistoricSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationHistoricSwiftUIView(medicationManager: MedicationManager(), medication: Medication())
    }
}
