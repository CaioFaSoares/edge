//
//  PeriodSettingsView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct PeriodSettingsView: View {
    @ObservedObject var periodManager: PeriodManager
    @State private var closingDay: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            Section("Configuração do Período") {
                HStack {
                    Text("Dia do Fechamento")
                    TextField("1-28", text: $closingDay)
                        .keyboardType(.numberPad)
                }
            }
            
            Section {
                Button("Salvar Configuração") {
                    saveConfiguration()
                }
            }
        }
        .alert("Erro", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func saveConfiguration() {
        guard let closingDayInt = Int(closingDay),
              closingDayInt >= 1 && closingDayInt <= 28 else {
            showingAlert = true
            return
        }
        
        let newConfig = PeriodConfiguration(closingDay: closingDayInt)
        
        let validationResult = newConfig.validate()
        if validationResult.isValid {
            periodManager.periodConfiguration = newConfig
            if let encoded = try? JSONEncoder().encode(newConfig) {
                UserDefaults.standard.set(encoded, forKey: "PeriodConfiguration")
            }
        } else {
            showingAlert = true
        }
    }
}
