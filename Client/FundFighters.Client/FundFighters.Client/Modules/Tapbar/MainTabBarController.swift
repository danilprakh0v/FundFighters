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
            rootViewController: AnalyticsPlaceholderViewController())
        let mainVC = UINavigationController(
            rootViewController: DashboardViewControllerUIKit())
        let reportsVC = UINavigationController(
            rootViewController: ReportsViewController())
        let profileVC = UINavigationController(
            rootViewController: ProfilePlaceholderViewController())

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

// MARK: - Заглушки для вкладок (Coming Soon)

final class AnalyticsPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Аналитика\nСкоро в приложении"
        label.font = DS.golosBold(22)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

final class ProfilePlaceholderViewController: UIViewController {
    private let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        label.font = DS.golosBold(22)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
        updateLocalization()
    }
    
    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        label.text = isRu ? "Профиль\nСкоро в приложении" : "Profile\nComing soon"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
