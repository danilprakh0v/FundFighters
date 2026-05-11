/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: OnboardingViewModel.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: ViewModel для экрана онбординга новых пользователей.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

import Foundation
import Combine

final class OnboardingViewModel {
    
    // MARK: - Свойства
    
    var currentStep = 0
    let totalSteps = 4
    
    var onStepCompleted: (() -> Void)?
    var onOnboardingFinished: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Методы
    
    /// Переход к следующему шагу онбординга
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
            onStepCompleted?()
        } else {
            completeOnboarding()
        }
    }
    
    /// Возврат к предыдущему шагу онбординга
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            onStepCompleted?()
        }
    }
    
    /// Завершение процесса онбординга
    func completeOnboarding() {
        // Сохранение флага завершения онбординга в настройках пользователя
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
        onOnboardingFinished?()
    }
    
    /// Пропуск онбординга
    func skipOnboarding() {
        completeOnboarding()
    }
}

// MARK: - Шаг онбординга
struct OnboardingStep {
    let title: String
    let description: String
    let imageName: String
    let actionButtonText: String
}

// Константные данные для шагов обучения
let onboardingSteps = [
    OnboardingStep(
        title: "Welcome to FundFighters",
        description: "Gamify your savings in epic financial battles!",
        imageName: "star.fill",
        actionButtonText: "Next"
    ),
    OnboardingStep(
        title: "Set Goals",
        description: "Create financial goals and turn them into enemies to defeat!",
        imageName: "target",
        actionButtonText: "Next"
    ),
    OnboardingStep(
        title: "Track Progress",
        description: "Watch your balance grow as you defeat financial enemies.",
        imageName: "chart.bar.fill",
        actionButtonText: "Next"
    ),
    OnboardingStep(
        title: "Ready for Battle?",
        description: "Everything is set! Start your financial journey right now.",
        imageName: "bolt.fill",
        actionButtonText: "Let's Go!"
    )
]
