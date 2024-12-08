//
//  FinancialPeriod.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

struct FinancialPeriod: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var isClosed: Bool
    
    // Referência aos grupos de custo deste período
    var costGroupIDs: [UUID]
    
    // Status do carry over (transição entre períodos)
    var carryOverStatus: CarryOverStatus
    
    // Valores do período
    var plannedTotal: Decimal
    var confirmedTotal: Decimal
    var launchedTotal: Decimal
}
