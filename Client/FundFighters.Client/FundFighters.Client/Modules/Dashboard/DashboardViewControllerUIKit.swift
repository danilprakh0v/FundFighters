/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client/Backend Service])
Файл: DashboardViewControllerUIKit.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Dashboard/
Назначение: Главный экран приложения (Dashboard)
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class DashboardViewControllerUIKit: UIViewController, UIScrollViewDelegate {

    // MARK: - Свойства (Properties)

    private let viewModel = DashboardViewModel()
    private var currentPage: Int = 0

    // Состояние накопления (синхронизируется с BattleVC)
    private var savingsCurrentAmount: Double = 0
    private var savingsTargetAmount: Double  = 0
    private var savingsGoalName: String      = "Нет активной цели"

    // MARK: - UI Элементы

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: Компоненты заголовка

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "avatar_placeholder")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let welcomeLabel: UILabel = {
        let l = UILabel()
        l.text = "С возвращением!"
        l.font = DS.golosSemi(13)
        l.textColor = DS.accent
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.70
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Боец"
        l.font = DS.golosBold(22)
        l.textColor = DS.textPrimary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.62
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var langButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.title = UserManager.shared.isRussian ? "RU" : "EN"
        cfg.image = UIImage(systemName: "globe")
        cfg.imagePadding = 3
        cfg.baseBackgroundColor = DS.accent.withAlphaComponent(0.12)
        cfg.baseForegroundColor = DS.accent
        cfg.cornerStyle = .capsule
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        let b = UIButton(configuration: cfg)
        b.titleLabel?.font = DS.golosSemi(14)
        b.titleLabel?.numberOfLines = 1
        b.titleLabel?.lineBreakMode = .byClipping
        b.layer.borderColor = DS.accent.withAlphaComponent(0.22).cgColor
        b.layer.borderWidth = 1
        b.layer.shadowColor = DS.accent.cgColor
        b.layer.shadowOpacity = 0.10
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 8
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(toggleLang), for: .touchUpInside)
        return b
    }()

    private let notifButton = NotificationBellButton()

    private let logoutButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        b.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: cfg), for: .normal)
        b.tintColor = .systemRed.withAlphaComponent(0.7)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: Карточки

    private let balanceCard = BalanceCardView()

    private let goalsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Goals / Enemies"
        l.font = DS.golosBold(20)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let savingsGoalCard = SavingsGoalCardView()

    // MARK: Горизонтальный скролл (Paging)

    private let pagingContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var horizontalScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.clipsToBounds = false
        sv.delegate = self
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let horizontalStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 0
        s.alignment = .top
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let recentActivityView = RecentActivityViewUIKit()
    private let expenseChartView   = ExpenseChartViewUIKit()
    private let battleCardView     = BattleCardViewUIKit()

    private lazy var leftArrowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)),
                   for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.58)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        b.layer.cornerRadius = 16
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.08
        b.layer.shadowRadius = 10
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.translatesAutoresizingMaskIntoConstraints = false
        decoratePageArrow(b)
        b.addTarget(self, action: #selector(pageArrowTouchDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(pageArrowTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        b.addTarget(self, action: #selector(pageLeft), for: .touchUpInside)
        return b
    }()

    private lazy var rightArrowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)),
                   for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.58)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        b.layer.cornerRadius = 16
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.08
        b.layer.shadowRadius = 10
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.translatesAutoresizingMaskIntoConstraints = false
        decoratePageArrow(b)
        b.addTarget(self, action: #selector(pageArrowTouchDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(pageArrowTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        b.addTarget(self, action: #selector(pageRight), for: .touchUpInside)
        return b
    }()

    private let refreshControl = UIRefreshControl()

    // MARK: - Жизненный цикл (Lifecycle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.bg
        setupLayout()
        setupActions()
        bindViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAvatar), name: NSNotification.Name("AvatarChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUsername), name: NSNotification.Name("UsernameChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEnemyGoal), name: NSNotification.Name("EnemyChanged"), object: nil)
        updateLocalization()
        updateAvatar()
        
        // Отображение начальных данных во время загрузки
        updateUI()
        
        viewModel.loadDashboard()
    }
    
    @objc private func toggleLang() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.langButton.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        } completion: { _ in
            UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.6, options: [.allowUserInteraction]) {
                self.langButton.transform = .identity
            }
        }
        UserManager.shared.isRussian.toggle()
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        UIView.transition(with: langButton, duration: 0.22, options: [.transitionCrossDissolve, .allowUserInteraction]) {
            self.langButton.configuration?.title = isRu ? "RU" : "EN"
            self.langButton.configuration?.baseBackgroundColor = DS.accent.withAlphaComponent(isRu ? 0.18 : 0.12)
        }
        welcomeLabel.text = isRu ? "С возвращением" : "Welcome back"
        goalsTitleLabel.text = isRu ? "Цели / Враги" : "Goals / Enemies"
        if savingsTargetAmount <= 0 {
            savingsGoalName = isRu ? "Нет активной цели" : "No active goal"
        }
        refreshSavingsCard()
    }

    @objc private func updateAvatar() {
        if let data = UserManager.shared.avatarData(), let image = UIImage(data: data) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(named: "avatar_placeholder")
        }
    }

    @objc private func updateUsername() {
        // Always use locally stored username (user may have customized it)
        nameLabel.text = UserManager.shared.session.username
    }

    @objc private func updateEnemyGoal() {
        let session = UserManager.shared.session
        if !session.savingsGoalName.isEmpty {
            savingsGoalName = session.savingsGoalName
            savingsCurrentAmount = session.savingsCurrent
            savingsTargetAmount = session.savingsTarget
            refreshSavingsCard()
            battleCardView.configure(battles: viewModel.dashboard?.recentBattles ?? [])
        }
    }

    private func decoratePageArrow(_ button: UIButton) {
        let blur: UIVisualEffectView
        if #available(iOS 26.0, *) {
            blur = UIVisualEffectView(effect: UIGlassEffect())
        } else {
            blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        }
        blur.isUserInteractionEnabled = false
        blur.alpha = 0.62
        blur.clipsToBounds = true
        blur.layer.cornerRadius = 16
        blur.layer.cornerCurve = .continuous
        blur.layer.borderWidth = 1
        blur.layer.borderColor = UIColor.white.withAlphaComponent(0.86).cgColor
        blur.translatesAutoresizingMaskIntoConstraints = false
        button.insertSubview(blur, at: 0)
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: button.topAnchor),
            blur.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: button.trailingAnchor)
        ])
        DispatchQueue.main.async {
            if let imageView = button.imageView {
                button.bringSubviewToFront(imageView)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновление данных при появлении экрана для синхронизации бюджета
        viewModel.loadDashboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserManager.shared.hasSeenTutorial {
            let tutorialVC = TutorialViewController()
            tutorialVC.modalPresentationStyle = .overFullScreen
            tutorialVC.modalTransitionStyle = .crossDissolve
            present(tutorialVC, animated: true) {
                UserManager.shared.hasSeenTutorial = true
            }
        }
    }

    // MARK: - Настройка верстки (Layout)

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let welcomeStack = UIStackView(arrangedSubviews: [welcomeLabel, nameLabel])
        welcomeStack.axis = .vertical
        welcomeStack.spacing = 2
        welcomeStack.translatesAutoresizingMaskIntoConstraints = false
        welcomeStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        welcomeStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        welcomeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let headerStack = UIStackView(arrangedSubviews: [avatarImageView, welcomeStack, UIView(), langButton, notifButton, logoutButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        [headerStack, balanceCard, goalsTitleLabel, savingsGoalCard, pagingContainer]
            .forEach { contentView.addSubview($0) }

        pagingContainer.addSubview(horizontalScrollView)
        pagingContainer.addSubview(leftArrowButton)
        pagingContainer.addSubview(rightArrowButton)
        
        pagingContainer.clipsToBounds = false
        horizontalScrollView.addSubview(horizontalStack)

        let screenWidth = UIScreen.main.bounds.width
        let pad = DS.screenPad

        for innerView in [recentActivityView, expenseChartView, battleCardView] {
            let wrapper = UIView()
            wrapper.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(innerView)
            NSLayoutConstraint.activate([
                wrapper.widthAnchor.constraint(equalToConstant: screenWidth),
                innerView.topAnchor.constraint(equalTo: wrapper.topAnchor),
                innerView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: pad),
                innerView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -pad),
                innerView.bottomAnchor.constraint(lessThanOrEqualTo: wrapper.bottomAnchor)
            ])
            horizontalStack.addArrangedSubview(wrapper)
        }

        scrollView.refreshControl = refreshControl

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Заголовок (Header)
            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            langButton.widthAnchor.constraint(equalToConstant: 78),
            langButton.heightAnchor.constraint(equalToConstant: 32),
            notifButton.widthAnchor.constraint(equalToConstant: 44),
            notifButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 40),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),

            // Карточка баланса
            balanceCard.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            balanceCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            balanceCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            // Заголовок целей
            goalsTitleLabel.topAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: 24),
            goalsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            // Карточка накоплений
            savingsGoalCard.topAnchor.constraint(equalTo: goalsTitleLabel.bottomAnchor, constant: 12),
            savingsGoalCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            savingsGoalCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            // Контейнер пейджинга
            pagingContainer.topAnchor.constraint(equalTo: savingsGoalCard.bottomAnchor, constant: 24),
            pagingContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pagingContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pagingContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            pagingContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 420),

            // Горизонтальный скролл
            horizontalScrollView.topAnchor.constraint(equalTo: pagingContainer.topAnchor),
            horizontalScrollView.leadingAnchor.constraint(equalTo: pagingContainer.leadingAnchor),
            horizontalScrollView.trailingAnchor.constraint(equalTo: pagingContainer.trailingAnchor),
            horizontalScrollView.bottomAnchor.constraint(equalTo: pagingContainer.bottomAnchor),

            // Стек внутри горизонтального скролла
            horizontalStack.topAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.trailingAnchor),
            horizontalStack.heightAnchor.constraint(equalTo: horizontalScrollView.frameLayoutGuide.heightAnchor),

            // Кнопки навигации (стрелки)
            leftArrowButton.leadingAnchor.constraint(equalTo: pagingContainer.leadingAnchor, constant: 4),
            leftArrowButton.centerYAnchor.constraint(equalTo: pagingContainer.centerYAnchor),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 32),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 32),

            rightArrowButton.trailingAnchor.constraint(equalTo: pagingContainer.trailingAnchor, constant: -4),
            rightArrowButton.centerYAnchor.constraint(equalTo: pagingContainer.centerYAnchor),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 32),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    // MARK: - Обработка действий (Actions) & Привязка (Binding)

    private func setupActions() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        notifButton.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)
        savingsGoalCard.onFightTapped = { [weak self] in self?.navigateToBattle() }
        
        recentActivityView.onDeleteTransaction = { [weak self] id in
            self?.handleDeleteTransaction(id: id)
        }

        // Avatar tap -> navigate to Profile tab
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(avatarTap)
    }

    @objc private func avatarTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.10, animations: {
            self.avatarImageView.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }, completion: { _ in
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5) {
                self.avatarImageView.transform = .identity
            }
        })
        (tabBarController as? MainTabBarController)?.switchToTab(4)
    }

    @objc private func handleLogout() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(
            title: isRu ? "Выйти?" : "Log out?",
            message: isRu ? "Текущая сессия будет завершена." : "Your current session will be ended.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isRu ? "Выйти" : "Log out", style: .destructive, handler: { _ in
            UserManager.shared.logout()
            guard let window = self.view.window else { return }
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = SplashViewController()
            }, completion: nil)
        }))
        present(alert, animated: true)
    }

    @objc private func handleNotifications() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(
            title: isRu ? "Уведомления" : "Notifications",
            message: isRu ? "Здесь будут напоминания по целям, отчётам и безопасности." : "Goal, report and security reminders will appear here.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func handleDeleteTransaction(id: String) {
        APIService.shared.deleteTransaction(transactionId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.viewModel.loadDashboard()
                case .failure(let error):
                    print("Error deleting transaction: \(error)")
                }
            }
        }
    }

    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
                self?.refreshControl.endRefreshing()
            }
        }
        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
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
                self?.present(alert, animated: true)
            }
        }
    }

    // MARK: - Обновление UI

    private func updateUI() {
        refreshControl.endRefreshing()

        // Заголовок — берём локально сохранённое имя, не перетираем его серверным
        let localName = UserManager.shared.session.username
        let serverName = viewModel.dashboard?.userInfo.username ?? ""
        let username = (localName == "Fighter" || localName.isEmpty) ? serverName : localName
        nameLabel.text = username.isEmpty ? localName : username

        // Карточка баланса
        if let balance = viewModel.dashboard?.balanceInfo {
            let total      = NSDecimalNumber(decimal: balance.totalBalance).doubleValue
            let income     = NSDecimalNumber(decimal: balance.monthlyIncome).doubleValue
            let expense    = NSDecimalNumber(decimal: balance.monthlyExpense).doubleValue
            let totalStr   = formatCurrency(total)
            let incomeStr  = formatCurrency(income)
            let expenseStr = formatCurrency(expense)
            let incPct     = total > 0 ? String(format: "%.0f%%", (income / total) * 100) : "0%"
            let expPct     = total > 0 ? String(format: "%.0f%%", (expense / total) * 100) : "0%"
            balanceCard.configure(balance: totalStr, income: incomeStr, expense: expenseStr,
                                  isHidden: false, incomePercent: incPct, expensePercent: expPct)
        } else {
            // Данные для нового пользователя
            let session = UserManager.shared.session
            balanceCard.configure(
                balance: formatCurrency(session.totalBalance),
                income: formatCurrency(session.monthlyIncome),
                expense: formatCurrency(session.monthlyExpense),
                isHidden: false,
                incomePercent: "0%",
                expensePercent: "0%"
            )
        }

        // Цели накопления. Пока цель работает как мок, локальная сессия важнее API,
        // чтобы прогресс не сбрасывался после refresh / возврата с битвы.
        let sessionGoal = UserManager.shared.session
        if sessionGoal.savingsTarget > 0 {
            savingsCurrentAmount = sessionGoal.savingsCurrent
            savingsTargetAmount  = sessionGoal.savingsTarget
            savingsGoalName      = sessionGoal.savingsGoalName
        } else if let goal = viewModel.dashboard?.activeGoal {
            savingsCurrentAmount = NSDecimalNumber(decimal: goal.currentAmount).doubleValue
            savingsTargetAmount  = NSDecimalNumber(decimal: goal.targetAmount).doubleValue
            savingsGoalName      = goal.goalName
        } else {
            savingsCurrentAmount = UserManager.shared.session.savingsCurrent
            savingsTargetAmount  = UserManager.shared.session.savingsTarget
            savingsGoalName      = UserManager.shared.session.savingsGoalName
        }
        refreshSavingsCard()

        // Недавняя активность
        let transactions = viewModel.dashboard?.recentTransactions ?? []
        recentActivityView.configure(transactions: transactions)

        // График расходов
        let categories = viewModel.dashboard?.expenseCategories ?? []
        expenseChartView.configure(categories: categories)

        // Битвы
        let battles = viewModel.dashboard?.recentBattles ?? []
        battleCardView.configure(battles: battles)

        updateArrowStates()
    }

    private func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = " "
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 0
        return (fmt.string(from: NSNumber(value: value)) ?? "\(value)") + "₽"
    }

    @objc private func handleRefresh() { viewModel.loadDashboard() }

    private func refreshSavingsCard() {
        let current = savingsTargetAmount > 0 ? savingsCurrentAmount : 23250
        let target = savingsTargetAmount > 0 ? savingsTargetAmount : 62000
        let goalName = savingsTargetAmount > 0 ? savingsGoalName : "PlayStation 5 Slim"
        let pct = target > 0 ? current / target : 0
        savingsGoalCard.configure(
            goalName: goalName,
            current:  formatCurrency(current),
            target:   formatCurrency(target),
            percent:  String(format: "%.1f%%", pct * 100),
            progress: pct
        )
    }

    private func navigateToBattle() {
        let battleVC = BattleViewController(
            currentAmount: savingsCurrentAmount,
            targetAmount:  savingsTargetAmount,
            goalName:      savingsGoalName
        )
        battleVC.modalPresentationStyle = .fullScreen

        battleVC.onSavingsUpdated = { [weak self] current, target, name in
            guard let self = self else { return }
            self.savingsCurrentAmount = current
            self.savingsTargetAmount  = target
            self.savingsGoalName      = name
            UserManager.shared.saveSavingsGoal(current: current, target: target, name: name)
            self.refreshSavingsCard()
        }

        present(battleVC, animated: true)
    }

    // MARK: - Пейджинг (Paging)

    @objc private func pageLeft() {
        guard currentPage > 0 else { return }
        currentPage -= 1
        scrollToPage(currentPage)
    }

    @objc private func pageRight() {
        guard currentPage < 2 else { return }
        currentPage += 1
        scrollToPage(currentPage)
    }

    @objc private func pageArrowTouchDown(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let isRight = sender === rightArrowButton
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            sender.transform = CGAffineTransform(scaleX: isRight ? 1.20 : 1.12, y: 0.88)
            sender.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        }
    }

    @objc private func pageArrowTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.58, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .beginFromCurrentState]) {
            sender.transform = .identity
            sender.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        }
    }

    private func scrollToPage(_ page: Int) {
        let x = CGFloat(page) * horizontalScrollView.bounds.width
        horizontalScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        updateArrowStates()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === horizontalScrollView else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        currentPage = page
        updateArrowStates()
    }

    private func updateArrowStates() {
        leftArrowButton.alpha  = currentPage == 0 ? 0 : 1
        rightArrowButton.alpha = currentPage == 2 ? 0 : 1
        leftArrowButton.isUserInteractionEnabled  = currentPage != 0
        rightArrowButton.isUserInteractionEnabled = currentPage != 2
    }
}
