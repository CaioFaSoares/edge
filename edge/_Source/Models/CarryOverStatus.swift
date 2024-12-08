//
//  CarryOverStatus.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

enum CarryOverStatus: Codable {
    case pending
    case completed(amount: Decimal)
    case adjusted(originalAmount: Decimal, adjustedAmount: Decimal, reason: String)
}
