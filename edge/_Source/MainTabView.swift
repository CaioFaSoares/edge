//
//  RootView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct MainTabView: View {
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
        TabView {
            NavigationStack {
                DashboardView()
                    .navigationTitle("Visão Geral")
            }
            .tabItem {
                Label("Visão Geral", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                CostGroupListView(viewModel: viewModel)
                    .navigationTitle("Grupos")
            }
            .tabItem {
                Label("Grupos", systemImage: "folder.fill")
            }
            
            NavigationStack {
                SettingsView(periodManager: periodManager)
                    .navigationTitle("Configurações")
            }
            .tabItem {
                Label("Configurações", systemImage: "gear")
            }
        }
        .tint(.blue)
        .onAppear {
            Task {
                await viewModel.loadGroups()
            }
        }
    }
}
