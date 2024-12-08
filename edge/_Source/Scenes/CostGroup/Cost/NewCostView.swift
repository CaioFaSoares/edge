//
//  NewCostView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct NewCostView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CostGroupViewModel
    let group: CostGroup
    
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var date = Date()
    @State private var costState: CostState = .planned
    
    var body: some View {
        NavigationStack {
            Form {
                // Informações básicas
                Section("Detalhes") {
                    TextField("Descrição", text: $description)
                    
                    TextField("Valor", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker(
                        "Data",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                }
                
                // Estado do custo
                Section("Estado") {
                    Picker("Estado", selection: $costState) {
                        Text("Planejado").tag(CostState.planned)
                        Text("Confirmado").tag(CostState.confirmed)
                        Text("Lançado").tag(CostState.launched)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Novo Custo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveCost()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveCost() {
        guard let amountDecimal = Decimal(string: amount) else { return }
        
        let newCost = Cost(
            id: UUID(),
            groupID: group.id,
            amount: amountDecimal,
            state: costState,
            date: date,
            description: description
        )
        
        Task {
            await viewModel.addCost(newCost)
            dismiss()
        }
    }
}
