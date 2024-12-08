//
//  CreateCostSeriesView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct CreateCostSeriesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CostGroupViewModel
    let group: CostGroup
    
    // Form states
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var recurrenceType: RecurrenceType = .daily(businessDaysOnly: true)
    @State private var untilDate: Date = Date()
    
    // Error handling
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Informações básicas
                Section("Detalhes") {
                    TextField("Descrição", text: $description)
                    
                    TextField("Valor", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                // Configuração de recorrência
                Section("Recorrência") {
                    RecurrencePickerView(selection: $recurrenceType)
                    
                    DatePicker(
                        "Até",
                        selection: $untilDate,
                        displayedComponents: [.date]
                    )
                }
                
                // Preview da série
                if let previewDates = try? recurrenceType.generateDates(
                    from: Date(),
                    to: untilDate
                ) {
                    Section("Preview") {
                        Text("\(previewDates.count) ocorrências")
                        
                        if !previewDates.isEmpty {
                            Text("Primeira: \(previewDates[0].formatted(.dateTime.day().month()))")
                            Text("Última: \(previewDates.last!.formatted(.dateTime.day().month()))")
                        }
                    }
                }
            }
            .navigationTitle("Nova Série")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        createSeries()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Erro", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !description.isEmpty && 
        !amount.isEmpty && 
        Decimal(string: amount) != nil
    }
    
    private func createSeries() {
        guard let amountDecimal = Decimal(string: amount) else { return }
        
        let newCost = Cost(
            groupID: group.id,
            amount: amountDecimal,
            state: .planned,
            date: Date(),
            description: description,
            recurrence: recurrenceType
        )
        
        Task {
            do {
                try await viewModel.saveCostSeries(newCost, untilDate: untilDate)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// View auxiliar para selecionar o tipo de recorrência
struct RecurrencePickerView: View {
    @Binding var selection: RecurrenceType
    
    var body: some View {
        Picker("Tipo", selection: $selection) {
            Text("Todo dia útil")
                .tag(RecurrenceType.daily(businessDaysOnly: true))
            
            Text("Todo dia")
                .tag(RecurrenceType.daily(businessDaysOnly: false))
            
            Text("Dias específicos")
                .tag(RecurrenceType.custom(specificDates: []))
        }
        
        if case .custom = selection {
            CustomDaysSelector(dates: selection)
        }
    }
}
