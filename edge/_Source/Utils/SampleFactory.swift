//
//  SampleFactory.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

enum SampleData {
    static func createSampleCosts(for groupID: UUID) -> [Cost] {
        [
            // Exemplo de custo recorrente planejado
            Cost(
                groupID: groupID,
                amount: 20.00,
                state: .planned,
                date: Date().addingTimeInterval(86400), // Amanhã
                description: "Almoço",
                recurrence: .custom(specificDates: [1, 15, 30])
            ),
            
            // Exemplo de custo confirmado
            Cost(
                groupID: groupID,
                amount: 15.50,
                state: .confirmed,
                description: "Café da manhã"
                // Outros parâmetros assumem valores padrão
            ),
            
            // Exemplo de custo em série
            Cost(
                groupID: groupID,
                amount: 25.00,
                state: .launched,
                date: Date().addingTimeInterval(-86400), // Ontem
                description: "Jantar em série",
                recurrence: .custom(specificDates: [5, 10, 15, 20, 25, 30]),
                parentCostID: UUID(), // Custo pai para exemplo
                childCostIDs: [UUID(), UUID()] // Alguns custos filhos para exemplo
            )
        ]
    }
}

extension SampleData {
    // Cria um custo recorrente
    static func createRecurringCost(groupID: UUID) -> Cost {
        Cost(
            groupID: groupID,
            amount: 30.00,
            description: "Custo Recorrente",
            recurrence: .custom(specificDates: [1, 15])
        )
    }
    
    // Cria uma série de custos relacionados
    static func createCostSeries(groupID: UUID, count: Int) -> [Cost] {
        let parentID = UUID()
        let parentCost = Cost(
            id: parentID,
            groupID: groupID,
            amount: 50.00,
            description: "Custo Pai",
            childCostIDs: [] // Será preenchido abaixo
        )
        
        var costs = [parentCost]
        var childIDs: [UUID] = []
        
        // Criar custos filhos
        for i in 1..<count {
            let childID = UUID()
            childIDs.append(childID)
            
            let childCost = Cost(
                id: childID,
                groupID: groupID,
                amount: 50.00,
                description: "Custo Filho \(i)",
                parentCostID: parentID
            )
            costs.append(childCost)
        }
        
        // Atualizar o parentCost com os childIDs
        var updatedParent = parentCost
        updatedParent.childCostIDs = childIDs
        costs[0] = updatedParent
        
        return costs
    }
}

extension SampleData {
    // Função para criar um único grupo de exemplo
    static func createSingleGroup() -> CostGroup {
        CostGroup(
            id: UUID(),
            name: "Novo Grupo",
            plannedAmount: 100.00,
            confirmedAmount: nil,
            launchedAmount: 0,
            isRecurrent: false,
            isQuickGroup: false
        )
    }
    
    // Função para criar um grupo com valores específicos
    static func createCustomGroup(
        name: String,
        plannedAmount: Decimal,
        isRecurrent: Bool = false,
        isQuickGroup: Bool = false
    ) -> CostGroup {
        CostGroup(
            id: UUID(),
            name: name,
            plannedAmount: plannedAmount,
            confirmedAmount: nil,
            launchedAmount: 0,
            isRecurrent: isRecurrent,
            isQuickGroup: isQuickGroup
        )
    }
}
