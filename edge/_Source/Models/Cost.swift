//
//  Cost.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

struct Cost: Identifiable, Codable {
    
    // identity
    let id: UUID
    let groupID: UUID
    
    // monetary info
    var amount: Decimal
    var state: CostState
    
    // data
    var date: Date
    var description: String
    var recurrence: RecurrenceType?
    
    // referencia p/ séries
    var parentCostID: UUID?
    var childCostIDs: [UUID]
    
    // Inicializador completo para a factory
    init(
        id: UUID = UUID(),           // Permite injetar UUID para testes
        groupID: UUID,               // Obrigatório
        amount: Decimal,             // Obrigatório
        state: CostState = .planned, // Valor padrão
        date: Date = Date(),         // Valor padrão
        description: String,         // Obrigatório
        recurrence: RecurrenceType? = nil,    // Opcional
        parentCostID: UUID? = nil,   // Opcional
        childCostIDs: [UUID] = []    // Valor padrão array vazio
    ) {
        self.id = id
        self.groupID = groupID
        self.amount = amount
        self.state = state
        self.date = date
        self.description = description
        self.recurrence = recurrence
        self.parentCostID = parentCostID
        self.childCostIDs = childCostIDs
    }
    
    // Inicializador conveniente para custos simples (mantemos o que você já tinha)
    init(groupID: UUID, amount: Decimal, description: String) {
        self.groupID = groupID
        self.amount = amount
        self.description = description
        
        self.id = UUID()
        self.state = .planned
        self.date = Date()
        self.childCostIDs = []
    }
}


