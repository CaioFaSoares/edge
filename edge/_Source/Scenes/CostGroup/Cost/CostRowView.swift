//
//  CostRowView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct CostRowView: View {
    let cost: Cost
    let isPartOfSeries: Bool
    @ObservedObject var viewModel: CostGroupViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(cost.description)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text((cost.amount as NSDecimalNumber) as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "brl"))
                }
                
                HStack {
                    Text(cost.date.formatted(.dateTime.day().month()))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if isPartOfSeries {
                        SeriesBadge(isChild: cost.parentCostID != nil)
                            .padding(.trailing, 4)
                    }
                    
                    StatusBadge(state: cost.state)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingEditSheet) {
            EditCostView(viewModel: viewModel, cost: cost)
        }
    }
}
