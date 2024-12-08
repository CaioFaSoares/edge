//
//  StatusBadge.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

// Badge para mostrar o status do custo
struct StatusBadge: View {
    let state: CostState
    
    var body: some View {
        Text(state.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(state.color.opacity(0.2))
            .foregroundStyle(state.color)
            .clipShape(Capsule())
    }
}
