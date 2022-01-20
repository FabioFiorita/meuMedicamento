//
//  HistoricSwiftUIView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 08/12/21.
//

import SwiftUI

struct HistoricView: View {
    @ObservedObject var medicationManager: MedicationManager
    @State private var onTime = 0
    @State private var late = 0
    @State private var missed = 0
    @State private var onTime7 = 0
    @State private var late7 = 0
    @State private var missed7 = 0
    @State private var onTime30 = 0
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
                                Text(LocalizedStringKey("Total"))
                                    .font(.largeTitle)
                                    .bold()
                                    HistoricComponents(onTime: $onTime, late: $late, missed: $missed, isTotal: true)
                            }
                            .frame(maxWidth: .infinity)
                            .accessibilityElement(children: .combine)
                        }
                        .groupBoxStyle(PrimaryGroupBoxStyle())
                        HStack {
                            GroupBox {
                                VStack(alignment: .center, spacing: 5) {
                                    Text(LocalizedStringKey("Last7Days"))
                                        HistoricComponents(onTime: $onTime7, late: $late7, missed: $missed7, isTotal: false)
                                }
                                .frame(maxWidth: .infinity)
                                .accessibilityElement(children: .combine)
                            }
                            .groupBoxStyle(PrimaryGroupBoxStyle())
                            GroupBox {
                                VStack(alignment: .center, spacing: 5) {
                                    Text(LocalizedStringKey("Last30Days"))
                                        HistoricComponents(onTime: $onTime30, late: $late30, missed: $missed30, isTotal: false)
                                }
                                .frame(maxWidth: .infinity)
                                .accessibilityElement(children: .combine)
                            }
                            .groupBoxStyle(PrimaryGroupBoxStyle())
                        }
                    }
                    .padding()
                    List {
                        ForEach(medicationManager.savedMedications, id: \.self) { medication in
                            HStack {
                                NavigationLink(medication.name ?? "Medication") {
                                    MedicationHistoricView(medicationManager: medicationManager, medication: medication)
                                }
                            }
                        }
                        .listStyle(.automatic)
                    }
                    Spacer()
                }
                .onAppear {
                    medicationManager.deleteHistories()
                    medicationManager.fetchHistories()
                    medicationManager.fetchMedications()
                    onTime = medicationManager.fetchHistoric(forStatus: .onTime, forType: .all)
                    late = medicationManager.fetchHistoric(forStatus: .late, forType: .all)
                    missed = medicationManager.fetchHistoric(forStatus: .missed, forType: .all)
                    onTime7 = medicationManager.fetchHistoric(forStatus: .onTime, forType: .all7Days)
                    late7 = medicationManager.fetchHistoric(forStatus: .late, forType: .all7Days)
                    missed7 = medicationManager.fetchHistoric(forStatus: .missed, forType: .all7Days)
                    onTime30 = medicationManager.fetchHistoric(forStatus: .onTime, forType: .all30Days)
                    late30 = medicationManager.fetchHistoric(forStatus: .late, forType: .all30Days)
                    missed30 = medicationManager.fetchHistoric(forStatus: .missed, forType: .all30Days)
                }
                
            }
            .navigationBarTitle(LocalizedStringKey("Historic"),displayMode: .automatic)
        }
        .navigationViewStyle(.stack)
    }
    
}

struct HistoricSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricView(medicationManager: MedicationManager())
    }
}
