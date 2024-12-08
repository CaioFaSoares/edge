//
//  CostError.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import Foundation

enum CostError: Error {
    case invalidTransition(from: CostState, to: CostState)
    case invalidAmount
    case invalidGroup
    case notRecurrent
    case notPartOfSeries
    case invalidSeriesUpdate
    
    var localizedDescription: String {
        switch self {
        case .notRecurrent:
            return "Custo não é recorrente"
        case .notPartOfSeries:
            return "Custo não faz parte de uma série"
        case .invalidSeriesUpdate:
            return "Não foi possível atualizar a série"
        case .invalidTransition(let from, let to):
            return "Transição inválida de \(from) para \(to)"
        case .invalidAmount:
            return "Valor inválido"
        case .invalidGroup:
            return "Grupo inválido"
        }
    }
}
