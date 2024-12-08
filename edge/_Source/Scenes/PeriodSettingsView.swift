//
//  PeriodSettingsView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct PeriodSettingsView: View {
    @ObservedObject var periodManager: PeriodManager
    @State private var startDay: String = ""
    @State private var duration: String = ""
    @State private var autoClose: Bool = false
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            Section("Configuração do Período") {
                HStack {
                    Text("Dia de Início")
                    TextField("1-28", text: $startDay)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Duração (dias)")
                    TextField("Ex: 30", text: $duration)
                        .keyboardType(.numberPad)
                }
                
                Toggle("Fechamento Automático", isOn: $autoClose)
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
        guard let startDayInt = Int(startDay),
              let durationInt = Int(duration),
              startDayInt >= 1 && startDayInt <= 28 else {
            showingAlert = true
            return
        }
        
        let newConfig = PeriodConfiguration(
            startDay: startDayInt,
            duration: durationInt,
            autoClose: autoClose,
            notifyBeforeEnd: false,
            daysBeforeEndNotification: 0,
            autoCarryOver: true,
            requireConfirmation: false
        )
        
        let validationResult = newConfig.validate()
        if validationResult.isValid {
            periodManager.periodConfiguration = newConfig
            // Salvar no UserDefaults
            if let encoded = try? JSONEncoder().encode(newConfig) {
                UserDefaults.standard.set(encoded, forKey: "PeriodConfiguration")
            }
        } else {
            showingAlert = true
        }
    }
}
