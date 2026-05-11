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
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let welcomeLabel: UILabel = {
        let l = UILabel()
        l.text = "С возвращением!"
        l.font = DS.golosSemi(14)
        l.textColor = DS.accent
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Боец"
        l.font = DS.golosBold(22)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let notifButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "notf_inact"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

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
        l.text = "Цели / Враги"
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
        b.setImage(UIImage(systemName: "chevron.compact.left",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .light)),
                   for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.25)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(pageLeft), for: .touchUpInside)
        return b
    }()

    private lazy var rightArrowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.compact.right",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .light)),
                   for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.25)
        b.translatesAutoresizingMaskIntoConstraints = false
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
        
        // Отображение начальных данных во время загрузки
        updateUI()
        
        viewModel.loadDashboard()
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

        let headerStack = UIStackView(arrangedSubviews: [avatarImageView, welcomeStack, UIView(), notifButton, logoutButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        [headerStack, balanceCard, goalsTitleLabel, savingsGoalCard, pagingContainer]
            .forEach { contentView.addSubview($0) }

        pagingContainer.addSubview(horizontalScrollView)
        pagingContainer.addSubview(leftArrowButton)
        pagingContainer.addSubview(rightArrowButton)
        
        pagingContainer.clipsToBounds = true
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
            notifButton.widthAnchor.constraint(equalToConstant: 40),
            notifButton.heightAnchor.constraint(equalToConstant: 40),
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
            leftArrowButton.leadingAnchor.constraint(equalTo: pagingContainer.leadingAnchor),
            leftArrowButton.centerYAnchor.constraint(equalTo: pagingContainer.centerYAnchor),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 20),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 100),

            rightArrowButton.trailingAnchor.constraint(equalTo: pagingContainer.trailingAnchor),
            rightArrowButton.centerYAnchor.constraint(equalTo: pagingContainer.centerYAnchor),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 20),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    // MARK: - Обработка действий (Actions) & Привязка (Binding)

    private func setupActions() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        savingsGoalCard.onFightTapped = { [weak self] in self?.navigateToBattle() }
        
        recentActivityView.onDeleteTransaction = { [weak self] id in
            self?.handleDeleteTransaction(id: id)
        }
    }

    @objc private func handleLogout() {
        let alert = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
            UserManager.shared.logout()
            guard let window = self.view.window else { return }
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = SplashViewController()
            }, completion: nil)
        }))
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
            DispatchQueue.main.async { self?.refreshControl.endRefreshing() }
        }
    }

    // MARK: - Обновление UI

    private func updateUI() {
        refreshControl.endRefreshing()

        // Заголовок
        let username = viewModel.dashboard?.userInfo.username ?? UserManager.shared.session.username
        nameLabel.text = username

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

        // Цели накопления
        if let goal = viewModel.dashboard?.activeGoal {
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
        let pct = savingsTargetAmount > 0 ? savingsCurrentAmount / savingsTargetAmount : 0
        savingsGoalCard.configure(
            goalName: savingsGoalName,
            current:  formatCurrency(savingsCurrentAmount),
            target:   formatCurrency(savingsTargetAmount),
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
