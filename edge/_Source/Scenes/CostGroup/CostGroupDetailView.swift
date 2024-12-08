//
//  CostGroupDetailView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

struct CostGroupDetailView: View {
    let group: CostGroup
    
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
        }
        .navigationTitle(group.name)
    }
}
