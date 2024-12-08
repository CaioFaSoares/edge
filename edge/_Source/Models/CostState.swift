//
//  CostState.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

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
