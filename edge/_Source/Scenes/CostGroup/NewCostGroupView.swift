//
//  NewCostGroupView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

// View para criar um novo grupo
struct NewCostGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CostGroupViewModel
    
    @State private var name = ""
    @State private var plannedAmount = ""
    @State private var isRecurrent = false
    @State private var isQuickGroup = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Básicas") {
                    TextField("Nome do Grupo", text: $name)
                    TextField("Valor Planejado", text: $plannedAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Configurações") {
                    Toggle("Grupo Recorrente", isOn: $isRecurrent)
                    Toggle("Grupo Rápido", isOn: $isQuickGroup)
                }
            }
            .navigationTitle("Novo Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        Task {
                            await saveGroup()
                        }
                    }
                    .disabled(name.isEmpty || plannedAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveGroup() async {
        guard let planned = Decimal(string: plannedAmount) else { return }
        
        let newGroup = CostGroup(
            id: UUID(),
            name: name,
            plannedAmount: planned,
            confirmedAmount: nil,
            launchedAmount: 0,
            isRecurrent: isRecurrent,
            isQuickGroup: isQuickGroup
        )
        
        await viewModel.addCostGroup(newGroup)
        dismiss()
    }
}
