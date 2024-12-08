//
//  CostGroupDetailView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct CostGroupDetailView: View {
    let group: CostGroup
    @ObservedObject var viewModel: CostGroupViewModel
    @State private var showingNewCost = false
    
    var body: some View {
        List {
            Section("Informações do Grupo") {
                LabeledContent("Planejado", value: (group.plannedAmount as NSDecimalNumber) as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "BRL"))
                
                if let confirmed = group.confirmedAmount {
                    LabeledContent("Confirmado", value: (confirmed as NSDecimalNumber) as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "BRL"))
                }
                
                LabeledContent("Lançado", value: (group.launchedAmount as NSDecimalNumber) as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "BRL"))
            }
            
            Section("Configurações") {
                LabeledContent("Recorrente", value: group.isRecurrent ? "Sim" : "Não")
                LabeledContent("Grupo Rápido", value: group.isQuickGroup ? "Sim" : "Não")
            }
            
            Section("Custos") {
                // Aqui virá a lista de custos
                if viewModel.costs.isEmpty {
                    Text("Nenhum custo registrado")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.costs) { cost in
                        CostRowView(cost: cost)
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewCost = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewCost) {
            NewCostView(viewModel: viewModel, group: group)
        }
    }
}
