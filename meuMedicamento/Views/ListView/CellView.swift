//
//  CellView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 13/12/21.
//

import SwiftUI

struct CellView: View {
    @State private var showModalEdit = false
    @State private var showModalHistory = false
    @State private var showTimeIntervalAlert = false
    @State private var showViewContextAlert = false
    @ObservedObject var medication: Medication
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var medicationManager: MedicationManager
    var body: some View {
        HStack {
            checkmark(forMedication: medication)
            NavigationLink(destination: MedicationDetailView(medication: medication, medicationManager: medicationManager)) {
                CellComponents(medication: medication, userSettings: userSettings)
            }
            .contextMenu(menuItems: {
                Button {
                    updateQuantity(medication: medication)
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Tomar Medicamento")
                    }.accessibilityElement(children: .combine)
                }
                Button {
                    medicationManager.refreshRemainingQuantity(medication: medication)
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Renovar Quantidade")
                    }.accessibilityElement(children: .combine)
                }
                Button {
                    showModalHistory = true
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Ver Histórico")
                    }.accessibilityElement(children: .combine)
                }
                Button(role: .destructive) {
                    medicationManager.deleteMedication(medication: medication)
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Deletar Medicamento")
                    }.accessibilityElement(children: .combine)
                }
            })
            .sheet(isPresented: $showModalHistory, onDismiss: {
                medicationManager.fetchMedications()
            }, content: {
                MedicationHistoricView(medicationManager: medicationManager, medication: medication)
            })
        }
        .swipeActions(edge: .trailing ,allowsFullSwipe: false) {
            Button("Apagar", role: .destructive) {
                medicationManager.deleteMedication(medication: medication)
            }
        }
    }
    
    private func checkmark(forMedication medication: Medication) -> some View {
        Button {
            updateQuantity(medication: medication)
            if medication.remainingQuantity >= 1 {
                medication.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        medication.isSelected = false
                        medicationManager.fetchMedications()
                    }
                }
            }
            medicationManager.fetchMedications()
        } label: {
            Image(systemName: "checkmark.circle").font(.system(size: 35, weight: .regular)).accessibility(label: Text("Tomar Medicamento"))
                .foregroundColor(medication.isSelected ? Color.green : Color.primary)
        }
        .buttonStyle(.plain)
        .alert("Erro na hora de agendar a notificação", isPresented: $showTimeIntervalAlert) {
            Button {
                self.showModalEdit = true
            } label: {
                Text("Editar Medicamento")
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Configure a data de início novamente")
        }
        .sheet(isPresented: $showModalEdit, onDismiss: medicationManager.fetchMedications, content: {
            EditMedicationSwiftUIView(medication: medication)
        })
        .alert("Erro na hora de cadastrar o medicamento", isPresented: $showViewContextAlert) {
            Button("OK",role: .destructive) { }
        } message: {
            Text("Reinicie o aplicativo")
        }
    }
    
    private func updateQuantity(medication: Medication) {
        withAnimation {
            switch medicationManager.updateRemainingQuantity(medication: medication) {
            case .notificationTimeIntervalError:
                showTimeIntervalAlert = true
            case .viewContextError:
                showViewContextAlert = true
            case .sucess:
                print("updateQuantity Sucess!")
            default:
                break
            }
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(medication: Medication(), userSettings: UserSettings(), medicationManager: MedicationManager())
    }
}
