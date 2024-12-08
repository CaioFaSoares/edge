//
//  CustomDaysSelector.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct CustomDaysSelector: View {
    @State var dates: RecurrenceType
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Selecione os dias do mês")
                .font(.caption)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(1...31, id: \.self) { day in
                        if case .custom(let selectedDays) = dates {
                            Toggle(isOn: .init(
                                get: { selectedDays.contains(day) },
                                set: { isSelected in
                                    if case .custom(var days) = dates {
                                        if isSelected {
                                            days.insert(day)
                                        } else {
                                            days.remove(day)
                                        }
                                        dates = .custom(specificDates: days)
                                    }
                                }
                            )) {
                                Text("\(day)")
                            }
                            .toggleStyle(.button)
                        }
                    }
                }
            }
        }
    }
}
