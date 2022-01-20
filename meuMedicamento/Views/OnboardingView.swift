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
                    Text(LocalizedStringKey("OnboardingWelcome"))
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
                                Text(LocalizedStringKey("OnboardingOrganizeTitle"))
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text(LocalizedStringKey("OnboardingOrganizeBody"))
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
                                Text(LocalizedStringKey("OnboardingControlTitle"))
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text(LocalizedStringKey("OnboardingControlBody"))
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
                                Text(LocalizedStringKey("OnboardingMapTitle"))
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text(LocalizedStringKey("OnboardingMapBody"))
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
                        Text(LocalizedStringKey("OnboardingButton"))
                            .bold()
                            .font(.title3)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color(.white))
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
