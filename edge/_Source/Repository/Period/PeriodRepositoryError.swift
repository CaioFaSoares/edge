//
//  PeriodError.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//


enum PeriodRepositoryError: Error {
    case invalidDates
    case periodOverlap
    case noActivePeriod
    case periodAlreadyExists
    case cannotDeleteActivePeriod
    case invalidConfiguration
}
