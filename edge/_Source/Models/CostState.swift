//
//  CostState.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

enum CostState: String, Codable {
    case planned    // estado inicial de um gasto. representa uma intenção
    case confirmed  // representa um compromisso financeiro
    case launched   // representa um gasto efetivo
    
    // funcao para confirmar se custo pode transitar de um estado para outro
    func canTransitionTo(_ newState: CostState) -> Bool {
        switch (self, newState) {
        case (.planned, .confirmed),
             (.confirmed, .launched):
            return true
        default:
            return false
        }
    }
    
}

extension CostState {
    var displayName: String {
        switch self {
        case .planned: return "Planejado"
        case .confirmed: return "Confirmado"
        case .launched: return "Lançado"
        }
    }
    
    var color: Color {
        switch self {
        case .planned: return .blue
        case .confirmed: return .orange
        case .launched: return .green
        }
    }
}
