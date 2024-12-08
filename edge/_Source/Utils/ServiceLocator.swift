//
//  ServiceLocator.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//


// Service Locator que gerencia nossas dependências
class ServiceLocator {
    static let shared = ServiceLocator()
    
    private var services: [String: Any] = [:]
    
    private init() {
        // Registramos nossos serviços padrão
        registerDefaults()
    }
    
    private func registerDefaults() {
        // Registra a implementação padrão do repositório
        register(CostRepository.self) { UserDefaultsCostRepository() }
    }
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        services[String(describing: type)] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = services[key] as? () -> T else {
            fatalError("Serviço \(key) não registrado")
        }
        return factory()
    }
}

extension ServiceLocator {
    static func registerServices() {
        shared.register(PeriodRepository.self) { UserDefaultsPeriodRepository() }
        shared.register(PeriodManager.self) {
            PeriodManager(repository: shared.resolve(PeriodRepository.self))
        }
    }
}
