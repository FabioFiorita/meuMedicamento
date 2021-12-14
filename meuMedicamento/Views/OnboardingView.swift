//
//  OnboardingView.swift
//  meuMedicamento
//
//  Created by Fabio Fiorita on 08/12/21.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isOnboardingViewShowing: Bool
    
    var body: some View {
        ZStack {
            Color("main")
                .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15.0) {
                    Image("Logo SF")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                        .accessibilityHidden(true)
                    Text("Bem Vindo ao meuMedicamento.")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                    HStack(spacing: 25) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                                .foregroundColor(.white)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text("Organize seus medicamentos")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text("Confira uma lista dos seus medicamentos, controle a sua frequência e receba alertas quando seus remédios estiverem acabando.")
                                    .foregroundColor(.white)
                            }
                        }
                        HStack(spacing: 25) {
                            Image(systemName: "calendar.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                                .foregroundColor(.white)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text("Controle suas ingestões")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text("Acompanhe um histórico, verificando se os remédios foram tomados no horário correto, atrasados ou esquecidos.")
                                    .foregroundColor(.white)
                            }
                        }
                        HStack(spacing: 25) {
                            Image(systemName: "map")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                                .foregroundColor(.white)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text("Mapa Integrado")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text("Encontre farmácias e hospitais próximos.")
                                    .foregroundColor(.white)
                            }
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            isOnboardingViewShowing.toggle()
                            dismiss()
                        }
                    } label: {
                        Text("Começar a usar")
                            .bold()
                            .font(.title3)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background()
                            .cornerRadius(10.0)
                            .foregroundColor(Color("main"))
                    }

                    Spacer()
                }
                .padding()
            }
        }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboardingViewShowing: Binding.constant(true))
    }
}
