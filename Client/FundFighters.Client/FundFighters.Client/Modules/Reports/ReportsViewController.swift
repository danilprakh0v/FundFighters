/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: ReportsViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Reports/
Назначение: Экран отчетов. Визуализация расходов по категориям.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - Токены дизайна (ReportsDT)

private enum ReportsDT {
    static let accentTeal   = UIColor(red: 46/255,  green: 166/255, blue: 155/255, alpha: 1.0)
    static let accentGreen  = UIColor(red: 30/255,  green: 140/255, blue: 98/255,  alpha: 1.0)
    static let background   = UIColor(red: 240/255, green: 240/255, blue: 236/255, alpha: 1.0)
    static let cardBg       = UIColor(red: 245/255, green: 245/255, blue: 242/255, alpha: 1.0)
    static let pillInactive = UIColor(red: 220/255, green: 220/255, blue: 216/255, alpha: 1.0)
}

// MARK: - Вспомогательная кнопка (Зеленый круг)

private final class ReportsGreenCircleButton: UIButton {
    init(iconName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ReportsDT.accentTeal
        setImage(
            UIImage(systemName: iconName,
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)),
            for: .normal
        )
        tintColor = .white
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.cornerCurve  = .continuous
    }
}

// MARK: - ReportsViewController

final class ReportsViewController: UIViewController {

    // MARK: - Свойства

    private let viewModel = DashboardViewModel()

    // MARK: - UI Элементы

    // Панель навигации
    private lazy var backButton: ReportsGreenCircleButton = {
        let b = ReportsGreenCircleButton(iconName: "chevron.left")
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "FundFighters"
        l.font          = DS.golosBold(22)
        l.textColor     = DS.textPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Заголовок секции
    private let sectionTitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "Тип расходов"
        l.font          = DS.golosBold(22)
        l.textColor     = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Контейнер выбора периода
    private let periodContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let periodLabel: UILabel = {
        let l = UILabel()
        l.text          = "Ноябрь"
        l.font          = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor     = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let prevButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)),
                   for: .normal)
        b.tintColor = .label
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)),
                   for: .normal)
        b.tintColor = .label
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let yearButton: UIButton = {
        var cfg = UIButton.Configuration.plain()
        cfg.title = "Year"
        cfg.image = UIImage(systemName: "chevron.up.chevron.down",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        cfg.imagePlacement = .trailing
        cfg.imagePadding   = 4
        cfg.baseForegroundColor = .label
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { a in
            var b = a
            b.font = .systemFont(ofSize: 15, weight: .semibold)
            return b
        }
        let b = UIButton(configuration: cfg)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // График расходов
    private let expenseChartView = ExpenseChartViewUIKit()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ReportsDT.background
        setupLayout()
        loadData()
    }

    // MARK: - Верстка

    private func setupLayout() {
        expenseChartView.translatesAutoresizingMaskIntoConstraints = false

        // Стек управления месяцем: [←] [Ноябрь] [→]
        let monthNavStack = UIStackView(arrangedSubviews: [prevButton, periodLabel, nextButton])
        monthNavStack.axis      = .horizontal
        monthNavStack.spacing   = 8
        monthNavStack.alignment = .center
        monthNavStack.translatesAutoresizingMaskIntoConstraints = false

        let periodSpacer = UIView()
        periodSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        periodSpacer.translatesAutoresizingMaskIntoConstraints = false

        // Общий стек периода: [Месяц] [Пробел] [Год]
        let periodRowStack = UIStackView(arrangedSubviews: [monthNavStack, periodSpacer, yearButton])
        periodRowStack.axis      = .horizontal
        periodRowStack.spacing   = 8
        periodRowStack.alignment = .center
        periodRowStack.translatesAutoresizingMaskIntoConstraints = false

        [backButton, navTitleLabel, sectionTitleLabel, periodRowStack, expenseChartView]
            .forEach { view.addSubview($0) }

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Кнопка назад
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            // Заголовок навигации
            navTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Заголовок секции
            sectionTitleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Строка периода
            periodRowStack.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 8),
            periodRowStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            periodRowStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // График
            expenseChartView.topAnchor.constraint(equalTo: periodRowStack.bottomAnchor, constant: 20),
            expenseChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expenseChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            expenseChartView.heightAnchor.constraint(equalToConstant: 420),
        ])
    }

    // MARK: - Данные

    private func loadData() {
        viewModel.loadDashboard()
        viewModel.onDataLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.expenseChartView.configure(categories: self?.viewModel.dashboard?.expenseCategories ?? [])
            }
        }
    }

    // MARK: - Обработка действий

    @objc private func closeTapped() {
        if let tabBar = self.tabBarController as? MainTabBarController {
            tabBar.switchToTab(2) // Переключение на главный экран (Dashboard)
        } else {
            dismiss(animated: true)
        }
    }
}
