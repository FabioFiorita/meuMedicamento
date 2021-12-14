//
//  HistoricComponents.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 14/12/21.
//

import SwiftUI

struct HistoricComponents: View {
    @Binding var inTime: Int
    @Binding var late: Int
    @Binding var missed: Int
    @State var isTotal: Bool
    
    var body: some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text("No Horário")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibility(label: Text("Sem atraso"))
                    .font(.title)
                    .imageScale(.large)
                Text("\(inTime)")
                    .font(.title)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Sem Atraso: \(inTime)")
            
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text("Atrasado")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                Image(systemName: "clock.fill")
                    .foregroundColor(.yellow)
                    .accessibility(label: Text("Atrasado"))
                    .font(.title)
                    .imageScale(.large)
                Text("\(late)")
                    .font(.title)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Atrasado: \(late)")
            
            VStack(alignment: .center, spacing: 10) {
                if isTotal {
                    Text("Não tomou")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(label: Text("Não tomou"))
                    .font(.title)
                    .imageScale(.large)
                Text("\(missed)")
                    .font(.title)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Não tomou: \(missed)")
        }
    }
}

