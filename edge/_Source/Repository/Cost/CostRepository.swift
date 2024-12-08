//
//  CostRepository.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

protocol CostRepository {
    // Operações com CostGroup
    func fetchAllGroups() async throws -> [CostGroup]
    func saveGroup(_ group: CostGroup) async throws
    func deleteGroup(_ group: CostGroup) async throws
    func updateGroup(_ group: CostGroup) async throws
    
    // Operações com Cost
    func fetchCosts(for groupID: UUID) async throws -> [Cost]
    func saveCost(_ cost: Cost) async throws
    func deleteCost(_ cost: Cost) async throws
    func updateCost(_ cost: Cost) async throws
}
