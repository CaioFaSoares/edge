//
//  RecurrenceType.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

// frequencia dos custos recorrentes
enum RecurrenceType: Codable {
    case none
    case daily(businessDaysOnly: Bool)
    case weekly(daysOfWeek: Set<Int>)
    case custom(specificDates: Set<Int>)
}
