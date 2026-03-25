/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: OnboardingViewModel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: ViewModel для onboarding экрана новых пользователей.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

import Foundation
import Combine

final class OnboardingViewModel {
    
    // MARK: - Properties
    
    var currentStep = 0
    let totalSteps = 4
    
    var onStepCompleted: (() -> Void)?
    var onOnboardingFinished: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Methods
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
            onStepCompleted?()
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            onStepCompleted?()
        }
    }
    
    func completeOnboarding() {
        // Mark onboarding as completed in UserDefaults
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
        onOnboardingFinished?()
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
}

// MARK: - Onboarding Step
struct OnboardingStep {
    let title: String
    let description: String
    let imageName: String
    let actionButtonText: String
}

let onboardingSteps = [
    OnboardingStep(
        title: "Welcome to FundFighters",
        description: "Gamify your savings with epic financial battles!",
        imageName: "star.fill",
        actionButtonText: "Next"
    ),
    OnboardingStep(
        title: "Set Your Goals",
        description: "Create savings goals and transform them into enemies to defeat!",
        imageName: "target",
        actionButtonText: "Next"
    ),
    OnboardingStep(
        title: "Track Your Progress",
        description: "Watch your balance grow as you defeat your financial enemies.",
        imageName: "chart.bar.fill",
        actionButtonText: "Next"
    ),
    OnboardingStep(
        title: "Ready to Battle?",
        description: "You're all set! Start your financial journey now.",
        imageName: "bolt.fill",
        actionButtonText: "Let's Go!"
    )
]
