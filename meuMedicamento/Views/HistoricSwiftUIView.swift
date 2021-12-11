//
//  HistoricSwiftUIView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 08/12/21.
//

import SwiftUI

struct HistoricSwiftUIView: View {
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
                                    historicGroupBox()
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
                    }
                    .padding()
                        List {
                            ForEach(medicationManager.savedMedications, id: \.self) { medication in
                                    HStack {
                                        NavigationLink(medication.name ?? "Medicamento") {
                                            MedicationHistoricSwiftUIView(medicationManager: medicationManager, medication: medication)
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
    
    private func historicGroupBox() -> some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                Text("No Horário")
                    .font(.title3)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text("Sem atraso"))
                    .font(.largeTitle)
                Text("\(inTime)")
                    .font(.largeTitle)
            }
            VStack(alignment: .center, spacing: 10) {
                Text("Atrasado")
                    .font(.title3)
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text("Atrasado"))
                .font(.largeTitle)
                Text("\(late)")
                    .font(.largeTitle)
            }
            VStack(alignment: .center, spacing: 10) {
                Text("Não tomou")
                    .font(.title3)
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

}

struct HistoricSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricSwiftUIView(medicationManager: MedicationManager())
    }
}
