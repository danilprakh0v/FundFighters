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
        title: "Добро пожаловать в FundFighters",
        description: "Геймифицируйте свои сбережения в эпических финансовых битвах!",
        imageName: "star.fill",
        actionButtonText: "Далее"
    ),
    OnboardingStep(
        title: "Ставьте цели",
        description: "Создавайте финансовые цели и превращайте их во врагов для победы!",
        imageName: "target",
        actionButtonText: "Далее"
    ),
    OnboardingStep(
        title: "Следите за прогрессом",
        description: "Наблюдайте, как растет ваш баланс, пока вы побеждаете финансовых врагов.",
        imageName: "chart.bar.fill",
        actionButtonText: "Далее"
    ),
    OnboardingStep(
        title: "Готовы к битве?",
        description: "Все настроено! Начните свое финансовое путешествие прямо сейчас.",
        imageName: "bolt.fill",
        actionButtonText: "Погнали!"
    )
]
