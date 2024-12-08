//
//  Cost_Utils.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

extension Cost {
    
    // ⚠️ funcionalidade importante, é interessante isso poder ser desabilitado forçadamente.
    // verifica se o valor do custo pode ser editado
    var isEditable: Bool {
        state != .launched
    }
    
    // tenta transicionar o estado do custo
    mutating func transition(to newState: CostState) throws {
        guard state.canTransitionTo(newState) else {
            throw CostError.invalidTransition(from: state, to: newState)
        }
    }
    
}

enum CostError: Error {
    case invalidTransition(from: CostState, to: CostState)
    case invalidAmount
    case invalidGroup
}

extension Cost {
    
    // Esta função nos ajuda a testar diferentes cenários de transição
    static func createWithTransitions(groupID: UUID) -> Cost {
        var cost = Cost(groupID: groupID, amount: 50.00, description: "Teste de transições")
        
        // Podemos usar isso para testar o comportamento de transições válidas e inválidas
        do {
            try cost.transition(to: .confirmed)
            // Se chegamos aqui, a transição foi bem sucedida
        } catch CostError.invalidTransition(let from, let to) {
            print("Transição inválida de \(from) para \(to)")
        } catch {
            print("Erro inesperado: \(error)")
        }
        
        return cost
    }
}
