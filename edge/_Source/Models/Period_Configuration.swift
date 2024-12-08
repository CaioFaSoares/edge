//
//  Period_Configuration.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

struct PeriodConfiguration: Codable {
    var closingDay: Int  // Dia do mês que o período fecha/renova
    
    // Validação simplificada
    func validate() -> ValidationResult {
        var errors: [ValidationError] = []
        
        if closingDay < 1 || closingDay > 28 {
            errors.append(.init(
                field: "closingDay",
                message: "O dia de fechamento deve estar entre 1 e 28"
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
