//
//  OnboardingView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var periodManager: PeriodManager
    @ObservedObject var onboardingManager: OnboardingManager
    
    @State private var selectedDate = Date()
    @State private var closingDay = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Bem-vindo ao Edge")
                    .font(.title)
                    .padding(.top, 40)
                
                Text("Vamos configurar seu período financeiro")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Escolha o dia do fechamento (1-28):")
                        .font(.subheadline)
                    
                    TextField("Ex: 5", text: $closingDay)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .padding(.horizontal)
                }
                .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Início do primeiro período:")
                        .font(.subheadline)
                    
                    DatePicker(
                        "Data de início",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                .padding(.top, 16)
                
                Button(action: createFirstPeriod) {
                    Text("Começar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                Spacer()
            }
            .padding()
            .alert("Erro", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Por favor, insira um dia válido entre 1 e 28")
            }
        }
    }
    
    private func createFirstPeriod() {
        guard let closingDayInt = Int(closingDay),
              closingDayInt >= 1 && closingDayInt <= 28 else {
            showError = true
            return
        }
        
        Task {
            do {
                try await periodManager.createFirstPeriod(
                    startDate: selectedDate,
                    closingDay: closingDayInt
                )
                onboardingManager.hasCompletedOnboarding = true
            } catch {
                showError = true
            }
        }
    }
}
