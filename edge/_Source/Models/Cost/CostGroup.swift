//
//  CostGroup.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

struct CostGroup: Identifiable, Codable {
    
    // identity
    let id: UUID
    var name: String
    
    // monetary info
    var plannedAmount: Decimal
    var confirmedAmount: Decimal?
    private(set) var launchedAmount: Decimal
    
    // configurations
    var isRecurrent: Bool
    var isQuickGroup: Bool
    
    // % do custo do grupo
//    var progress: Double {
//        guard plannedAmount > 0 else { return 0 }
//        return Double()
//    }
    
    // atualização de valores lançados
    mutating func updateLaunchedAmount(_ newAmount: Decimal) {
        launchedAmount = newAmount
    }
    
    mutating func updateConfirmedAmount(_ newAmount: Decimal) {
        confirmedAmount = newAmount
    }
    
    mutating func updatePlannedAmount(_ newAmount: Decimal) {
        plannedAmount = newAmount
    }
    
}
