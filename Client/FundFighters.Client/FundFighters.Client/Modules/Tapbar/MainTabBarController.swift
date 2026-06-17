/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: MainTabBarController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Tapbar/
Назначение: Главный контроллер вкладок со стеклянным эффектом (GlassTabBar).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit
import PhotosUI

final class MainTabBarController: UITabBarController {

    private let glassBar = GlassTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        setupViewControllers()
        setupGlassBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Проверка необходимости показа экрана обучения
        let userId = UserDefaults.standard.string(forKey: "userId") ?? "default"
        let tutorialKey = "hasSeenTutorial_\(userId)"
        if !UserDefaults.standard.bool(forKey: tutorialKey) {
            let tutorialVC = TutorialViewController()
            tutorialVC.modalPresentationStyle = .overFullScreen
            tutorialVC.modalTransitionStyle = .crossDissolve
            present(tutorialVC, animated: true) {
                UserDefaults.standard.set(true, forKey: tutorialKey)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(glassBar)
    }

    // --- Настройка дочерних контроллеров ---
    private func setupViewControllers() {
        let transactionsVC = UINavigationController(
            rootViewController: TransactionsViewController())
        let analyticsVC = UINavigationController(
            rootViewController: AnalyticsDashboardViewController())
        let mainVC = UINavigationController(
            rootViewController: DashboardViewControllerUIKit())
        let reportsVC = UINavigationController(
            rootViewController: ReportsViewController())
        let profileVC = UINavigationController(
            rootViewController: ProfileViewController())

        [transactionsVC, analyticsVC, mainVC, reportsVC, profileVC].forEach {
            $0.setNavigationBarHidden(true, animated: false)
        }

        viewControllers = [transactionsVC, analyticsVC, mainVC, reportsVC, profileVC]
        selectedIndex = 2
    }

    // --- Настройка стеклянного таббара ---
    private func setupGlassBar() {
        view.addSubview(glassBar)
        glassBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            glassBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            glassBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            glassBar.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            glassBar.heightAnchor.constraint(equalToConstant: 76)
        ])

        glassBar.onTabSelected = { [weak self] index in
            guard let self else { return }
            self.selectedIndex = index
        }
        glassBar.selectTab(2, animated: false)
    }

    func switchToTab(_ index: Int) {
        selectedIndex = index
        glassBar.selectTab(index, animated: true)
    }
}

// MARK: - Унифицированная кнопка уведомлений

final class NotificationBellButton: UIControl {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let tintView = UIView()
    private let iconView = UIImageView()
    private let badgeView = UIView()
    private let shineLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor.white.withAlphaComponent(0.30)
        layer.cornerRadius = 26
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.2
        layer.borderColor = UIColor.white.withAlphaComponent(0.74).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 6)
        clipsToBounds = false

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 26
        blurView.layer.cornerCurve = .continuous
        addSubview(blurView)

        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.isUserInteractionEnabled = false
        tintView.backgroundColor = UIColor.white.withAlphaComponent(0.38)
        tintView.layer.cornerRadius = 26
        tintView.layer.cornerCurve = .continuous
        addSubview(tintView)

        shineLayer.colors = [
            UIColor.white.withAlphaComponent(0.72).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        shineLayer.startPoint = CGPoint(x: 0.15, y: 0)
        shineLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(shineLayer, at: 0)

        iconView.image = UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))
        iconView.tintColor = UIColor(red: 0.58, green: 0.58, blue: 0.61, alpha: 1)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        badgeView.backgroundColor = UIColor(red: 0.62, green: 0.61, blue: 0.66, alpha: 1)
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 2
        badgeView.isUserInteractionEnabled = false
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tintView.topAnchor.constraint(equalTo: topAnchor),
            tintView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1),
            iconView.widthAnchor.constraint(equalToConstant: 27),
            iconView.heightAnchor.constraint(equalToConstant: 27),

            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            badgeView.widthAnchor.constraint(equalToConstant: 12),
            badgeView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.height / 2
        layer.cornerRadius = radius
        blurView.layer.cornerRadius = radius
        tintView.layer.cornerRadius = radius
        badgeView.layer.cornerRadius = badgeView.bounds.height / 2
        shineLayer.frame = bounds
        shineLayer.cornerRadius = radius
        shineLayer.cornerCurve = .continuous
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.16, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
                self.tintView.alpha = self.isHighlighted ? 0.72 : 1
            }
        }
    }
}

private final class GreenCircleBackButton: UIControl {
    private let iconView = UIImageView()
    private let glassLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DT.accentGreen
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.2
        layer.borderColor = UIColor.white.withAlphaComponent(0.62).cgColor
        layer.shadowColor = DT.accentGreen.cgColor
        layer.shadowOpacity = 0.20
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
        clipsToBounds = false

        glassLayer.colors = [
            UIColor.white.withAlphaComponent(0.30).cgColor,
            UIColor.white.withAlphaComponent(0.04).cgColor,
            UIColor.black.withAlphaComponent(0.08).cgColor
        ]
        glassLayer.locations = [0, 0.48, 1]
        glassLayer.startPoint = CGPoint(x: 0, y: 0)
        glassLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(glassLayer, at: 0)

        iconView.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .bold))?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -1),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        glassLayer.frame = bounds
        glassLayer.cornerRadius = bounds.height / 2
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: isHighlighted ? 0.12 : 0.32, delay: 0, usingSpringWithDamping: 0.58, initialSpringVelocity: 0.8) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 1.12, y: 0.86) : .identity
                self.alpha = self.isHighlighted ? 0.88 : 1
            }
        }
    }
}

// MARK: - Analytics

final class AnalyticsDashboardViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let backButton = GreenCircleBackButton()
    private let notificationButton = NotificationBellButton()
    private let titleLabel = UILabel()
    private let rankCard = AnalyticsRankCard()
    private let spendingCard = AnalyticsSpendingCard()
    private let flowCard = AnalyticsFlowCard()
    private lazy var periodControl: PillTabSwitcher = {
        let isRu = UserManager.shared.isRussian
        let titles = isRu ? ["Неделя", "Месяц", "Год"] : ["Week", "Month", "Year"]
        return PillTabSwitcher(items: titles)
    }()
    private var selectedPeriod = 1
    private var dashboard: DashboardResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.965, green: 0.982, blue: 0.974, alpha: 1)
        setupLayout()
        setupActions()
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
        updateLocalization()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = DS.golosBold(38)
        titleLabel.textColor = DS.textPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75

        [backButton, titleLabel, notificationButton, rankCard, periodControl, spendingCard, flowCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 18),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),

            notificationButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            notificationButton.widthAnchor.constraint(equalToConstant: 52),
            notificationButton.heightAnchor.constraint(equalToConstant: 52),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: notificationButton.leadingAnchor, constant: -14),

            periodControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            periodControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            periodControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            periodControl.heightAnchor.constraint(equalToConstant: 48),

            rankCard.topAnchor.constraint(equalTo: periodControl.bottomAnchor, constant: 16),
            rankCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            rankCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            rankCard.heightAnchor.constraint(equalToConstant: 196),

            spendingCard.topAnchor.constraint(equalTo: rankCard.bottomAnchor, constant: 18),
            spendingCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            spendingCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            spendingCard.heightAnchor.constraint(equalToConstant: 384),

            flowCard.topAnchor.constraint(equalTo: spendingCard.bottomAnchor, constant: 18),
            flowCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            flowCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            flowCard.heightAnchor.constraint(equalToConstant: 272),
            flowCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -112)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        periodControl.onTabChanged = { [weak self] index in
            self?.selectedPeriod = index
            UIView.transition(with: self?.contentView ?? UIView(), duration: 0.28, options: .transitionCrossDissolve) {
                self?.render()
            }
        }
        // Start on Month (index 1)
        periodControl.selectIndex(1)
    }

    private func loadData() {
        APIService.shared.getDashboard { [weak self] result in
            if case .success(let dashboard) = result {
                self?.dashboard = dashboard
            }
            self?.render()
        }
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Аналитика" : "Dashboard"
        let titles = isRu ? ["Неделя", "Месяц", "Год"] : ["Week", "Month", "Year"]
        titles.enumerated().forEach { index, title in
            periodControl.setTitle(title, forSegmentAt: index)
        }
        render()
    }

    @objc private func backTapped() {
        (tabBarController as? MainTabBarController)?.switchToTab(2)
    }

    @objc private func notificationTapped() {
        showNotice()
    }

    private func render() {
        let analytics = makeAnalytics()
        rankCard.configure(progress: analytics.progress, currentXP: analytics.currentXP, targetXP: analytics.targetXP)
        spendingCard.configure(items: analytics.categories, periodIndex: selectedPeriod)
        flowCard.configure(income: analytics.income, expense: analytics.expense, bars: analytics.bars, periodIndex: selectedPeriod)
    }

    private func makeAnalytics() -> AnalyticsSnapshot {
        let multiplier: Double = selectedPeriod == 0 ? 0.32 : (selectedPeriod == 1 ? 1.0 : 8.2)
        let fallbackIncome = UserManager.shared.session.monthlyIncome > 0 ? UserManager.shared.session.monthlyIncome : 180150
        let fallbackExpense = UserManager.shared.session.monthlyExpense > 0 ? UserManager.shared.session.monthlyExpense : 5812
        let income = max(45000, NSDecimalNumber(decimal: dashboard?.balanceInfo.monthlyIncome ?? Decimal(fallbackIncome)).doubleValue * multiplier)
        let expense = max(18000, NSDecimalNumber(decimal: dashboard?.balanceInfo.monthlyExpense ?? Decimal(fallbackExpense)).doubleValue * multiplier)
        let target = max(UserManager.shared.session.savingsTarget, 62000)
        let current = min(target, max(UserManager.shared.session.savingsCurrent, 23250) * (selectedPeriod == 2 ? 1.6 : 1.0))
        let progress = target > 0 ? current / target : 0.37

        let categories = makeCategories(multiplier: multiplier)

        let bars = [
            AnalyticsFlowBar(label: flowLabel(1), income: income * 0.34, expense: expense * 0.27),
            AnalyticsFlowBar(label: flowLabel(2), income: income * 0.28, expense: expense * 0.38),
            AnalyticsFlowBar(label: flowLabel(3), income: income * 0.38, expense: expense * 0.35)
        ]

        return AnalyticsSnapshot(progress: progress, currentXP: current, targetXP: target, income: income, expense: expense, categories: categories, bars: bars)
    }

    private func flowLabel(_ index: Int) -> String {
        let isRu = UserManager.shared.isRussian
        if selectedPeriod == 2 {
            return isRu ? "Кв. \(index)" : "Q\(index)"
        }
        return isRu ? "Нед. \(index)" : "Week \(index)"
    }

    private func makeCategories(multiplier: Double) -> [AnalyticsCategory] {
        let palette: [(UIColor, String)] = [
            (UIColor(red: 0.19, green: 0.86, blue: 0.40, alpha: 1), "fork.knife"),
            (UIColor(red: 0.22, green: 0.56, blue: 1, alpha: 1), "cart.fill"),
            (UIColor(red: 1, green: 0.52, blue: 0.28, alpha: 1), "gamecontroller.fill"),
            (UIColor(red: 1, green: 0.23, blue: 0.45, alpha: 1), "repeat.circle.fill"),
            (UIColor(red: 0.74, green: 0.22, blue: 0.92, alpha: 1), "bolt.fill")
        ]

        if let expenseCategories = dashboard?.expenseCategories, !expenseCategories.isEmpty {
            let total = max(1, expenseCategories.reduce(0.0) { $0 + NSDecimalNumber(decimal: $1.totalAmount).doubleValue })
            return expenseCategories.prefix(5).enumerated().map { index, category in
                let value = NSDecimalNumber(decimal: category.totalAmount).doubleValue * multiplier
                let visual = palette[index % palette.count]
                return AnalyticsCategory(
                    name: category.name,
                    amount: value,
                    color: visual.0,
                    icon: iconForCategory(category.name, fallback: visual.1),
                    percent: Int(round(value / (total * multiplier) * 100))
                )
            }
        }

        return [
            AnalyticsCategory(name: "Food", amount: 12150 * multiplier, color: palette[0].0, icon: palette[0].1, percent: 27),
            AnalyticsCategory(name: "Groceries", amount: 11250 * multiplier, color: palette[1].0, icon: palette[1].1, percent: 25),
            AnalyticsCategory(name: "Entertainment", amount: 9000 * multiplier, color: palette[2].0, icon: palette[2].1, percent: 20),
            AnalyticsCategory(name: "Subscriptions", amount: 6750 * multiplier, color: palette[3].0, icon: palette[3].1, percent: 15),
            AnalyticsCategory(name: "Utilities", amount: 5850 * multiplier, color: palette[4].0, icon: palette[4].1, percent: 13)
        ]
    }

    private func iconForCategory(_ category: String, fallback: String) -> String {
        let key = category.lowercased()
        if key.contains("food") || key.contains("еда") { return "fork.knife" }
        if key.contains("grocery") || key.contains("проду") { return "cart.fill" }
        if key.contains("entertainment") || key.contains("разв") { return "gamecontroller.fill" }
        if key.contains("subscription") || key.contains("подпис") { return "repeat.circle.fill" }
        if key.contains("util") || key.contains("коммун") { return "bolt.fill" }
        if key.contains("health") || key.contains("здоров") { return "heart.fill" }
        if key.contains("transport") || key.contains("транспорт") { return "car.fill" }
        if key.contains("saving") || key.contains("накоп") { return "dollarsign.circle.fill" }
        if key.contains("other") || key.contains("другое") { return "tag.fill" }
        return fallback
    }

    private func showNotice() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(
            title: isRu ? "Уведомления" : "Notifications",
            message: isRu ? "Аналитические подсказки появятся здесь после нескольких периодов данных." : "Analytics insights will appear here after a few data periods.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

private struct AnalyticsSnapshot {
    let progress: Double
    let currentXP: Double
    let targetXP: Double
    let income: Double
    let expense: Double
    let categories: [AnalyticsCategory]
    let bars: [AnalyticsFlowBar]
}

private struct AnalyticsCategory {
    let name: String
    let amount: Double
    let color: UIColor
    let icon: String
    let percent: Int
}

private struct AnalyticsFlowBar {
    let label: String
    let income: Double
    let expense: Double
}

private class AnalyticsGlassCard: UIView {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
    private let tintView = UIView()
    private let glowLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = DT.accentGreen
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.2
        layer.borderColor = UIColor.white.withAlphaComponent(0.62).cgColor
        layer.shadowColor = DT.accentGreen.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 10)
        clipsToBounds = false

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 22
        blurView.layer.cornerCurve = .continuous
        addSubview(blurView)

        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.isUserInteractionEnabled = false
        tintView.backgroundColor = DT.accentGreen.withAlphaComponent(0.82)
        tintView.layer.cornerRadius = 22
        tintView.layer.cornerCurve = .continuous
        addSubview(tintView)

        glowLayer.colors = [
            UIColor.white.withAlphaComponent(0.24).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor,
            UIColor(red: 0.02, green: 0.38, blue: 0.25, alpha: 0.18).cgColor
        ]
        glowLayer.locations = [0, 0.48, 1]
        glowLayer.startPoint = CGPoint(x: 0, y: 0)
        glowLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(glowLayer, at: 0)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        glowLayer.frame = bounds
        glowLayer.cornerRadius = 22
        blurView.layer.cornerRadius = 22
        tintView.layer.cornerRadius = 22
    }
}

private final class AnalyticsRankCard: AnalyticsGlassCard {
    private let titleLabel = UILabel()
    private let ringView = AnalyticsRingView()
    private let dollarLabel = UILabel()
    private let levelRankLabel = UILabel()
    private let xpLabel = UILabel()
    private let targetIcon = UIImageView()
    private let trendIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        titleLabel.textColor = .white
        titleLabel.font = DS.golosBold(17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        ringView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ringView)

        dollarLabel.text = "$"
        dollarLabel.textColor = .white.withAlphaComponent(0.4)
        dollarLabel.font = .systemFont(ofSize: 36, weight: .bold)
        dollarLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dollarLabel)

        levelRankLabel.textColor = .white
        levelRankLabel.font = DS.golosBold(14)
        levelRankLabel.adjustsFontSizeToFitWidth = true
        levelRankLabel.minimumScaleFactor = 0.78
        levelRankLabel.textAlignment = .center
        levelRankLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(levelRankLabel)

        xpLabel.textColor = .white.withAlphaComponent(0.92)
        xpLabel.font = DS.golosMedium(13)
        xpLabel.textAlignment = .center
        xpLabel.adjustsFontSizeToFitWidth = true
        xpLabel.minimumScaleFactor = 0.75
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(xpLabel)

        [targetIcon, trendIcon].forEach {
            $0.tintColor = UIColor.white.withAlphaComponent(0.14)
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        targetIcon.image = UIImage(systemName: "target")
        trendIcon.image = UIImage(systemName: "arrow.up.right")

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            ringView.centerXAnchor.constraint(equalTo: centerXAnchor),
            ringView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            ringView.widthAnchor.constraint(equalToConstant: 104),
            ringView.heightAnchor.constraint(equalToConstant: 104),

            dollarLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            dollarLabel.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),

            levelRankLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            levelRankLabel.bottomAnchor.constraint(equalTo: xpLabel.topAnchor, constant: -5),
            levelRankLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            levelRankLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            xpLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            xpLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            xpLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            xpLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            targetIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            targetIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -56),
            targetIcon.widthAnchor.constraint(equalToConstant: 92),
            targetIcon.heightAnchor.constraint(equalToConstant: 92),

            trendIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            trendIcon.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            trendIcon.widthAnchor.constraint(equalToConstant: 84),
            trendIcon.heightAnchor.constraint(equalToConstant: 84)
        ])
    }

    func configure(progress: Double, currentXP: Double, targetXP: Double) {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Общий финансовый ранг" : "Overall Financial Rank"
        ringView.configure(progress: progress)
        let percent = Int(round(min(1, max(0, progress)) * 100))
        levelRankLabel.text = isRu ? "Уровень 3 • Воин Капитала • \(percent)%" : "Level 3 • Capital Warrior • \(percent)%"
        xpLabel.text = isRu
            ? "XP получено: \(format(currentXP)) / \(format(targetXP))"
            : "XP Earned: \(format(currentXP)) / \(format(targetXP))"
    }

    private func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

private final class AnalyticsRingView: UIView {
    private var progress: Double = 0.75

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(progress: Double) {
        self.progress = min(1, max(0, progress))
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.36
        let lineWidth: CGFloat = 10
        let bg = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)
        UIColor.white.withAlphaComponent(0.18).setStroke()
        bg.lineWidth = lineWidth
        bg.stroke()

        let fg = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: -.pi / 2 + CGFloat(progress * .pi * 2), clockwise: true)
        UIColor(red: 0.24, green: 0.88, blue: 0.42, alpha: 1).setStroke()
        fg.lineCapStyle = .round
        fg.lineWidth = lineWidth
        fg.stroke()
    }
}

private final class AnalyticsSpendingCard: AnalyticsGlassCard {
    private let titleLabel = UILabel()
    private let donutView = AnalyticsDonutView()
    private let listStack = UIStackView()
    private let contentStack = UIStackView()
    private var items: [AnalyticsCategory] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        titleLabel.font = DS.golosBold(22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78
        titleLabel.clipsToBounds = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        donutView.translatesAutoresizingMaskIntoConstraints = false

        listStack.axis = .vertical
        listStack.spacing = 7
        listStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(donutView)
        contentStack.addArrangedSubview(listStack)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            contentStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14),

            donutView.heightAnchor.constraint(equalToConstant: 138)
        ])
    }

    func configure(items: [AnalyticsCategory], periodIndex: Int) {
        self.items = items
        titleLabel.text = UserManager.shared.isRussian ? "Структура расходов" : "Spending Breakdown"
        donutView.configure(items: items)
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        items.prefix(5).forEach { listStack.addArrangedSubview(AnalyticsCategoryRow(item: $0)) }
    }
}

private final class AnalyticsDonutView: UIView {
    private var items: [AnalyticsCategory] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(items: [AnalyticsCategory]) {
        self.items = items
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !items.isEmpty else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.36
        let lineWidth = radius * 0.38
        var start = -CGFloat.pi / 2
        let total = CGFloat(items.reduce(0) { $0 + $1.amount })
        let iconRadius = radius
        let iconSize: CGFloat = 14

        for item in items {
            let angle = CGFloat(item.amount) / max(total, 1) * .pi * 2
            // Gap between segments for clarity
            let gapAngle: CGFloat = angle > 0.12 ? 0.04 : 0
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start + gapAngle / 2, endAngle: start + angle - gapAngle / 2, clockwise: true)
            item.color.setStroke()
            path.lineWidth = lineWidth
            path.stroke()

            // Draw category icon in the middle of the arc segment
            if angle > 0.35, let sfImage = UIImage(systemName: item.icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize, weight: .bold)) {
                let midAngle = start + angle / 2
                let iconX = center.x + iconRadius * cos(midAngle) - iconSize / 2
                let iconY = center.y + iconRadius * sin(midAngle) - iconSize / 2
                UIGraphicsPushContext(UIGraphicsGetCurrentContext()!)
                sfImage.withTintColor(.white, renderingMode: .alwaysOriginal).draw(in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
                UIGraphicsPopContext()
            }

            start += angle
        }

        // Inner circle fill for donut hole
        UIColor.white.withAlphaComponent(0.16).setFill()
        let holeRadius = radius - lineWidth / 2
        UIBezierPath(ovalIn: CGRect(x: center.x - holeRadius * 0.54, y: center.y - holeRadius * 0.54, width: holeRadius * 1.08, height: holeRadius * 1.08)).fill()
    }
}

private final class AnalyticsCategoryRow: UIView {
    init(item: AnalyticsCategory) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 30).isActive = true

        let dot = UIImageView(image: UIImage(systemName: item.icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)))
        dot.tintColor = .white
        dot.backgroundColor = item.color
        dot.layer.cornerRadius = 10
        dot.contentMode = .center
        dot.translatesAutoresizingMaskIntoConstraints = false

        let name = UILabel()
        name.text = localizedCategory(item.name)
        name.font = DS.golosBold(13)
        name.textColor = .white
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.76

        let amount = UILabel()
        amount.text = format(item.amount)
        amount.font = DS.golosBold(12)
        amount.textColor = .white
        amount.textAlignment = .right
        amount.adjustsFontSizeToFitWidth = true
        amount.minimumScaleFactor = 0.72

        let pct = UILabel()
        pct.text = "\(item.percent)%"
        pct.font = DS.golosBold(10)
        pct.textColor = .white
        pct.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        pct.layer.cornerRadius = 9
        pct.clipsToBounds = true
        pct.textAlignment = .center

        [dot, name, amount, pct].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 20),
            dot.heightAnchor.constraint(equalToConstant: 20),

            name.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 7),
            name.centerYAnchor.constraint(equalTo: centerYAnchor),
            name.trailingAnchor.constraint(lessThanOrEqualTo: amount.leadingAnchor, constant: -6),

            pct.trailingAnchor.constraint(equalTo: trailingAnchor),
            pct.centerYAnchor.constraint(equalTo: centerYAnchor),
            pct.widthAnchor.constraint(equalToConstant: 40),
            pct.heightAnchor.constraint(equalToConstant: 18),

            amount.trailingAnchor.constraint(equalTo: pct.leadingAnchor, constant: -6),
            amount.centerYAnchor.constraint(equalTo: centerYAnchor),
            amount.widthAnchor.constraint(equalToConstant: 92)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    private func localizedCategory(_ name: String) -> String {
        guard UserManager.shared.isRussian else { return name }
        return [
            "Food": "Еда",
            "Groceries": "Продукты",
            "Entertainment": "Развлечения",
            "Subscriptions": "Подписки",
            "Subscription": "Подписки",
            "Utilities": "Коммунальные",
            "Savings": "Накопления",
            "Other": "Другое",
            "Health": "Здоровье",
            "Transport": "Транспорт"
        ][name] ?? name
    }

    private func format(_ value: Double) -> String {
        "\(Int(value).formatted())₽"
    }
}

private final class AnalyticsFlowCard: AnalyticsGlassCard {
    private let titleLabel = UILabel()
    private let incomeLabel = UILabel()
    private let expenseLabel = UILabel()
    private let chartView = AnalyticsBarsView()
    private let netLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        titleLabel.font = DS.golosBold(22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78

        [incomeLabel, expenseLabel].forEach {
            $0.font = DS.golosBold(15)
            $0.textColor = .white
            $0.numberOfLines = 2
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.72
        }

        // Liquid-glass pill for net flow
        let netPill = buildNetPill()
        netLabel.font = DS.golosBold(14)
        netLabel.textColor = .white
        netLabel.textAlignment = .center

        let topRow = UIStackView(arrangedSubviews: [incomeLabel, expenseLabel])
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = 8
        topRow.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        netLabel.translatesAutoresizingMaskIntoConstraints = false
        netPill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(topRow)
        addSubview(netPill)
        netPill.addSubview(netLabel)
        addSubview(chartView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            topRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            topRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            topRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            netPill.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 10),
            netPill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            netPill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            netPill.heightAnchor.constraint(equalToConstant: 32),

            netLabel.centerXAnchor.constraint(equalTo: netPill.centerXAnchor),
            netLabel.centerYAnchor.constraint(equalTo: netPill.centerYAnchor),
            netLabel.leadingAnchor.constraint(greaterThanOrEqualTo: netPill.leadingAnchor, constant: 12),
            netLabel.trailingAnchor.constraint(lessThanOrEqualTo: netPill.trailingAnchor, constant: -12),

            chartView.topAnchor.constraint(equalTo: netPill.bottomAnchor, constant: 10),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    /// Build the liquid-glass pill container for the net flow label
    private func buildNetPill() -> UIView {
        let pill = UIView()
        pill.layer.cornerRadius = 16
        pill.layer.cornerCurve = .continuous
        pill.clipsToBounds = false

        // Blur effect
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.clipsToBounds = true
        blur.layer.cornerRadius = 16
        blur.layer.cornerCurve = .continuous
        blur.layer.borderWidth = 1
        blur.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        pill.addSubview(blur)

        // Tint overlay
        let tint = UIView()
        tint.translatesAutoresizingMaskIntoConstraints = false
        tint.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        tint.layer.cornerRadius = 16
        tint.layer.cornerCurve = .continuous
        blur.contentView.addSubview(tint)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: pill.topAnchor),
            blur.bottomAnchor.constraint(equalTo: pill.bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: pill.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: pill.trailingAnchor),
            tint.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            tint.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),
            tint.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor)
        ])
        return pill
    }

    func configure(income: Double, expense: Double, bars: [AnalyticsFlowBar], periodIndex: Int) {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Денежный поток" : "Monthly Flow"
        incomeLabel.text = "\(isRu ? "Доход" : "Income")\n\(format(income))"
        expenseLabel.text = "\(isRu ? "Расход" : "Expense")\n\(format(expense))"
        let net = income - expense
        let netSign = net >= 0 ? "+" : "-"
        let netStr = "\(netSign)\(format(abs(net)))"
        netLabel.text = isRu ? "Чистый денежный поток: \(netStr)" : "Net cash flow: \(netStr)"
        netLabel.textColor = net >= 0 ? .white : UIColor(red: 1, green: 0.82, blue: 0.82, alpha: 1)
        chartView.configure(bars: bars)
    }

    private func format(_ value: Double) -> String {
        "\(Int(value).formatted())₽"
    }
}

private final class AnalyticsBarsView: UIView {
    private var bars: [AnalyticsFlowBar] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(bars: [AnalyticsFlowBar]) {
        self.bars = bars
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !bars.isEmpty, rect.width > 0, rect.height > 0 else { return }
        let maxValue = max(1, bars.flatMap { [$0.income, $0.expense] }.max() ?? 1)
        let baseY = rect.maxY - 24
        UIColor.white.withAlphaComponent(0.22).setStroke()
        let axis = UIBezierPath()
        axis.move(to: CGPoint(x: 4, y: baseY))
        axis.addLine(to: CGPoint(x: rect.maxX - 4, y: baseY))
        axis.lineWidth = 1
        axis.stroke()

        let groupWidth = rect.width / CGFloat(bars.count)
        for (index, bar) in bars.enumerated() {
            let startX = CGFloat(index) * groupWidth + max(10, (groupWidth - 54) / 2)
            let incomeHeight = max(18, CGFloat(bar.income / maxValue) * (rect.height - 46))
            let expenseHeight = max(18, CGFloat(bar.expense / maxValue) * (rect.height - 46))

            drawLiquidGlassBar(x: startX, y: baseY - incomeHeight, height: incomeHeight, color: UIColor(red: 0.30, green: 0.88, blue: 0.33, alpha: 1), sign: "+")
            drawLiquidGlassBar(x: startX + 30, y: baseY - expenseHeight, height: expenseHeight, color: UIColor(red: 0.86, green: 0.28, blue: 0.29, alpha: 1), sign: "-")

            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attr: [NSAttributedString.Key: Any] = [.font: DS.golosBold(10), .foregroundColor: UIColor.white, .paragraphStyle: style]
            NSString(string: bar.label).draw(in: CGRect(x: CGFloat(index) * groupWidth, y: baseY + 5, width: groupWidth, height: 16), withAttributes: attr)
        }
    }

    private func drawLiquidGlassBar(x: CGFloat, y: CGFloat, height: CGFloat, color: UIColor, sign: String) {
        let barRect = CGRect(x: x, y: y, width: 24, height: max(18, height))
        let path = UIBezierPath(roundedRect: barRect, cornerRadius: 6)

        // Solid color base
        color.withAlphaComponent(0.92).setFill()
        path.fill()

        // Liquid glass specular highlight (top half)
        let specularRect = CGRect(x: barRect.minX, y: barRect.minY, width: barRect.width, height: barRect.height * 0.45)
        let specular = UIBezierPath(roundedRect: specularRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 6, height: 6))
        UIColor.white.withAlphaComponent(0.38).setFill()
        specular.fill()

        // Border
        UIColor.white.withAlphaComponent(0.55).setStroke()
        let border = UIBezierPath(roundedRect: barRect.insetBy(dx: 0.4, dy: 0.4), cornerRadius: 6)
        border.lineWidth = 0.8
        border.stroke()

        let signStyle = NSMutableParagraphStyle()
        signStyle.alignment = .center
        let signAttrs: [NSAttributedString.Key: Any] = [
            .font: DS.golosBold(13),
            .foregroundColor: UIColor.white,
            .paragraphStyle: signStyle
        ]
        NSString(string: sign).draw(in: CGRect(x: barRect.minX, y: barRect.midY - 9, width: barRect.width, height: 18), withAttributes: signAttrs)
    }
}

final class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let backButton = GreenCircleBackButton()
    private let notificationButton = NotificationBellButton()
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let uidLabel = UILabel()
    private let profileRow = ProfileOptionRow(icon: "person.fill")
    private let securityRow = ProfileOptionRow(icon: "shield.fill", showsSwitch: true)
    private let achievementsRow = ProfileOptionRow(icon: "trophy.fill")
    private let settingsRow = ProfileOptionRow(icon: "gearshape.fill", showsSwitch: true)
    private let logoutRow = ProfileOptionRow(icon: "rectangle.portrait.and.arrow.right.fill", iconColor: DS.red)
    private let statsCard = ProfileStatsCard()
    private var dashboard: DashboardResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.965, green: 0.982, blue: 0.974, alpha: 1)
        setupLayout()
        setupActions()
        loadProfile()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocalization),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar),
            name: NSNotification.Name("AvatarChanged"),
            object: nil
        )
        updateLocalization()
        updateAvatar()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        setupTopButtons()
        setupHeader()

        let stack = UIStackView(arrangedSubviews: [
            profileRow,
            securityRow,
            achievementsRow,
            settingsRow,
            logoutRow
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        statsCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsCard)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            backButton.widthAnchor.constraint(equalToConstant: 52),
            backButton.heightAnchor.constraint(equalToConstant: 52),

            notificationButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            notificationButton.widthAnchor.constraint(equalToConstant: 52),
            notificationButton.heightAnchor.constraint(equalToConstant: 52),

            avatarContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 106),
            avatarContainer.heightAnchor.constraint(equalToConstant: 106),

            usernameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            uidLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            uidLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            statsCard.topAnchor.constraint(equalTo: uidLabel.bottomAnchor, constant: 24),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            statsCard.heightAnchor.constraint(equalToConstant: 142),

            stack.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -110)
        ])
    }

    private func setupTopButtons() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backButton)

        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(notificationButton)
    }

    private func setupHeader() {
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.backgroundColor = .white
        avatarContainer.layer.cornerRadius = 53
        avatarContainer.layer.borderWidth = 1
        avatarContainer.layer.borderColor = UIColor.white.cgColor
        avatarContainer.layer.shadowColor = UIColor.black.cgColor
        avatarContainer.layer.shadowOpacity = 0.10
        avatarContainer.layer.shadowRadius = 18
        avatarContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentView.addSubview(avatarContainer)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(named: "avatar_placeholder") ?? UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = DT.accentGreen
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 43
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.isUserInteractionEnabled = true
        avatarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatarTapped)))

        // Edit badge — placed on contentView so it renders OUTSIDE the clipped avatarContainer
        let editBadge = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)))
        editBadge.translatesAutoresizingMaskIntoConstraints = false
        editBadge.tintColor = .white
        editBadge.backgroundColor = DT.accentGreen
        editBadge.contentMode = .center
        editBadge.layer.cornerRadius = 15
        editBadge.layer.borderWidth = 2.5
        editBadge.layer.borderColor = UIColor.white.cgColor
        editBadge.clipsToBounds = true
        editBadge.isUserInteractionEnabled = false
        contentView.addSubview(editBadge)

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = DS.golosBold(28)
        usernameLabel.textColor = DS.textPrimary
        usernameLabel.textAlignment = .center
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.72
        contentView.addSubview(usernameLabel)

        uidLabel.translatesAutoresizingMaskIntoConstraints = false
        uidLabel.font = DS.golosSemi(18)
        uidLabel.textColor = DS.textPrimary
        contentView.addSubview(uidLabel)

        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 86),
            avatarImageView.heightAnchor.constraint(equalToConstant: 86),

            // Badge sits at the bottom-right of avatarContainer, attached to contentView
            editBadge.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 2),
            editBadge.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 2),
            editBadge.widthAnchor.constraint(equalToConstant: 30),
            editBadge.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        profileRow.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        securityRow.switchChanged = { [weak self] enabled in self?.updateTwoFactor(enabled) }
        achievementsRow.addTarget(self, action: #selector(achievementsTapped), for: .touchUpInside)
        settingsRow.switchChanged = { enabled in UserManager.shared.isRussian = enabled }
        logoutRow.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    private func loadProfile() {
        APIService.shared.getDashboard { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let dashboard):
                self.dashboard = dashboard
                UserManager.shared.saveProfile(
                    username: dashboard.userInfo.username,
                    email: dashboard.userInfo.email
                )
                self.updateProfileValues()
            case .failure(_):
                let isRu = UserManager.shared.isRussian
                let alert = UIAlertController(
                    title: isRu ? "Ошибка сервера" : "Server Error",
                    message: isRu ? "Не удалось загрузить данные аккаунта. Сервер временно недоступен." : "Could not load account data. The server is temporarily unavailable.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    UserManager.shared.logout()
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let loginVC = UINavigationController(rootViewController: LoginViewController())
                        loginVC.isNavigationBarHidden = true
                        window.rootViewController = loginVC
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                    }
                }))
                self.present(alert, animated: true)
            }
        }
    }

    private func updateProfileValues() {
        let session = UserManager.shared.session
        usernameLabel.text = session.username
        let uidPrefix = UserManager.shared.isRussian ? "UID:" : "UID:"
        uidLabel.attributedText = coloredPrefix("\(uidPrefix) \(session.userId)", prefix: uidPrefix)
        securityRow.setSwitchOn(session.isTwoFactorEnabled, animated: false)
        settingsRow.setSwitchOn(UserManager.shared.isRussian, animated: false)

        let incomeDecimal = dashboard?.balanceInfo.monthlyIncome ?? Decimal(UserManager.shared.session.monthlyIncome)
        let expenseDecimal = dashboard?.balanceInfo.monthlyExpense ?? Decimal(UserManager.shared.session.monthlyExpense)
        let income = NSDecimalNumber(decimal: incomeDecimal).doubleValue
        let expense = NSDecimalNumber(decimal: expenseDecimal).doubleValue
        statsCard.configure(income: income, expense: expense, streakDays: transactionStreakDays())
    }

    private func transactionStreakDays() -> Int {
        guard let transactions = dashboard?.recentTransactions, !transactions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(transactions.map { calendar.startOfDay(for: $0.createdAt) })
        var cursor = calendar.startOfDay(for: Date())
        var streak = 0

        if !uniqueDays.contains(cursor),
           let latest = uniqueDays.max(),
           calendar.isDate(latest, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor) {
            cursor = latest
        }

        while uniqueDays.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return streak
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        profileRow.configure(
            title: isRu ? "Профиль" : "Profile",
            subtitle: isRu ? "Имя, почта и данные аккаунта" : "Name, email and account details"
        )
        securityRow.configure(
            title: isRu ? "Безопасность" : "Security",
            subtitle: isRu ? "Двухфакторная аутентификация" : "Two-factor authentication"
        )
        achievementsRow.configure(
            title: isRu ? "Достижения" : "Achievements",
            subtitle: isRu ? "Прогресс, победы и накопления" : "Progress, wins and savings"
        )
        settingsRow.configure(
            title: isRu ? "Русский язык" : "Russian language",
            subtitle: isRu ? "Переключить язык приложения" : "Switch the app language"
        )
        logoutRow.configure(
            title: isRu ? "Выйти" : "Logout",
            subtitle: isRu ? "Завершить текущую сессию" : "End the current session"
        )
        logoutRow.setTextColor(DS.red)
        statsCard.updateLocalization()
        updateProfileValues()
    }

    private func coloredPrefix(_ text: String, prefix: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: DS.textPrimary, .font: DS.golosSemi(18)]
        )
        result.addAttributes(
            [.foregroundColor: DT.accentGreen, .font: DS.golosBold(18)],
            range: (text as NSString).range(of: prefix)
        )
        return result
    }

    @objc private func backTapped() {
        animatePress(backButton)
        (tabBarController as? MainTabBarController)?.switchToTab(2)
    }

    @objc private func notificationTapped() {
        animatePress(notificationButton)
        let isRu = UserManager.shared.isRussian
        showInfo(
            title: isRu ? "Уведомления" : "Notifications",
            message: isRu ? "Здесь появятся напоминания о целях и безопасности." : "Goal and security reminders will appear here."
        )
    }

    @objc private func updateAvatar() {
        if let data = UserManager.shared.avatarData(), let image = UIImage(data: data) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(named: "avatar_placeholder") ?? UIImage(systemName: "person.crop.circle.fill")
        }
    }

    @objc private func changeAvatarTapped() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { object, _ in
            guard let image = object as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.82) else { return }
            DispatchQueue.main.async {
                UserManager.shared.saveAvatarData(data)
                self.updateAvatar()
            }
        }
    }

    @objc private func editProfileTapped() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(
            title: isRu ? "Профиль" : "Profile",
            message: isRu ? "Обновите отображаемое имя." : "Update your display name.",
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.text = UserManager.shared.session.username
            field.placeholder = isRu ? "Имя" : "Name"
        }
        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isRu ? "Сохранить" : "Save", style: .default) { [weak self] _ in
            let value = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !value.isEmpty else { return }
            guard value.count <= 32 else {
                self?.showInfo(
                    title: isRu ? "Слишком длинное имя" : "Name is too long",
                    message: isRu ? "Введите имя до 32 символов." : "Use up to 32 characters."
                )
                return
            }
            self?.saveProfileName(value)
        })
        present(alert, animated: true)
    }

    private func saveProfileName(_ username: String) {
        APIService.shared.updateProfile(username: username) { [weak self] result in
            guard let self else { return }
            let isRu = UserManager.shared.isRussian
            switch result {
            case .success(let response):
                let userId = response.userId ?? response.playerId.map(String.init)
                UserManager.shared.saveProfile(
                    username: response.username,
                    email: response.email,
                    userId: userId
                )
                if let isEnabled = response.isTwoFactorEnabled {
                    UserManager.shared.saveTwoFactorEnabled(isEnabled)
                }
                self.updateProfileValues()
                NotificationCenter.default.post(name: NSNotification.Name("UsernameChanged"), object: nil)
            case .failure:
                self.showInfo(
                    title: isRu ? "Не удалось сохранить имя" : "Could not save name",
                    message: isRu ? "Имя не изменено на сервере. Проверьте подключение и попробуйте ещё раз." : "The name was not changed on the server. Check the connection and try again."
                )
            }
        }
    }

    @objc private func achievementsTapped() {
        let isRu = UserManager.shared.isRussian
        showInfo(
            title: isRu ? "Достижения" : "Achievements",
            message: isRu ? "Победы над врагами и серии накоплений скоро будут собраны здесь." : "Enemy wins and saving streaks will be collected here soon."
        )
    }

    @objc private func logoutTapped() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(
            title: isRu ? "Выйти?" : "Log out?",
            message: isRu ? "Текущая сессия будет завершена." : "Your current session will be ended.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isRu ? "Выйти" : "Log out", style: .destructive) { [weak self] _ in
            UserManager.shared.logout()
            guard let window = self?.view.window else { return }
            UIView.transition(with: window, duration: 0.45, options: .transitionCrossDissolve) {
                window.rootViewController = SplashViewController()
            }
        })
        present(alert, animated: true)
    }

    private func updateTwoFactor(_ enabled: Bool) {
        securityRow.setLoading(true)
        APIService.shared.updateTwoFactor(enabled: enabled) { [weak self] result in
            guard let self else { return }
            self.securityRow.setLoading(false)
            switch result {
            case .success(let response):
                UserManager.shared.saveTwoFactorEnabled(response.isTwoFactorEnabled)
                self.securityRow.setSwitchOn(response.isTwoFactorEnabled, animated: true)
            case .failure:
                self.securityRow.setSwitchOn(!enabled, animated: true)
                let isRu = UserManager.shared.isRussian
                self.showInfo(
                    title: isRu ? "Не удалось обновить 2FA" : "Could not update 2FA",
                    message: isRu ? "Проверьте подключение к серверу и попробуйте ещё раз." : "Check the server connection and try again."
                )
            }
        }
    }

    private func showInfo(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func animatePress(_ view: UIView) {
        UIView.animate(withDuration: 0.10, animations: {
            view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5) {
                view.transform = .identity
            }
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private final class ProfileOptionRow: UIControl {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let tintView = UIView()
    private let shineLayer = CAGradientLayer()
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let switchControl = UISwitch()
    private let spinner = UIActivityIndicatorView(style: .medium)
    var switchChanged: ((Bool) -> Void)?

    init(icon: String, iconColor: UIColor = DT.accentGreen, showsSwitch: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 74).isActive = true
        backgroundColor = UIColor.white.withAlphaComponent(0.46)
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 9)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.74).cgColor
        clipsToBounds = false

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius = 24
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        addSubview(blurView)

        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.isUserInteractionEnabled = false
        tintView.backgroundColor = UIColor.white.withAlphaComponent(0.34)
        tintView.layer.cornerRadius = 24
        tintView.layer.cornerCurve = .continuous
        addSubview(tintView)

        shineLayer.colors = [
            UIColor.white.withAlphaComponent(0.72).cgColor,
            UIColor.white.withAlphaComponent(0.08).cgColor,
            iconColor.withAlphaComponent(0.08).cgColor
        ]
        shineLayer.locations = [0, 0.48, 1]
        shineLayer.startPoint = CGPoint(x: 0, y: 0)
        shineLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(shineLayer, at: 0)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = iconColor.withAlphaComponent(0.12)
        iconView.layer.cornerRadius = 26
        iconView.layer.cornerCurve = .continuous
        iconView.layer.borderWidth = 1
        iconView.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
        addSubview(iconView)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold))
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = DS.golosBold(17)
        titleLabel.textColor = DS.textPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78
        addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = DS.golosSemi(12)
        subtitleLabel.textColor = DT.accentGreen
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.74
        addSubview(subtitleLabel)

        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.tintColor = UIColor.systemGray3
        addSubview(chevronView)

        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.onTintColor = DT.accentGreen
        switchControl.isHidden = !showsSwitch
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        addSubview(switchControl)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = DT.accentGreen
        spinner.hidesWhenStopped = true
        addSubview(spinner)

        chevronView.isHidden = showsSwitch

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tintView.topAnchor.constraint(equalTo: topAnchor),
            tintView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 62),
            iconView.heightAnchor.constraint(equalToConstant: 62),

            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: showsSwitch ? switchControl.leadingAnchor : chevronView.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),

            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 18),

            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        shineLayer.frame = bounds
        shineLayer.cornerRadius = 24
        shineLayer.cornerCurve = .continuous
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    func setTextColor(_ color: UIColor) {
        titleLabel.textColor = color
        subtitleLabel.textColor = color
        chevronView.tintColor = color.withAlphaComponent(0.42)
    }

    func setSwitchOn(_ isOn: Bool, animated: Bool) {
        switchControl.setOn(isOn, animated: animated)
    }

    func setLoading(_ loading: Bool) {
        switchControl.isHidden = loading
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.16) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }

    @objc private func switchValueChanged() {
        switchChanged?(switchControl.isOn)
    }
}

private final class ProfileStatsCard: UIView {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let tintView = UIView()
    private let glowLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let iconBadge = UIImageView()
    private let incomeMetric = ProfileMetricPill()
    private let expenseMetric = ProfileMetricPill()
    private let streakMetric = ProfileMetricPill()
    private var income: Double = 0
    private var expense: Double = 0
    private var streakDays: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = DT.accentGreen.withAlphaComponent(0.92)
        layer.cornerRadius = 28
        layer.cornerCurve = .continuous
        layer.shadowColor = DT.accentGreen.cgColor
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.borderWidth = 1.1
        layer.borderColor = UIColor.white.withAlphaComponent(0.62).cgColor
        clipsToBounds = false

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius = 28
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        addSubview(blurView)

        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.isUserInteractionEnabled = false
        tintView.backgroundColor = DT.accentGreen.withAlphaComponent(0.62)
        tintView.layer.cornerRadius = 28
        tintView.layer.cornerCurve = .continuous
        addSubview(tintView)

        glowLayer.colors = [
            UIColor.white.withAlphaComponent(0.42).cgColor,
            UIColor.white.withAlphaComponent(0.08).cgColor,
            UIColor(red: 0.05, green: 0.42, blue: 0.28, alpha: 0.25).cgColor
        ]
        glowLayer.locations = [0, 0.48, 1]
        glowLayer.startPoint = CGPoint(x: 0, y: 0)
        glowLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(glowLayer, at: 0)

        iconBadge.translatesAutoresizingMaskIntoConstraints = false
        iconBadge.image = UIImage(systemName: "sparkles", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        iconBadge.tintColor = .white
        iconBadge.contentMode = .scaleAspectFit
        iconBadge.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconBadge.layer.cornerRadius = 15
        iconBadge.layer.cornerCurve = .continuous
        addSubview(iconBadge)

        titleLabel.font = DS.golosBold(18)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        let row = UIStackView(arrangedSubviews: [incomeMetric, expenseMetric, streakMetric])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tintView.topAnchor.constraint(equalTo: topAnchor),
            tintView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconBadge.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            iconBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconBadge.widthAnchor.constraint(equalToConstant: 30),
            iconBadge.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconBadge.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),

            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            row.heightAnchor.constraint(equalToConstant: 66)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        glowLayer.frame = bounds
        glowLayer.cornerRadius = 28
        glowLayer.cornerCurve = .continuous
    }

    func configure(income: Double, expense: Double, streakDays: Int) {
        self.income = income
        self.expense = expense
        self.streakDays = streakDays
        updateLocalization()
    }

    func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Сводка месяца" : "Month Summary"
        incomeMetric.configure(title: isRu ? "Доходы" : "Income", value: "+\(format(income))")
        expenseMetric.configure(title: isRu ? "Расходы" : "Expense", value: "-\(format(expense))")
        let suffix = isRu ? daysText(streakDays) : "\(streakDays) days"
        streakMetric.configure(title: isRu ? "Серия" : "Streak", value: suffix)
    }

    private func daysText(_ days: Int) -> String {
        let mod10 = days % 10
        let mod100 = days % 100
        let word: String
        if mod10 == 1 && mod100 != 11 {
            word = "день"
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            word = "дня"
        } else {
            word = "дней"
        }
        return "\(days) \(word)"
    }

    private func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: abs(value))) ?? "0")₽"
    }
}

private final class ProfileMetricPill: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.14)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor

        titleLabel.font = DS.golosSemi(11)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = DS.golosBold(16)
        valueLabel.textColor = .white
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.68
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

// MARK: - Представление стеклянного таббара

final class GlassTabBar: UIView {

    var onTabSelected: ((Int) -> Void)?

    private typealias TabItem = (
        active: String,
        inactive: String,
        sfFallback: String,
        isCenter: Bool
    )

    private let items: [TabItem] = [
        ("transact_act",  "transact_inact",  "list.bullet.rectangle.portrait", false),
        ("dashboard_act", "dashboard_inact", "chart.bar.fill",                 false),
        ("main_act",      "main_inact",      "dollarsign.circle.fill",         true),
        ("report_act",    "report_inact",    "doc.text.fill",                  false),
        ("options_act",   "options_inact",   "person.2.fill",                  false)
    ]

    private var buttons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // Эффект размытия
        let blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 38
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 0.85)
        layer.cornerRadius = 38
        layer.borderWidth  = 1.1
        layer.borderColor  = UIColor.white.withAlphaComponent(0.55).cgColor
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius  = 18
        layer.shadowOffset  = CGSize(width: 0, height: 4)

        // Контейнер для кнопок
        let stack = UIStackView()
        stack.axis         = .horizontal
        stack.distribution = .fillEqually
        stack.alignment    = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])

        for (i, item) in items.enumerated() {
            let btn = item.isCenter
                ? makeCenterButton(item)
                : makeRegularButton(item)
            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.isUserInteractionEnabled = true
            container.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false

            let size: CGFloat = item.isCenter ? 68 : 48
            NSLayoutConstraint.activate([
                btn.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                btn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                btn.widthAnchor.constraint(equalToConstant: size),
                btn.heightAnchor.constraint(equalToConstant: size)
            ])

            stack.addArrangedSubview(container)
            buttons.append(btn)
        }
    }

    private func makeRegularButton(_ item: TabItem) -> UIButton {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let activeImg = UIImage(named: item.active)
            ?? UIImage(systemName: item.sfFallback, withConfiguration: cfg)
        let inactiveImg = UIImage(named: item.inactive)
            ?? UIImage(systemName: item.sfFallback, withConfiguration: cfg)?
                .withTintColor(.systemGray2, renderingMode: .alwaysOriginal)

        b.setImage(inactiveImg?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.setImage(activeImg?.withRenderingMode(.alwaysOriginal),   for: .selected)
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }

    private func makeCenterButton(_ item: TabItem) -> UIButton {
        let b = UIButton(type: .custom)
        b.backgroundColor = .clear
        let cfg = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let inactiveImg = UIImage(named: item.inactive)
            ?? UIImage(systemName: item.sfFallback, withConfiguration: cfg)
        let activeImg = UIImage(named: item.active)
            ?? UIImage(systemName: item.sfFallback, withConfiguration: cfg)
        b.setImage(inactiveImg?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.setImage(activeImg?.withRenderingMode(.alwaysOriginal),   for: .selected)
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }

    @objc private func tabTapped(_ sender: UIButton) {
        selectTab(sender.tag)
        onTabSelected?(sender.tag)
    }

    func selectTab(_ index: Int, animated: Bool = true) {
        for (i, btn) in buttons.enumerated() {
            let isActive = (i == index)
            btn.isSelected = isActive

            let duration = animated ? 0.3 : 0.0
            UIView.animate(withDuration: duration) {
                if isActive {
                    btn.layer.shadowColor   = UIColor(red: 30/255, green: 140/255, blue: 98/255, alpha: 1).cgColor
                    btn.layer.shadowOpacity = 0.45
                    btn.layer.shadowRadius  = 12
                    btn.layer.shadowOffset  = CGSize(width: 0, height: 4)
                } else {
                    btn.layer.shadowColor   = UIColor.black.cgColor
                    btn.layer.shadowOpacity = 0.08
                    btn.layer.shadowRadius  = 4
                    btn.layer.shadowOffset  = CGSize(width: 0, height: 2)
                }
            }
        }

        guard animated, index < buttons.count else { return }
        let btn = buttons[index]

        // Анимация нажатия (отскок)
        UIView.animate(withDuration: 0.10) {
            btn.transform = CGAffineTransform(scaleX: 0.86, y: 0.86)
        } completion: { _ in
            UIView.animate(
                withDuration: 0.30,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: .allowUserInteraction
            ) {
                btn.transform = .identity
            }
        }
    }
}
