//
//  PeriodManager.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import Foundation

class PeriodManager: ObservableObject {
    @Published var currentPeriod: FinancialPeriod?
    @Published var periodConfiguration: PeriodConfiguration
    
    private let repository: PeriodRepository
    
    init(repository: PeriodRepository) {
        self.repository = repository
        // Carrega configuração inicial ou usa configuração padrão
        if let savedConfig = UserDefaults.standard.data(forKey: "PeriodConfiguration"),
           let config = try? JSONDecoder().decode(PeriodConfiguration.self, from: savedConfig) {
            self.periodConfiguration = config
        } else {
            self.periodConfiguration = PeriodConfiguration(startDay: 1,
                                                           duration: 30,
                                                           autoClose: false,
                                                           notifyBeforeEnd: false,
                                                           daysBeforeEndNotification: 0,
                                                           autoCarryOver: true,
                                                           requireConfirmation: false)
        }
        
        // Inicializa verificação de período
        Task { @MainActor in
            await initializeCurrentPeriod()
        }
    }
    
    @MainActor
    private func initializeCurrentPeriod() async {
        do {
            // Tenta carregar o período atual
            if let period = try await repository.fetchCurrentPeriod() {
                self.currentPeriod = period
            } else {
                // Se não houver período, cria um novo
                try await createNewPeriod()
            }
        } catch {
            print("Error initializing period: \(error)")
            // Em caso de erro, tenta criar um novo período
            try? await createNewPeriod()
        }
    }
    
    @MainActor
    func createNewPeriod() async throws {
        let config = periodConfiguration
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = config.startDay
        
        guard let startDate = calendar.date(from: components),
              let endDate = calendar.date(byAdding: .day, value: config.duration, to: startDate) else {
            throw PeriodRepositoryError.invalidDates
        }
        
        // Se a data de início já passou, avança para o próximo mês
        if startDate < now {
            components.month = (components.month ?? 1) + 1
            guard let adjustedStartDate = calendar.date(from: components),
                  let adjustedEndDate = calendar.date(byAdding: .day, value: config.duration, to: adjustedStartDate) else {
                throw PeriodRepositoryError.invalidDates
            }
            
            try await createAndSavePeriod(startDate: adjustedStartDate, endDate: adjustedEndDate)
        } else {
            try await createAndSavePeriod(startDate: startDate, endDate: endDate)
        }
    }
    
    private func createAndSavePeriod(startDate: Date, endDate: Date) async throws {
        let newPeriod = FinancialPeriod(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            isActive: true,
            isClosed: false,
            costGroupIDs: [],
            carryOverStatus: .pending,
            plannedTotal: 0,
            confirmedTotal: 0,
            launchedTotal: 0
        )
        
        try await repository.savePeriod(newPeriod)
        await MainActor.run {
            self.currentPeriod = newPeriod
        }
    }
}
