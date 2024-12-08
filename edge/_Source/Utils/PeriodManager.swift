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
    
    @MainActor
    func createFirstPeriod(startDate: Date, closingDay: Int) async throws {
        // Salvar a configuração
        let newConfig = PeriodConfiguration(closingDay: closingDay)
        self.periodConfiguration = newConfig
        if let encoded = try? JSONEncoder().encode(newConfig) {
            UserDefaults.standard.set(encoded, forKey: "PeriodConfiguration")
        }
        
        // Calcular a data final baseada no dia de fechamento
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: startDate)
        components.day = closingDay
        
        guard let endDate = calendar.date(from: components) else {
            throw PeriodRepositoryError.invalidDates
        }
        
        // Se o dia de fechamento for antes da data inicial, avançar para o próximo mês
        let finalEndDate = startDate < endDate ? endDate : calendar.date(byAdding: .month, value: 1, to: endDate) ?? endDate
        
        let newPeriod = Period(
            id: UUID(),
            startDate: startDate,
            endDate: finalEndDate,
            isActive: true,
            costGroupIDs: [],
            plannedTotal: 0,
            confirmedTotal: 0,
            launchedTotal: 0
        )
        
        try await repository.savePeriod(newPeriod)
        self.currentPeriod = newPeriod
        await loadPeriods()
    }
}

// Atualização do dia de fechamento
extension PeriodManager {
    @MainActor
    func updateClosingDay(_ newClosingDay: Int) async throws {
        // Validar o novo dia
        guard newClosingDay >= 1 && newClosingDay <= 28 else {
            throw PeriodRepositoryError.invalidConfiguration
        }
        
        // Salvar nova configuração
        let newConfig = PeriodConfiguration(closingDay: newClosingDay)
        self.periodConfiguration = newConfig
        if let encoded = try? JSONEncoder().encode(newConfig) {
            UserDefaults.standard.set(encoded, forKey: "PeriodConfiguration")
        }
        
        // Recalcular períodos
        try await recalculateAllPeriods(newClosingDay: newClosingDay)
    }
    
    @MainActor
    private func recalculateAllPeriods(newClosingDay: Int) async throws {
        let calendar = Calendar.current
        let now = Date()
        
        // Calcular o período atual primeiro
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = newClosingDay
        
        guard let baseDate = calendar.date(from: components) else {
            throw PeriodRepositoryError.invalidDates
        }
        
        // Determinar a data de início do período atual
        let periodStartDate: Date
        let periodEndDate: Date
        
        if baseDate > now {
            // Se o dia de fechamento ainda não chegou, usamos o mês atual
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: baseDate) else {
                throw PeriodRepositoryError.invalidDates
            }
            periodStartDate = previousMonth
            periodEndDate = baseDate
        } else {
            // Se já passou, usamos o próximo mês
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: baseDate) else {
                throw PeriodRepositoryError.invalidDates
            }
            periodStartDate = baseDate
            periodEndDate = nextMonth
        }
        
        // Criar novo período atual
        let newCurrentPeriod = Period(
            id: UUID(),
            startDate: periodStartDate,
            endDate: periodEndDate,
            isActive: true,
            costGroupIDs: currentPeriod?.costGroupIDs ?? [],
            plannedTotal: currentPeriod?.plannedTotal ?? 0,
            confirmedTotal: currentPeriod?.confirmedTotal ?? 0,
            launchedTotal: currentPeriod?.launchedTotal ?? 0
        )
        
        // Limpar períodos antigos
        try await repository.deleteAllPeriods()
        
        // Salvar novo período
        try await repository.savePeriod(newCurrentPeriod)
        
        // Atualizar estado
        self.currentPeriod = newCurrentPeriod
        await loadPeriods()
    }
}
