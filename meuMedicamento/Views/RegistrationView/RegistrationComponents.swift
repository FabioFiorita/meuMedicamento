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
            TextField("Nome do Medicamento", text: $name)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
            TextField("Quantidade Restante", text: $remainingQuantity)
                .focused($focusedField, equals: .remainingQuantity)
                .keyboardType(.numberPad)
                .tint(Color("main"))
            TextField("Quantidade na Caixa", text: $boxQuantity)
                .focused($focusedField, equals: .boxQuantity)
                .keyboardType(.numberPad)
                .tint(Color("main"))
            Section {
                notificationTypePicker
                Group {
                    Text("Data de Início: ") + Text("\(date, formatter: itemFormatter)").foregroundColor(showDatePicker ? .blue : .secondary)
                }.onTapGesture(perform: {
                    focusedField = .none
                    showDatePicker.toggle()
                })
                if showDatePicker {
                    DatePicker("", selection: $date, in: Date()...).datePickerStyle(.graphical)
                }
                Picker(selection: $repeatPeriod, label: Text("Repetir")) {
                    ForEach(RepeatPeriod.periods, id: \.self) { periods in
                        Text(periods).tag(periods)
                    }
                }
            }
            Section{
                Text("Notas")
                TextEditor(text: $notes)
            }
        }
        .accentColor(Color("main"))
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
                    Image(systemName: "arrow.up").tint(Color("main"))
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
                    Image(systemName: "arrow.down").tint(Color("main"))
                }
            }
        })
    }
    
    private var notificationTypePicker: some View {
        Group {
            Picker(selection: $notificationType, label: Text("Tipo de Notificação")) {
                ForEach(NotificationType.type, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(.segmented)
            if notificationType == "Regularmente" {
                Text("O próximo medicamento será agendando seguindo a data definida")
            } else {
                Text("O próximo medicamento será agendando seguindo a data da última conclusão")
            }
        }
        
    }

}

