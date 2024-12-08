//
//  RootView.swift
//  edge
//
//  Created by Caio Soares on 08/12/24.
//

import SwiftUI

struct RootView: View {
    @StateObject private var periodManager = PeriodManager(
        repository: UserDefaultsPeriodRepository()
    )
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some View {
        if !onboardingManager.hasCompletedOnboarding {
            OnboardingView(
                periodManager: periodManager,
                onboardingManager: onboardingManager
            )
        } else {
            MainTabView()
        }
    }
}
