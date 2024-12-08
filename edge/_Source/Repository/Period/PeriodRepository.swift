//
//  PeriodRepository.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//


protocol PeriodRepository {
    func fetchCurrentPeriod() async throws -> Period?
    func fetchAllPeriods() async throws -> [Period]
    func savePeriod(_ period: Period) async throws
    func updatePeriod(_ period: Period) async throws
    func deletePeriod(_ period: Period) async throws
}
