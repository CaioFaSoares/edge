//
//  FinancialPeriod.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

struct Period: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    var isActive: Bool
    var costGroupIDs: [UUID]
    
    // Valores do período
    var plannedTotal: Decimal
    var confirmedTotal: Decimal
    var launchedTotal: Decimal
}
