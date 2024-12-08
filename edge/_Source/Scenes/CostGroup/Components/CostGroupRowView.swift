//
//  CostGroupRowView.swift
//  edge
//
//  Created by Caio Soares on 07/12/24.
//

import SwiftUI

// Esta view representa uma linha na nossa lista de grupos
struct CostGroupRowView: View {
    let group: CostGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group.name)
                .font(.headline)
            
            HStack {
                // Mostramos os valores planejados e lançados
                VStack(alignment: .leading) {
                    Text("Planejado: \(group.plannedAmount as NSDecimalNumber)")
                        .font(.subheadline)
                    Text("Lançado: \(group.launchedAmount as NSDecimalNumber)")
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Ícones para indicar configurações do grupo
                if group.isRecurrent {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                if group.isQuickGroup {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
