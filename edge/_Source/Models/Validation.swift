//
//  Validation.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

protocol Validatable {
    func validate() -> ValidationResult
}

struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    
    struct ValidationError: Identifiable {
        let id = UUID()
        let message: String
        let severity: Severity
        
        enum Severity {
            case warning
            case error
        }
    }
}

extension CostGroup: Validatable {
    func validate() -> ValidationResult {
        var errors: [ValidationResult.ValidationError] = []
        
        if plannedAmount <= 0 {
            errors.append(.init(
                message: "Valor planejado deve ser maior que zero.",
                severity: .error
            ))
        }
        
        if name.isEmpty {
            errors.append(.init(
                message: "É obrigatório inserior um nome para o grupo.",
                severity: .error
            ))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
