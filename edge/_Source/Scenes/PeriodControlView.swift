//
//  PeriodControlView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct PeriodControlView: View {
    @ObservedObject var periodManager: PeriodManager
    
    var body: some View {
        List {
            // Seção do Período Atual
            if let currentPeriod = periodManager.currentPeriod {
                Section("Período Atual") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ciclo: \(formatDate(currentPeriod.startDate)) - \(formatDate(currentPeriod.endDate))")
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Planejado: \(formatCurrency(currentPeriod.plannedTotal))")
                            Text("Confirmado: \(formatCurrency(currentPeriod.confirmedTotal))")
                            Text("Lançado: \(formatCurrency(currentPeriod.launchedTotal))")
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Seção de Configuração
            Section("Configuração") {
                HStack {
                    Text("Dia do Fechamento")
                    Spacer()
                    Text("\(periodManager.periodConfiguration.closingDay)")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Seção de Ações
            Section {
                Button("Forçar Novo Período") {
                    Task {
                        try? await periodManager.createNewPeriod()
                    }
                }
                .foregroundColor(.blue)
            }
            
            Section("Histórico") {
                ForEach(periodManager.periods) { period in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(period.startDate))
                            .font(.headline)
                        Text("Lançado: \(formatCurrency(period.launchedTotal))")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Controle de Períodos")
    }
    
    // Formatadores
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0,00"
    }
}
