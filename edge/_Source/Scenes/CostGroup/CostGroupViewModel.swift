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
    @Published var costs: [Cost] = []
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
}

// MARK:  Groups Logic
extension CostGroupViewModel {
    @MainActor
    private func loadCurrentPeriodGroups() {
        guard let currentPeriod = periodManager.currentPeriod else {
            costGroups = []
            return
        }
        
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
            await loadGroups()
        } catch {
            self.error = error as? GenericRepositoryError ?? .saveFailed
        }
    }
    
    @MainActor
    func removeCostGroup(_ group: CostGroup) async {
        do {
            try await repository.deleteGroup(group)
            if let index = costGroups.firstIndex(where: { $0.id == group.id }) {
                costGroups.remove(at: index)
            }
        } catch {
            self.error = error as? GenericRepositoryError ?? .deleteFailed
        }
    }
}

// MARK:  Costs Logic
extension CostGroupViewModel {
    @MainActor
    func loadCostsForGroup(_ groupID: UUID) async {
        do {
            costs = try await repository.fetchCosts(for: groupID)
        } catch {
            self.error = error as? GenericRepositoryError ?? .fetchFailed
        }
    }
    
    @MainActor
    func addCost(_ cost: Cost) async {
        do {
            try await repository.saveCost(cost)
            await loadCostsForGroup(cost.groupID)
            await updateGroupAmounts(groupID: cost.groupID)
        } catch {
            self.error = error as? GenericRepositoryError ?? .saveFailed
        }
    }
    
    @MainActor
    func updateCost(_ cost: Cost) async {
        do {
            print("Updating cost: \(cost.id)")
            try await repository.updateCost(cost)
            print("Cost updated, reloading costs for group: \(cost.groupID)")
            await loadCostsForGroup(cost.groupID)
            await updateGroupAmounts(groupID: cost.groupID)
            print("Costs reloaded, new count: \(costs.count)")
        } catch {
            print("Error updating cost: \(error)")
            self.error = error as? GenericRepositoryError ?? .updateFailed
        }
    }
}

// MARK:  Series Logic
extension CostGroupViewModel {
    @MainActor
    func saveCostSeries(_ cost: Cost, untilDate: Date) async throws {
        do {
            let seriesCosts = try cost.generateSeries(until: untilDate)
            try await repository.saveSeries(seriesCosts)
            await loadCostsForGroup(cost.groupID)
            await updateGroupAmounts(groupID: cost.groupID)
        } catch {
            self.error = error as? GenericRepositoryError ?? .saveFailed
            throw error
        }
    }
    
    @MainActor
    func updateFutureCosts(_ cost: Cost, newAmount: Decimal) async {
        do {
            try await repository.updateFutureCosts(cost, newAmount: newAmount)
            await loadCostsForGroup(cost.groupID)
        } catch {
            self.error = error as? GenericRepositoryError ?? .updateFailed
        }
    }
    
    @MainActor
    func fetchSeriesCosts(_ parentID: UUID) async {
        do {
            let serieCosts = try await repository.fetchSeriesCosts(parentID: parentID)
            // Você pode decidir onde armazenar estes custos da série
            // Por exemplo, adicionar uma nova @Published var para isso
            self.selectedGroupCosts = serieCosts
        } catch {
            self.error = error as? GenericRepositoryError ?? .fetchFailed
        }
    }
}

extension CostGroupViewModel {
    @MainActor
    func updateGroupAmounts(groupID: UUID) async {
        // Pega todos os custos do grupo
        let groupCosts = costs
        
        // O plannedAmount não deve ser alterado aqui pois é o orçamento definido
        // para o grupo quando ele foi criado
        
        // Calcula apenas confirmed e launched
        var confirmedTotal: Decimal = 0
        var launchedTotal: Decimal = 0
        
        for cost in groupCosts {
            switch cost.state {
            case .planned:
                // Planejado não afeta nenhum total, pois é apenas uma intenção
                continue
            case .confirmed:
                // Confirmado representa compromissos assumidos
                confirmedTotal += cost.amount
            case .launched:
                // Lançado representa o que já foi efetivamente gasto
                confirmedTotal += cost.amount
                launchedTotal += cost.amount
            }
        }
        
        // Encontra e atualiza o grupo
        if let index = costGroups.firstIndex(where: { $0.id == groupID }) {
            var updatedGroup = costGroups[index]
            // Mantém o plannedAmount original
            updatedGroup.updateConfirmedAmount(confirmedTotal)
            updatedGroup.updateLaunchedAmount(launchedTotal)
            
            // Salva o grupo atualizado
            do {
                try await repository.updateGroup(updatedGroup)
                costGroups[index] = updatedGroup
            } catch {
                print("Error updating group amounts: \(error)")
            }
        }
    }
}
