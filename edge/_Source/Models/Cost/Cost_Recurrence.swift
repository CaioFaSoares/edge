//
//  Cost_Recurrence.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import Foundation

extension Cost {
    // Cria uma série de custos baseada na recorrência
    func generateSeries(until endDate: Date) throws -> [Cost] {
        guard let recurrence = recurrence else {
            throw CostError.notRecurrent
        }
        
        // Gera as datas baseadas na recorrência
        let dates = recurrence.generateDates(from: date, to: endDate)
        
        // Cria os custos para cada data
        return dates.map { date in
            Cost(
                groupID: self.groupID,
                amount: self.amount,
                state: .confirmed,  // Custos da série começam confirmados
                date: date,
                description: self.description,
                parentCostID: self.id  // Referência ao custo pai
            )
        }
    }
    
    // Atualiza todos os custos futuros em uma série
    mutating func updateFutureCosts(_ newAmount: Decimal) throws {
        guard !childCostIDs.isEmpty else {
            throw CostError.notPartOfSeries
        }
        
        // Lógica para atualizar custos futuros será implementada
        // no CostRepository, já que precisamos acessar outros custos
    }
}
