//
//  HistoricSwiftUIView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 08/12/21.
//

import SwiftUI

struct HistoricView: View {
    @ObservedObject var medicationManager: MedicationManager
    @State private var inTime = 0
    @State private var late = 0
    @State private var missed = 0
    @State private var inTime7 = 0
    @State private var late7 = 0
    @State private var missed7 = 0
    @State private var inTime30 = 0
    @State private var late30 = 0
    @State private var missed30 = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                VStack {
                    VStack {
                        GroupBox {
                            VStack {
                                Text("Total")
                                    .font(.largeTitle)
                                    .bold()
                                HStack(alignment: .center) {
                                    historicGroupBox(inTime: inTime, late: late, missed: missed, isTotal: true)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                        }
                        .groupBoxStyle(PrimaryGroupBoxStyle())
                        HStack {
                            GroupBox {
                                VStack(alignment: .center, spacing: 5) {
                                    Text("Últimos 7 dias")
                                    HStack {
                                        historicGroupBox(inTime: inTime7, late: late7, missed: missed7, isTotal: false)
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .groupBoxStyle(PrimaryGroupBoxStyle())
                            GroupBox {
                                VStack(alignment: .center, spacing: 5) {
                                    Text("Últimos 30 dias")
                                    HStack {
                                        historicGroupBox(inTime: inTime30, late: late30, missed: missed30, isTotal: false)
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .groupBoxStyle(PrimaryGroupBoxStyle())
                        }
                    }
                    .padding()
                    List {
                        ForEach(medicationManager.savedMedications, id: \.self) { medication in
                            HStack {
                                NavigationLink(medication.name ?? "Medicamento") {
                                    MedicationHistoricView(medicationManager: medicationManager, medication: medication)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                    Spacer()
                }
                .onAppear {
                    inTime = medicationManager.fetchHistoric(forStatus: .inTime, forType: .all)
                    late = medicationManager.fetchHistoric(forStatus: .late, forType: .all)
                    missed = medicationManager.fetchHistoric(forStatus: .missed, forType: .all)
                    inTime7 = medicationManager.fetchHistoric(forStatus: .inTime, forType: .all7Days)
                    late7 = medicationManager.fetchHistoric(forStatus: .late, forType: .all7Days)
                    missed7 = medicationManager.fetchHistoric(forStatus: .missed, forType: .all7Days)
                    inTime30 = medicationManager.fetchHistoric(forStatus: .inTime, forType: .all30Days)
                    late30 = medicationManager.fetchHistoric(forStatus: .late, forType: .all30Days)
                    missed30 = medicationManager.fetchHistoric(forStatus: .missed, forType: .all30Days)
                    medicationManager.fetchMedications()
                    
                }
                
            }
            .navigationBarTitle("Histórico",displayMode: .automatic)
        }
        .navigationViewStyle(.stack)
    }
    
    private func historicGroupBox(inTime: Int, late: Int, missed: Int, isTotal: Bool) -> some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text("No Horário")
                        .font(.title3)
                }
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text("Sem atraso"))
                    .font(.largeTitle)
                Text("\(inTime)")
                    .font(.largeTitle)
            }
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text("Atrasado")
                        .font(.title3)
                }
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text("Atrasado"))
                    .font(.largeTitle)
                Text("\(late)")
                    .font(.largeTitle)
            }
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text("Não tomou")
                        .font(.title3)
                }
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(label: Text("Não tomou"))
                    .font(.largeTitle)
                Text("\(missed)")
                    .font(.largeTitle)
            }
        }
    }
    
}

struct HistoricSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricView(medicationManager: MedicationManager())
    }
}
