/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: SplashViewController.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: Initial loading screen with branding animation. //              Начальный экран загрузки с анимацией бренда.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

class SplashViewController: UIViewController {

    // --- Цвета ---
    private let appBackground = UIColor(hex: "1E8C62")

    // --- UI Элементы ---
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        // Используем оригинальный белый логотип
        iv.image = UIImage(named: "logo_white")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = appBackground
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimationSequence()
    }

    // --- Верстка ---
    private func setupLayout() {
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // УВЕЛИЧИЛ РАЗМЕР (Было 150, стало 280)
            // Убедись, что в LaunchScreen.storyboard размеры такие же, чтобы лого не "прыгало"
            logoImageView.widthAnchor.constraint(equalToConstant: 280),
            logoImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }

    // --- Анимация ---
    private func startAnimationSequence() {
        // УВЕЛИЧИЛ ДЛИТЕЛЬНОСТЬ (Было 0.8, стало 2.0 секунды)
        // delay: 0.2 — маленькая пауза перед началом, чтобы глаз успел сфокусироваться
        UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseInOut) {
            
            // Логотип плавно увеличивается ("дышит")
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            
            // Можно добавить легкое исчезновение к концу, если хочешь:
            // self.logoImageView.alpha = 0.8
            
        } completion: { _ in
            self.goToOnboarding()
        }
    }

    private func goToOnboarding() {
        let nextVC = EntryAnimationViewController()
        guard let window = view.window else { return }
        
        // Медленный переход (1.0 секунда) для большего наслаждения эффектом
        UIView.transition(with: window, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController = nextVC
        }, completion: nil)
    }
}
