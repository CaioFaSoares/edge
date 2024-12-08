//
//  Period_Configuration.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

struct PeriodConfiguration: Codable {
    
    var startDay: Int
    var duration: Int
    var autoClose: Bool
    
    var notifyBeforeEnd: Bool
    var daysBeforeEndNotification: Int
    
    var autoCarryOver: Bool
    var requireConfirmation: Bool
    
    static let `default` = PeriodConfiguration(
        startDay: 1,
        duration: 30,
        autoClose: false,
        notifyBeforeEnd: false,
        daysBeforeEndNotification: 7,
        autoCarryOver: false,
        requireConfirmation: false
    )
    
    func validate() -> ValidationResult {
        var errors: [ValidationError] = []
        
        if startDay < 1 || startDay > 28 {
            errors.append(.init(
                field: "startDay",
                message: "O dia de início deve estar entre 1 e 28"
            ))
        }
        
        if duration < 28 || duration > 31 {
            errors.append(.init(
                field: "duration",
                message: "A duração deve estar entre 28 e 31 dias"
            ))
        }
        
        if daysBeforeEndNotification >= duration {
            errors.append(.init(
                field: "daysBeforeEndNotification",
                message: "Os dias de notificação devem ser menores que a duração do período"
            ))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    struct ValidationError {
        let field: String
        let message: String
    }
    
    struct ValidationResult {
        let isValid: Bool
        let errors: [ValidationError]
    }
}
