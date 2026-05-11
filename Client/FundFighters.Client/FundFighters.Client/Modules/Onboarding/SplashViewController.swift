/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: SplashViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: Начальный экран загрузки с анимацией бренда.
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
            
            logoImageView.widthAnchor.constraint(equalToConstant: 280),
            logoImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }

    // --- Анимация ---
    private func startAnimationSequence() {
        // Анимация увеличения логотипа ("эффект дыхания")
        UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseInOut) {
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            self.goToNextScreen()
        }
    }

    private func goToNextScreen() {
        let nextVC: UIViewController
        
        if TokenManager.shared.hasToken {
            nextVC = MainTabBarController()
        } else {
            nextVC = EntryAnimationViewController()
        }
        
        guard let window = view.window else { return }
        
        // Плавный переход к следующему экрану
        UIView.transition(with: window, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController = nextVC
        }, completion: nil)
    }
}
