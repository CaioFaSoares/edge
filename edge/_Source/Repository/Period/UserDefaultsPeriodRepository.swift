//
//  UserDefaultsPeriodRepository.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

class UserDefaultsPeriodRepository: PeriodRepository {
    private enum StorageKey {
        static let periods = "copland.edge.storage.periods"
        static let currentPeriod = "copland.edge.storage.currentPeriod"
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
        
    func fetchCurrentPeriod() async throws -> Period? {
        guard let data = defaults.data(forKey: StorageKey.currentPeriod),
              let period = try? JSONDecoder().decode(Period.self, from: data) else {
                  return nil
              }
        return period
    }
    
    func fetchAllPeriods() async throws -> [Period] {
        guard let data = defaults.data(forKey: StorageKey.periods),
              let periods = try? JSONDecoder().decode([Period].self, from: data) else {
            return []
        }
        return periods
    }
 
    func savePeriod(_ period: Period) async throws {
        var periods = try await fetchAllPeriods()
        
        if periods.contains(where: {
            $0.startDate < period.startDate && period.startDate < $0.endDate
        }) {
            throw PeriodRepositoryError.periodOverlap
        }
        
        periods.append(period)
        
        let data = try JSONEncoder().encode(periods)
        defaults.set(data, forKey: StorageKey.periods)
        
        if period.isActive {
            let currentPeriodData = try JSONEncoder().encode(period)
            defaults.set(currentPeriodData, forKey: StorageKey.currentPeriod)
        }
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    func updatePeriod(_ period: Period) async throws {
//        var periods = try await fetchAllPeriods()
//        
//        guard let index = periods.firstIndex(where: { $0.id == period.id }) else {
//            throw PeriodRepositoryError.periodNotFound
//        }
//        
//        let otherPeriods = periods.filter { $0.id != period.id }
//        let hasOverlap = otherPeriods.contains { existingPeriod in
//            period.startDate < existingPeriod.endDate && existingPeriod.startDate < period.endDate
//        }
//        
//        if hasOverlap {
//            
//        }
    }
    
    func deletePeriod(_ period: Period) async throws {
        // Não permitir deletar o período ativo
        if period.isActive {
            throw PeriodRepositoryError.cannotDeleteActivePeriod
        }
        
        // Buscar todos os períodos
        var periods = try await fetchAllPeriods()
        
        // Remover o período específico
        periods.removeAll { $0.id == period.id }
        
        // Salvar a lista atualizada
        let encodedData = try JSONEncoder().encode(periods)
        defaults.set(encodedData, forKey: StorageKey.periods)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    func deleteAllPeriods() async throws {
        var periods = try await fetchAllPeriods()
        
        if periods.isEmpty {
            throw PeriodRepositoryError.periodIsEmpty
        }
        
        periods.removeAll()
        
        let data = try JSONEncoder().encode(periods)
        defaults.set(data, forKey: StorageKey.periods)
        
        if !defaults.synchronize() {
            throw GenericRepositoryError.saveFailed
        }
    }
    
    
}
