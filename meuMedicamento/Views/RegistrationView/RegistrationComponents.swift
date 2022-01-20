//
//  RegistrationComponents.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 13/12/21.
//

import SwiftUI

struct RegistrationComponents: View {
    
    @Binding var name: String
    @Binding var remainingQuantity: String
    @Binding var boxQuantity: String
    @Binding var notificationType: String
    @Binding var date: Date
    @Binding var repeatPeriod: String
    @Binding var notes: String
    @FocusState private var focusedField: Field?
    @State private var showDatePicker = false
    
    var body: some View {
        Form {
            TextField(LocalizedStringKey("MedicationName"), text: $name)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
            TextField(LocalizedStringKey("RemainingQuantity"), text: $remainingQuantity)
                .focused($focusedField, equals: .remainingQuantity)
                .keyboardType(.numberPad)
                .tint(Color("AccentColor"))
            TextField(LocalizedStringKey("BoxQuantity"), text: $boxQuantity)
                .focused($focusedField, equals: .boxQuantity)
                .keyboardType(.numberPad)
                .tint(Color("AccentColor"))
            Section {
                notificationTypePicker
                Group {
                    Text(LocalizedStringKey("InitialDate")) + Text(" \(date, formatter: itemFormatter)").foregroundColor(showDatePicker ? .blue : .secondary)
                }.onTapGesture(perform: {
                    focusedField = .none
                    showDatePicker.toggle()
                })
                if showDatePicker {
                    DatePicker("", selection: $date, in: Date()...).datePickerStyle(.graphical)
                }
                Picker(selection: $repeatPeriod, label: Text(LocalizedStringKey("Repeat"))) {
                    ForEach(RepeatPeriod.periods, id: \.self) { periods in
                        Text(LocalizedStringKey(periods)).tag(periods)
                    }
                }
            }
            Section{
                Text(LocalizedStringKey("Notes"))
                TextEditor(text: $notes)
            }
        }
        .accentColor(Color("AccentColor"))
        .onSubmit {
            switch focusedField {
            case .name:
                focusedField = .remainingQuantity
            default:
                break
            }
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    switch focusedField {
                    case .name:
                        focusedField = .none
                    case .remainingQuantity:
                        focusedField = .name
                    case .boxQuantity:
                        focusedField = .remainingQuantity
                    default:
                        break
                    }
                } label: {
                    Label(LocalizedStringKey("PreviousField"), systemImage: "arrow.up")
                        .tint(Color("AccentColor"))
                }
                Button {
                    switch focusedField {
                    case .name:
                        focusedField = .remainingQuantity
                    case .remainingQuantity:
                        focusedField = .boxQuantity
                    case .boxQuantity:
                        focusedField = .none
                    default:
                        break
                    }
                } label: {
                    Label(LocalizedStringKey("NextField"), systemImage: "arrow.down")
                        .tint(Color("AccentColor"))
                }
            }
        })
    }
    
    private var notificationTypePicker: some View {
        Group {
            Picker(selection: $notificationType, label: Text(LocalizedStringKey("NotificationType"))) {
                ForEach(NotificationType.type, id: \.self) { type in
                    Text(LocalizedStringKey(type)).tag(type)
                }
            }
            .pickerStyle(.segmented)
            if notificationType == "Regularmente" {
                Text(LocalizedStringKey("RegularlyText"))
            } else {
                Text(LocalizedStringKey("AfterConclusionText"))
            }
        }
        
    }

}

