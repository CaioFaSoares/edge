//
//  SettingsView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct SettingsView: View {
    let periodManager: PeriodManager
    
    var body: some View {
        List {
            Section("Períodos") {
                NavigationLink("Lista de Períodos") {
                    PeriodListView(periodManager: periodManager)
                }
                
                NavigationLink("Configuração do Período") {
                    PeriodSettingsView(periodManager: periodManager)
                }
                
                NavigationLink("Controle de Períodos") {
                    PeriodControlView(periodManager: periodManager)
                }
            }
            
            Section("Aplicativo") {
                // Aqui você pode adicionar outras configurações do app
                Text("Versão 1.0 - Desenvolvido @ copland")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
