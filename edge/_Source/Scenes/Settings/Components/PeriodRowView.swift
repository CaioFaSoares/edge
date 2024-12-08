//
//  PeriodRowView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct PeriodRowView: View {
    let period: Period
    let isCurrentPeriod: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDateRange(start: period.startDate, end: period.endDate))
                    .font(.headline)
                
                if isCurrentPeriod {
                    Text("(Atual)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Planejado: \(formatCurrency(period.plannedTotal))")
                Text("Lançado: \(formatCurrency(period.launchedTotal))")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        value.formatted(.currency(code: "BRL"))
    }
}
