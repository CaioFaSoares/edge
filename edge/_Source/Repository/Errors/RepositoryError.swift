//
//  RepositoryError.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//


enum RepositoryError: Error {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case updateFailed
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .saveFailed: return "Não foi possível salvar os dados"
        case .fetchFailed: return "Não foi possível carregar os dados"
        case .deleteFailed: return "Não foi possível excluir os dados"
        case .updateFailed: return "Não foi possível atualizar os dados"
        case .invalidData: return "Dados inválidos"
        }
    }
}

