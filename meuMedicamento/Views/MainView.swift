//
//  TabView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 13/12/21.
//

import SwiftUI

struct MainView: View {
    @AppStorage("OnboardingView") var isOnboardingViewShowing = true
    @StateObject private var medicationManager = MedicationManager()
    @StateObject private var userSettings = UserSettings()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if isOnboardingViewShowing {
                OnboardingView(isOnboardingViewShowing: $isOnboardingViewShowing)
            } else {
                TabView {
                    ListView(userSettings: userSettings, medicationManager: medicationManager)
                        .tabItem {
                            Label(LocalizedStringKey("Medicamentos"), systemImage: "pills")
                        }.badge(medicationManager.calculateLateMedications())
                    
                    HistoricView(medicationManager: medicationManager)
                        .tabItem {
                            Label(LocalizedStringKey("Histórico"), systemImage: "calendar")
                        }
                    
                    MapView()
                        .tabItem {
                            Label(LocalizedStringKey("Mapa"), systemImage: "map")
                        }
                    
                    SettingsView(userSettings: userSettings)
                        .tabItem {
                            Label(LocalizedStringKey("Ajustes"), systemImage: "gear")
                        }
                }
            }
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
