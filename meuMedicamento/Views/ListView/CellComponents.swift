//
//  CellComponents.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 13/12/21.
//

import SwiftUI

struct CellComponents: View {
    
    @ObservedObject var medication: Medication
    @ObservedObject var userSettings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            medicationName(forMedication: medication)
            medicationRemainingQuantity(forMedication: medication)
            medicationDate(forMedication: medication)
        }
        .accessibilityElement(children: .combine)
    }
    
    private func medicationName(forMedication medication: Medication) -> some View {
        Text(medication.name ?? "Untitled").font(.title)
    }
    private func medicationRemainingQuantity(forMedication medication: Medication) -> some View {
        Group {
            HStack {
                Text(LocalizedStringKey("RemainingMedications"))
                    .font(.body)
                    .fontWeight(.light)
                if Double(medication.remainingQuantity) <= Double(medication.boxQuantity) * (userSettings.limitMedication/100.0) {
                    Text("\(medication.remainingQuantity)")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.red)
                } else {
                    Text("\(medication.remainingQuantity)")
                        .font(.body)
                        .fontWeight(.light)
                }
            }
        }
    }
    private func medicationDate(forMedication medication: Medication) -> some View {
        Group {
            if medication.date?.timeIntervalSinceNow ?? 1.0 <= 0.0 {
                HStack {
                    Text(LocalizedStringKey("Next"))
                        .font(.body)
                        .fontWeight(.light)
                    Text(" \(medication.date ?? Date() ,formatter: shortDateFormatter)")
                        .foregroundColor(.red)
                        .font(.body)
                        .fontWeight(.light)
                }
            } else {
                HStack {
                    Text(LocalizedStringKey("Next"))
                        .font(.body)
                        .fontWeight(.light)
                    Text(" \(medication.date ?? Date() ,formatter: shortDateFormatter)")
                        .font(.body)
                        .fontWeight(.light)
                }
            }
        }
    }
}

struct CellComponents_Previews: PreviewProvider {
    static var previews: some View {
        CellComponents(medication: Medication(), userSettings: UserSettings())
    }
}
