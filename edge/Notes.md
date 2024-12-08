# Mudanças

07 dec 2024
- em cost, mudei "groupId" p/ "groupID"
- em recurrencyType, mudei monthly p/ case custom(specificDates: Set<Int>)
- em costGroup, desabilitei progress
- em costError:
```swift
    // tenta transicionar o estado do custo
    mutating func transition(to newState: CostState) throws {
        guard state.canTransitionTo(newState) else {
            throw CostError.invalidTransition(from: state, to: newState)
        }
    }
    
}

enum CostError: Error {
    case invalidTransition(from: CostState, to: CostState)
    case invalidAmount
    case invalidGroup
}
```

