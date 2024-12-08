//
//  CostGroupListView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct CostGroupListView: View {
    
    // Agora recebemos o ViewModel como parâmetro
    @ObservedObject var viewModel: CostGroupViewModel
    
    // Estado para controlar a apresentação do sheet de criação
    @State private var isShowingNewGroupSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.costGroups) { group in
                    NavigationLink {
                        CostGroupDetailView(group: group)
                    } label: {
                        CostGroupRowView(group: group)
                    }

                }
                .onDelete { indexSet in
                    // Convert IndexSet to the actual groups we want to delete
                    let groupsToDelete = indexSet.map { viewModel.costGroups[$0] }
                    
                    // Delete each group
                    Task {
                        for group in groupsToDelete {
                            await viewModel.removeCostGroup(group)
                        }
                    }
                }
            }
            .navigationTitle("Grupos de Custos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingNewGroupSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingNewGroupSheet) {
                NewCostGroupView(viewModel: viewModel)
            }
        }
    }
}

// Formatter para valores monetários
extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
}
