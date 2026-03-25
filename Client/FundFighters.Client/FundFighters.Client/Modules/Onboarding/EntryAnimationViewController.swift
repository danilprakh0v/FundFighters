/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: EntryAnimationViewController.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: Introduction screen for new users with step-by-step tutorial.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

import UIKit

final class EntryAnimationViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = OnboardingViewModel()
    private let accentGreen = UIColor(red: 30/255, green: 140/255, blue: 98/255, alpha: 1.0)

    // MARK: - UI Elements

    private let welcomeSignView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "welcome_sign")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let pillGlowView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rect_glow")
        iv.contentMode = .scaleToFill
        iv.alpha = 0.5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var subtitlePill: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Play, fight and get your money on right track"
        label.font = DS.interSemi(15)
        label.textColor = .white
        label.backgroundColor = self.accentGreen
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 3.1 Свечение над иллюстрацией (на всю длину, 20% opacity)
    private let illustrationTopGlow: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rect_glow")
        iv.contentMode = .scaleToFill
        iv.alpha = 0.2
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 3.2 Свечение под иллюстрацией (на всю длину, 20% opacity)
    private let illustrationBottomGlow: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rect_glow")
        iv.contentMode = .scaleToFill
        iv.alpha = 0.1
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 3. Главная иллюстрация
    private let illustrationView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "onboarding_illust")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.layer.cornerCurve = .continuous
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 4. Футер-текст
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Greetings at your first\ncaptivating Finance Tracker."
        label.numberOfLines = 2
        label.font = DS.golosSemi(28)
        label.textColor = .black
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 5. Кнопка
    private lazy var startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Start Your Fight!"
        config.baseBackgroundColor = self.accentGreen
        config.baseForegroundColor = .white
        config.background.cornerRadius = 24
        config.cornerStyle = .fixed
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = DS.golosBold(24)
            return outgoing
        }
        config.image = UIImage(named: "arrow")
        config.imagePlacement = .trailing
        config.imagePadding = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.96, alpha: 1.0)
        setupLayout()
        setupActions()
    }

    // MARK: - Actions Setup

    private func setupActions() {
        startButton.addTarget(self, action: #selector(handleStartButtonTapped), for: .touchUpInside)
    }

    // MARK: - Navigation with Animation

    @objc private func handleStartButtonTapped() {
        // Haptic Feedback / Тактильная обратная связь
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // Button press animation / Анимация нажатия кнопки
        UIView.animate(withDuration: 0.1, animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.startButton.transform = .identity
            } completion: { _ in
                self.navigateToLogin()
            }
        }
    }

    private func navigateToLogin() {
        // Save onboarding completed flag / Сохраняем флаг прохождения онбординга
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let loginVC = LoginViewController()
        // Smooth transition animation / Плавная анимация перехода
        guard let window = view.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = loginVC
        }, completion: nil)
    }

    // MARK: - Setup Layout

    private func setupLayout() {
        [illustrationTopGlow, illustrationBottomGlow, pillGlowView, welcomeSignView, subtitlePill, illustrationView, footerLabel, startButton].forEach {
            view.addSubview($0)
        }
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // --- 1. ЗАГОЛОВОК ---
            welcomeSignView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: -35),
            welcomeSignView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            welcomeSignView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            welcomeSignView.heightAnchor.constraint(equalToConstant: 170),
            // --- 2. ПИЛЮЛЯ (Укороченная, ближе к заголовку) ---
            subtitlePill.topAnchor.constraint(equalTo: welcomeSignView.bottomAnchor, constant: -10),
            subtitlePill.leadingAnchor.constraint(equalTo: welcomeSignView.leadingAnchor, constant: 20),
            subtitlePill.heightAnchor.constraint(equalToConstant: 28),
            // Не ограничиваем trailing, чтобы она была по размеру текста
            // --- 2.1 СВЕЧЕНИЕ ПИЛЮЛИ (На всю длину, убран фиксированный width) ---
            // Removed fixed width constraint that conflicted with leading+trailing
            pillGlowView.centerYAnchor.constraint(equalTo: subtitlePill.centerYAnchor),
            pillGlowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pillGlowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pillGlowView.heightAnchor.constraint(equalToConstant: 80),
            // --- 5. КНОПКА ---
            startButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 70),
            // --- 4. ФУТЕР ТЕКСТ (Увеличен левый отступ) ---
            footerLabel.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            footerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            footerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            // --- 3. ИЛЛЮСТРАЦИЯ ---
            illustrationView.topAnchor.constraint(equalTo: subtitlePill.bottomAnchor, constant: 10),
            illustrationView.bottomAnchor.constraint(equalTo: footerLabel.topAnchor, constant: -10),
            illustrationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            illustrationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // --- 3.1 ТЕНИ ИЛЛЮСТРАЦИИ (На всю длину) ---
            illustrationTopGlow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            illustrationTopGlow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            illustrationTopGlow.centerYAnchor.constraint(equalTo: illustrationView.topAnchor, constant: 20),
            illustrationTopGlow.heightAnchor.constraint(equalToConstant: 80),
            illustrationBottomGlow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            illustrationBottomGlow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            illustrationBottomGlow.centerYAnchor.constraint(equalTo: illustrationView.bottomAnchor, constant: -20),
            illustrationBottomGlow.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
}
