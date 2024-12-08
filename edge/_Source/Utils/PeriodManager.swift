//
//  PeriodManager.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

class PeriodManager: ObservableObject {
    @Published var currentPeriod: Period?
    @Published var periods: [Period] = []
    @Published var periodConfiguration: PeriodConfiguration
    
    private let repository: PeriodRepository
    
    init(repository: PeriodRepository) {
        self.repository = repository
        // Carrega configuração ou usa padrão
        if let savedConfig = UserDefaults.standard.data(forKey: "PeriodConfiguration"),
           let config = try? JSONDecoder().decode(PeriodConfiguration.self, from: savedConfig) {
            self.periodConfiguration = config
        } else {
            // Dia 5 como padrão
            self.periodConfiguration = PeriodConfiguration(closingDay: 5)
        }
        
        Task { @MainActor in
            await initializeCurrentPeriod()
            await loadPeriods()
        }
    }
    
    func loadPeriods() async {
        do {
            let loadedPeriods = try await repository.fetchAllPeriods()
            await MainActor.run {
                self.periods = loadedPeriods.sorted { $0.startDate > $1.startDate }
            }
        } catch {
            print("Error loading periods: \(error)")
        }
    }
    
    @MainActor
    private func initializeCurrentPeriod() async {
        do {
            if let period = try await repository.fetchCurrentPeriod() {
                self.currentPeriod = period
            } else {
                try await createNewPeriod()
            }
        } catch {
            print("Error initializing period: \(error)")
            try? await createNewPeriod()
        }
    }
    
    @MainActor
    func createNewPeriod() async throws {
        let calendar = Calendar.current
        let now = Date()
        
        // Calcula a data de início e fim baseado no dia de fechamento
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = periodConfiguration.closingDay
        
        guard let startDate = calendar.date(from: components) else {
            throw PeriodRepositoryError.invalidDates
        }
        
        // Se a data de início já passou, avança para o próximo mês
        var finalStartDate = startDate
        if startDate < now {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: startDate) else {
                throw PeriodRepositoryError.invalidDates
            }
            finalStartDate = nextMonth
        }
        
        // Data de fim é o dia anterior ao fechamento do próximo mês
        guard let endDate = calendar.date(byAdding: .month, value: 1, to: finalStartDate),
              let finalEndDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            throw PeriodRepositoryError.invalidDates
        }
        
        let newPeriod = Period(
            id: UUID(),
            startDate: finalStartDate,
            endDate: finalEndDate,
            isActive: true,
            costGroupIDs: [],
            plannedTotal: 0,
            confirmedTotal: 0,
            launchedTotal: 0
        )
        
        try await repository.savePeriod(newPeriod)
        self.currentPeriod = newPeriod
    }
}
