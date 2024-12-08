//
//  PeriodDetailView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct PeriodDetailView: View {
    let period: Period
    
    var body: some View {
        List {
            Section("Informações") {
                LabeledContent("Início", value: period.startDate, format: .dateTime.day().month().year())
                LabeledContent("Fim", value: period.endDate, format: .dateTime.day().month().year())
            }
            
            Section("Valores") {
                LabeledContent("Planejado", value: period.plannedTotal, format: .currency(code: "BRL"))
                LabeledContent("Confirmado", value: period.confirmedTotal, format: .currency(code: "BRL"))
                LabeledContent("Lançado", value: period.launchedTotal, format: .currency(code: "BRL"))
            }
            
            if !period.costGroupIDs.isEmpty {
                Section("Grupos de Custo") {
                    // Aqui você pode adicionar uma lista dos grupos
                    // associados a este período
                    Text("\(period.costGroupIDs.count) grupos")
                }
            }
        }
        .navigationTitle("Detalhes do Período")
    }
}
