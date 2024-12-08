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
    
    func fetchAllGroups() async throws -> [CostGroup] {
        guard let data = defaults.data(forKey: StorageKey.groups),
              let groups = try? JSONDecoder().decode([CostGroup].self, from: data) else {
            return []
        }
        return groups
    }
    
    func saveGroup(_ group: CostGroup) async throws {
        var groups = try await fetchAllGroups()
        groups.append(group)
        
        let data = try JSONEncoder().encode(groups)
        defaults.set(data, forKey: StorageKey.groups)
        
        if !defaults.synchronize() {
            throw CostRepositoryError.saveFailed
        }
    }

    func deleteGroup(_ group: CostGroup) async throws {
        var groups = try await fetchAllGroups()
        
        groups.removeAll(where: { $0.id == group.id })
        try await deleteCostsForGroup(group.id)
        
        let data = try JSONEncoder().encode(groups)
        defaults.set(data, forKey: StorageKey.groups)
        
        if !defaults.synchronize() {
            throw CostRepositoryError.saveFailed
        }
    }
    
    private func deleteCostsForGroup(_ groupID: UUID) async throws {
        // Get all costs
        var allCosts = try getAllCosts()
        
        // Remove costs for the deleted group
        allCosts.removeValue(forKey: groupID.uuidString)
        
        // Save updated costs
        try saveAllCosts(allCosts)
    }
    
    func updateGroup(_ group: CostGroup) async throws {
        var groups = try await fetchAllGroups()
        
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { throw CostRepositoryError.updateFailed }
        groups[index] = group
        
        let data = try JSONEncoder().encode(groups)
        defaults.set(data, forKey: StorageKey.groups)
        
        if !defaults.synchronize() {
            throw CostRepositoryError.saveFailed
        }
    }
    
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
            throw CostRepositoryError.saveFailed
        }
    }
    
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
            throw CostRepositoryError.saveFailed
        }
    }
    
    func updateCost(_ cost: Cost) async throws {
        var allCosts: [String: [Cost]] = [:]
        
        if let data = defaults.data(forKey: StorageKey.costs),
           let decoded = try? JSONDecoder().decode([String:[Cost]].self, from: data) {
            allCosts = decoded
        }
        
        let groupKey = cost.groupID.uuidString
        
        var groupCosts = allCosts[groupKey] ?? []
        
        guard let index = groupCosts.firstIndex(where: { $0.id == cost.id }) else { throw CostRepositoryError.updateFailed}
        groupCosts[index] = cost
        
        let data = try JSONEncoder().encode(allCosts)
        defaults.set(data,forKey: StorageKey.costs)
        
        if !defaults.synchronize() {
            throw CostRepositoryError.saveFailed
        }
    }
    
}

extension UserDefaultsCostRepository {
    // Helper method to get all costs
    private func getAllCosts() throws -> [String: [Cost]] {
        guard let data = defaults.data(forKey: StorageKey.costs),
              let allCosts = try? JSONDecoder().decode([String: [Cost]].self, from: data) else {
            return [:]
        }
        return allCosts
    }
    
    // Helper method to save all costs
    private func saveAllCosts(_ costs: [String: [Cost]]) throws {
        let encodedData = try JSONEncoder().encode(costs)
        defaults.set(encodedData, forKey: StorageKey.costs)
        
        if !defaults.synchronize() {
            throw CostRepositoryError.saveFailed
        }
    }
}


