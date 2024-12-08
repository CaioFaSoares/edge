//
//  PeriodConfigurationManager.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

class PeriodConfigurationManager {
    private enum StorageKey {
        static let configuration = "copland.edge.storage.periodConfiguration"
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func loadConfiguration() -> PeriodConfiguration {
        guard let data = defaults.data(forKey: StorageKey.configuration),
              let config = try? JSONDecoder().decode(PeriodConfiguration.self, from: data) else {
            return .default
        }
        return config
    }
    
    func saveConfiguration(_ configuration: PeriodConfiguration) throws {
        // Validar antes de salvar
        let validation = configuration.validate()
        guard validation.isValid else {
            throw PeriodRepositoryError.invalidConfiguration
        }
        
        let data = try JSONEncoder().encode(configuration)
        defaults.set(data, forKey: StorageKey.configuration)
        
        if !defaults.synchronize() {
            throw CostRepositoryError.saveFailed
        }
    }
}
