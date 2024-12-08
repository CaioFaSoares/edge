//
//  CostGroupRowView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

// Esta view representa uma linha na nossa lista de grupos
struct CostGroupRowView: View {
    let group: CostGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group.name)
                .font(.headline)
            
            HStack {
                // Mostramos os valores planejados e lançados
                VStack(alignment: .leading) {
                    Text("Planejado: \(group.plannedAmount as NSDecimalNumber)")
                        .font(.subheadline)
                    Text("Lançado: \(group.launchedAmount as NSDecimalNumber)")
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Ícones para indicar configurações do grupo
                if group.isRecurrent {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                if group.isQuickGroup {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CostRowView: View {
    let cost: Cost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(cost.description)
                    .font(.headline)
                Spacer()
                Text((cost.amount as NSDecimalNumber) as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "BRL"))
            }
            
            HStack {
                Text(cost.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                StatusBadge(state: cost.state)
            }
        }
        .padding(.vertical, 4)
    }
}
