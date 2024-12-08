//
//  PeriodRepository.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//


protocol PeriodRepository {
    func fetchCurrentPeriod() async throws -> FinancialPeriod?
    func fetchAllPeriods() async throws -> [FinancialPeriod]
    func savePeriod(_ period: FinancialPeriod) async throws
    func updatePeriod(_ period: FinancialPeriod) async throws
    func deletePeriod(_ period: FinancialPeriod) async throws
}