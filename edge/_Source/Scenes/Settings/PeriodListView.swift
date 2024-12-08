//
//  PeriodListView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct PeriodListView: View {
    @ObservedObject var periodManager: PeriodManager
    
    var body: some View {
        List {
            if let currentPeriod = periodManager.currentPeriod {
                Section("Período Atual") {
                    PeriodRowView(period: currentPeriod, isCurrentPeriod: true)
                }
            }
            
            Section("Períodos Anteriores") {
                if periodManager.periods.isEmpty {
                    Text("Nenhum período anterior")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(periodManager.periods) { period in
                        NavigationLink {
                            PeriodDetailView(period: period)
                        } label: {
                            PeriodRowView(period: period, isCurrentPeriod: false)
                        }
                    }
                }
            }
        }
        .navigationTitle("Períodos")
    }
}
