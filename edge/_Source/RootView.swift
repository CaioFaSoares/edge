//
//  RootView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct RootView: View {
    @StateObject private var periodManager = PeriodManager(
        repository: UserDefaultsPeriodRepository()
    )
    
    @StateObject private var viewModel = CostGroupViewModel(
        repository: UserDefaultsCostRepository(),
        periodManager: PeriodManager(
            repository: UserDefaultsPeriodRepository()
        )
    )
    var body: some View {
        // TabView é o container principal que gerencia nossas diferentes abas
        TabView {
            // Primeira aba: Visão geral (Dashboard)
            NavigationStack {
                DashboardView()
                    .navigationTitle("Visão Geral")
            }
            .tabItem {
                Label("Visão Geral", systemImage: "chart.bar.fill")
            }
            
            // Segunda aba: Lista de grupos de custo
            NavigationStack {
                CostGroupListView(viewModel: viewModel)
                    .navigationTitle("Grupos")
            }
            .tabItem {
                Label("Grupos", systemImage: "folder.fill")
            }
            
            // Terceira aba: Configurações
            NavigationStack {
                SettingsView()
                    .navigationTitle("Configurações")
            }
            .tabItem {
                Label("Configurações", systemImage: "gear")
            }
        }
        // Aplicamos um estilo consistente à TabView
        .tint(.blue) // Cor dos ícones e textos selecionados
    }
}
