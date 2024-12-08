//
//  CostGroupViewModel.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

class CostGroupViewModel: ObservableObject {
    @Published var costGroups: [CostGroup] = []
    @Published var selectedGroupCosts: [Cost] = []
    @Published var isLoading = false
    @Published var error: GenericRepositoryError?
    
    private let repository: CostRepository
    private let periodManager: PeriodManager
    
    init(repository: CostRepository, periodManager: PeriodManager) {
        self.repository = repository
        self.periodManager = periodManager
        
        Task {
            await loadCurrentPeriodGroups()
        }
    }
    
    @MainActor
    private func loadCurrentPeriodGroups() {
        guard let currentPeriod = periodManager.currentPeriod else {
            // Não há período ativo
            costGroups = []
            return
        }
        
        // Carregar apenas os grupos do período atual
        Task {
            do {
                let allGroups = try await repository.fetchAllGroups()
                costGroups = allGroups.filter { currentPeriod.costGroupIDs.contains($0.id) }
            } catch {
                self.error = error as? GenericRepositoryError ?? .fetchFailed
            }
        }
    }
    
    @MainActor
    func loadGroups() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            costGroups = try await repository.fetchAllGroups()
        } catch {
            self.error = error as? GenericRepositoryError ?? .fetchFailed
        }
    }
    
    @MainActor
    func addCostGroup(_ group: CostGroup) async {
        do {
            try await repository.saveGroup(group)
            await loadGroups()  // Recarrega para ter a lista atualizada
        } catch {
            self.error = error as? GenericRepositoryError ?? .saveFailed
        }
    }
    
    @MainActor
    func removeCostGroup(_ group: CostGroup) async {
        do {
            try await repository.deleteGroup(group)
            // After successful deletion, update the local array
            if let index = costGroups.firstIndex(where: { $0.id == group.id }) {
                costGroups.remove(at: index)
            }
        } catch {
            self.error = error as? GenericRepositoryError ?? .deleteFailed
        }
    }
    
    @MainActor
    func loadCosts(for group: CostGroup) async {
        do {
            selectedGroupCosts = try await repository.fetchCosts(for: group.id)
        } catch {
            // Handle error appropriately
            print("Failed to load costs: \(error.localizedDescription)")
            selectedGroupCosts = []
        }
    }
    

}
