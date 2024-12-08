//
//  RecurrenceType.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

// frequencia dos custos recorrentes
enum RecurrenceType: Codable, Equatable, Hashable {
    case none
    case daily(businessDaysOnly: Bool)
    case weekly(daysOfWeek: Set<Int>) // 1 = domingo, 7 = sábado
    case custom(specificDates: Set<Int>) // dias do mês (1-31)
    
    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            switch self {
            case .none:
                return [startDate]
                
            case .daily(let businessDaysOnly):
                if !businessDaysOnly || isBusinessDay(currentDate) {
                    dates.append(currentDate)
                }
                
            case .weekly(let daysOfWeek):
                let weekday = calendar.component(.weekday, from: currentDate)
                if daysOfWeek.contains(weekday) {
                    dates.append(currentDate)
                }
                
            case .custom(let specificDates):
                let dayOfMonth = calendar.component(.day, from: currentDate)
                if specificDates.contains(dayOfMonth) {
                    dates.append(currentDate)
                }
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }
        
        return dates
    }
    
    private func isBusinessDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // 1 = domingo, 7 = sábado
        return weekday != 1 && weekday != 7
    }
}
