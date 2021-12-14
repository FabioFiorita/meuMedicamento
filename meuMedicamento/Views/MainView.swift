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
                            Label("Medicamentos", systemImage: "pills")
                        }.badge(medicationManager.calculateLateMedications())
                    
                    HistoricView(medicationManager: medicationManager)
                        .tabItem {
                            Label("Histórico", systemImage: "calendar")
                        }
                    
                    MapView()
                        .tabItem {
                            Label("Mapa", systemImage: "map")
                        }
                    
                    SettingsSwiftUIView(userSettings: userSettings)
                        .tabItem {
                            Label("Ajustes", systemImage: "gear")
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
