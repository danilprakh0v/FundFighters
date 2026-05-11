/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: TutorialViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: Экран обучения (Tutorial) для новых пользователей.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

struct TutorialStep {
    let title: String
    let description: String
    let iconName: String
}

final class TutorialViewController: UIViewController {
    
    // --- Данные шагов обучения ---
    private var steps: [TutorialStep] = [
        TutorialStep(title: "Добро пожаловать в FundFighters", description: "Первый финансовый трекер, где ваши сбережения сражаются за вас. Готовы к победе?", iconName: "star.fill"),
        TutorialStep(title: "Победите свои расходы", description: "Каждый раз, когда вы откладываете деньги, вы наносите урон своему финансовому противнику. Одолейте зверя, достигнув цели!", iconName: "bolt.heart.fill"),
        TutorialStep(title: "Удобный учет", description: "Используйте кнопку 'плюс' или первую вкладку, чтобы записывать свои доходы и расходы в реальном времени.", iconName: "plus.circle.fill"),
        TutorialStep(title: "Следите за прогрессом", description: "Контролируйте свой баланс и ежемесячный прогресс. Держите сердца полными, а HP врага — на нуле!", iconName: "chart.bar.fill")
    ]
    
    private var currentStepIndex = 0
    
    // MARK: - UI Компоненты
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.cornerCurve = .continuous
        v.translatesAutoresizingMaskIntoConstraints = false
        // Тень для премиального вида
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 20
        return v
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DS.accent
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = DS.golosBold(28)
        l.textColor = DS.textPrimary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = DS.golosMedium(17)
        l.textColor = DS.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Далее", for: .normal)
        b.titleLabel?.font = DS.golosBold(18)
        b.backgroundColor = DS.accent
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return b
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = DS.accent
        pc.pageIndicatorTintColor = .systemGray5
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupLayout()
        pageControl.numberOfPages = steps.count
        updateStep(animated: false)
    }
    
    // --- Настройка верстки ---
    private func setupLayout() {
        view.addSubview(containerView)
        [iconImageView, titleLabel, descriptionLabel, pageControl, nextButton].forEach { containerView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            containerView.bottomAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 40),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            
            pageControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            pageControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            nextButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 24),
            nextButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 220),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // --- Обработка нажатий ---
    @objc private func nextTapped() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            updateStep(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // --- Обновление содержимого шага ---
    private func updateStep(animated: Bool) {
        let step = steps[currentStepIndex]
        let isLast = currentStepIndex == steps.count - 1
        
        let block = {
            self.iconImageView.image = UIImage(systemName: step.iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
            self.titleLabel.text = step.title
            self.descriptionLabel.text = step.description
            self.pageControl.currentPage = self.currentStepIndex
            self.nextButton.setTitle(isLast ? "Начать битву!" : "Далее", for: .normal)
        }
        
        if animated {
            UIView.transition(with: containerView, duration: 0.3, options: .transitionCrossDissolve, animations: block)
        } else {
            block()
        }
    }
}
