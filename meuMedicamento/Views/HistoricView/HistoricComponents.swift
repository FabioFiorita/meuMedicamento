//
//  HistoricComponents.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 14/12/21.
//

import SwiftUI

struct HistoricComponents: View {
    @Binding var onTime: Int
    @Binding var late: Int
    @Binding var missed: Int
    @State var isTotal: Bool
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text(LocalizedStringKey("No Horário"))
                        //.font(.title3)
                        .accessibilityHidden(true)
                }
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text(LocalizedStringKey("Sem atraso")))
                    .font(.title)
                    //.imageScale(.large)
                Text("\(onTime)")
                    .font(.title)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Sem Atraso: \(onTime)")
            Spacer()
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text(LocalizedStringKey("Atrasado"))
                        //.font(.title3)
                        .accessibilityHidden(true)
                }
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text(LocalizedStringKey("Atrasado")))
                    .font(.title)
                    //.imageScale(.large)
                Text("\(late)")
                    .font(.title)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Atrasado: \(late)")
            Spacer()
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text(LocalizedStringKey("Não tomou"))
                        //.font(.title3)
                        .accessibilityHidden(true)
                }
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(label: Text(LocalizedStringKey("Não tomou")))
                    .font(.title)
                    //.imageScale(.large)
                Text("\(missed)")
                    .font(.title)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Não tomou: \(missed)")
            Spacer()
        }
    }
}

