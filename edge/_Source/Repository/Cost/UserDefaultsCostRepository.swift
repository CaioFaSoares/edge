//
//  UserDefaultsRepository.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

class UserDefaultsCostRepository: CostRepository {
    private enum StorageKey {
        static let groups = "copland.edge.storage.groups"
        static let costs = "copland.edge.storage.costs"
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}

// MARK: Cost Logic
extension UserDefaultsCostRepository {
    
    //fetch all
    private func getAllCosts() throws -> [String: [Cost]] {
        guard let data = defaults.data(forKey: StorageKey.costs),
              let allCosts = try? JSONDecoder().decode([String: [Cost]].self, from: data) else {
            return [:]
        }
        return allCosts
    }
    
    //fetch for id
    func fetchCosts(for groupID: UUID) async throws -> [Cost] {
        guard let data = defaults.data(forKey: StorageKey.costs) else {
            return []
        }
        
        do {
            let allCosts = try JSONDecoder().decode([String: [Cost]].self, from: data)
            let groupKey = groupID.uuidString
            return allCosts[groupKey] ?? []
        }
    }
    
    //update for cost
    func updateCost(_ cost: Cost) async throws {
        var allCosts: [String: [Cost]] = [:]
        
        if let data = defaults.data(forKey: StorageKey.costs),
           let decoded = try? JSONDecoder().decode([String:[Cost]].self, from: data) {
            allCosts = decoded
        }
        
        let groupKey = cost.groupID.uuidString
        
        // Pegamos os custos do grupo
        var groupCosts = allCosts[groupKey] ?? []
        
        // Encontramos e atualizamos o custo
        guard let index = groupCosts.firstIndex(where: { $0.id == cost.id }) else {
            throw GenericRepositoryError.updateFailed
        }
        groupCosts[index] = cost
        
        // Importante: Atualizamos o dicionário com o array modificado
        allCosts[groupKey] = groupCosts
        
        // Salvamos o dicionário atualizado
        let data = try JSONEncoder().encode(allCosts)
        defaults.set(data, forKey: StorageKey.costs)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    //save all
    private func saveAllCosts(_ costs: [String: [Cost]]) throws {
        let encodedData = try JSONEncoder().encode(costs)
        defaults.set(encodedData, forKey: StorageKey.costs)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    //save for cost
    func saveCost(_ cost: Cost) async throws {
        var allCosts: [String: [Cost]] = [:]
        
        if let data = defaults.data(forKey: StorageKey.costs),
           let decoded = try? JSONDecoder().decode([String: [Cost]].self, from: data) {
            allCosts = decoded
        }
        
        let groupKey = cost.groupID.uuidString
        
        var groupCosts = allCosts[groupKey] ?? []
        
        groupCosts.append(cost)
        
        allCosts[groupKey] = groupCosts
        
        let data = try JSONEncoder().encode(allCosts)
        defaults.set(data, forKey: StorageKey.costs)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    //delete for cost
    func deleteCost(_ cost: Cost) async throws {
        var allCosts: [String: [Cost]] = [:]
        
        if let data = defaults.data(forKey: StorageKey.costs),
           let decoded = try? JSONDecoder().decode([String:[Cost]].self, from: data) {
            allCosts = decoded
        }
        
        let groupKey = cost.groupID.uuidString
        
        var groupCosts = allCosts[groupKey] ?? []
        
        groupCosts.removeAll(where: { $0.id == cost.id })
        
        let data = try JSONEncoder().encode(allCosts)
        defaults.set(data,forKey: StorageKey.costs)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    //delete cost for group
    private func deleteCostsForGroup(_ groupID: UUID) async throws {
        // Get all costs
        var allCosts = try getAllCosts()
        
        // Remove costs for the deleted group
        allCosts.removeValue(forKey: groupID.uuidString)
        
        // Save updated costs
        try saveAllCosts(allCosts)
    }
    
}

// MARK: CostGroup Logic
extension UserDefaultsCostRepository {
    // fetch all
    func fetchAllGroups() async throws -> [CostGroup] {
        guard let data = defaults.data(forKey: StorageKey.groups),
              let groups = try? JSONDecoder().decode([CostGroup].self, from: data) else {
            return []
        }
        return groups
    }
    
    // update for group
    func updateGroup(_ group: CostGroup) async throws {
        var groups = try await fetchAllGroups()
        
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { throw GenericRepositoryError.updateFailed }
        groups[index] = group
        
        let data = try JSONEncoder().encode(groups)
        defaults.set(data, forKey: StorageKey.groups)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    // save for group
    func saveGroup(_ group: CostGroup) async throws {
        var groups = try await fetchAllGroups()
        groups.append(group)
        
        let data = try JSONEncoder().encode(groups)
        defaults.set(data, forKey: StorageKey.groups)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }

    // delete for group
    func deleteGroup(_ group: CostGroup) async throws {
        var groups = try await fetchAllGroups()
        
        groups.removeAll(where: { $0.id == group.id })
        try await deleteCostsForGroup(group.id)
        
        let data = try JSONEncoder().encode(groups)
        defaults.set(data, forKey: StorageKey.groups)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
}

// MARK: Series Logic
extension UserDefaultsCostRepository {
    // save series of costs
    func saveSeries(_ costs: [Cost]) async throws {
        guard !costs.isEmpty else { return }
        
        var allCosts = try getAllCosts()
        
        // Agrupamos os custos por groupID para manter a estrutura do dicionário
        for cost in costs {
            let groupKey = cost.groupID.uuidString
            var groupCosts = allCosts[groupKey] ?? []
            
            // Se o custo já existe, atualizamos
            if let index = groupCosts.firstIndex(where: { $0.id == cost.id }) {
                groupCosts[index] = cost
            } else {
                groupCosts.append(cost)
            }
            
            allCosts[groupKey] = groupCosts
        }
        
        try saveAllCosts(allCosts)
    }
    
    // update series of future costs
    func updateFutureCosts(_ fromCost: Cost, newAmount: Decimal) async throws {
        var allCosts = try getAllCosts()
        let now = Date()
        let groupKey = fromCost.groupID.uuidString
        
        // Pegamos os custos do grupo específico
        guard var groupCosts = allCosts[groupKey] else {
            throw GenericRepositoryError.updateFailed
        }
        
        // Identifica os custos da série (pai ou filhos)
        let parentID = fromCost.parentCostID ?? fromCost.id
        
        // Atualiza custos futuros da série
        for index in 0..<groupCosts.count {
            let cost = groupCosts[index]
            if (cost.id == parentID || cost.parentCostID == parentID) && cost.date > now {
                var updatedCost = cost
                updatedCost.amount = newAmount
                groupCosts[index] = updatedCost
            }
        }
        
        allCosts[groupKey] = groupCosts
        try saveAllCosts(allCosts)
    }
    
    // fetch series of costs for parent id
    func fetchSeriesCosts(parentID: UUID) async throws -> [Cost] {
        let allCosts = try getAllCosts()
        var serieCosts: [Cost] = []
        
        // Procura em todos os grupos por custos da série
        for groupCosts in allCosts.values {
            let filteredCosts = groupCosts.filter {
                $0.id == parentID || $0.parentCostID == parentID
            }
            serieCosts.append(contentsOf: filteredCosts)
        }
        
        return serieCosts.sorted { $0.date < $1.date }
    }
}
