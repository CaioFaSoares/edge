//
//  EditCostView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct EditCostView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CostGroupViewModel
    let cost: Cost
    
    @State private var amount: String
    @State private var costState: CostState
    
    init(viewModel: CostGroupViewModel, cost: Cost) {
        self.viewModel = viewModel
        self.cost = cost
        // Inicializar os estados com os valores atuais
        _amount = State(initialValue: cost.amount.formatted(.number.precision(.fractionLength(2))))
        _costState = State(initialValue: cost.state)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Valor", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Estado", selection: $costState) {
                        ForEach([CostState.planned, .confirmed, .launched], id: \.self) { state in
                            Text(state.displayName).tag(state)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if cost.parentCostID != nil {
                    Text("Este custo faz parte de uma série")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Editar Custo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        updateCost()
                    }
                }
            }
        }
        .presentationDetents([.height(200)])
    }
    
    private func updateCost() {
        guard let newAmount = Decimal(string: amount) else { return }
        
        var updatedCost = cost
        updatedCost.amount = newAmount
        updatedCost.state = costState
        
        Task {
            await viewModel.updateCost(updatedCost)
            dismiss()
        }
    }
}
