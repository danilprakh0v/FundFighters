/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: DashboardViewControllerUIKit.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/
Назначение: Главный экран Dashboard — вертикальный скролл + горизонтальные страницы.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class DashboardViewControllerUIKit: UIViewController, UIScrollViewDelegate {

    private let viewModel = DashboardViewModel()
    private var currentPage: Int = 0

    // Локальный стейт накопления (синхронизируется с BattleVC)
    private var savingsCurrentAmount: Double = 23250
    private var savingsTargetAmount: Double  = 62000
    private var savingsGoalName: String      = "Playstation 5 Slim"

    // MARK: - UI
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

    // MARK: Header components
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
        l.text = "Welcome back!"
        l.font = DS.golosSemi(14)
        l.textColor = DS.accent
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Fighter"
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

    // MARK: Cards
    private let balanceCard = BalanceCardView()

    private let goalsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Saving Goals / Enemies"
        l.font = DS.golosBold(20)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let savingsGoalCard = SavingsGoalCardView()

    // MARK: Horizontal paging
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.bg
        setupLayout()
        setupActions()
        bindViewModel()
        
        // Show mocks immediately while loading
        updateUI()
        
        viewModel.loadDashboard()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let welcomeStack = UIStackView(arrangedSubviews: [welcomeLabel, nameLabel])
        welcomeStack.axis = .vertical
        welcomeStack.spacing = 2
        welcomeStack.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [avatarImageView, welcomeStack, UIView(), notifButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        [headerStack, balanceCard, goalsTitleLabel, savingsGoalCard, pagingContainer]
            .forEach { contentView.addSubview($0) }

        pagingContainer.addSubview(horizontalScrollView)
        pagingContainer.clipsToBounds = true
        horizontalScrollView.addSubview(horizontalStack)

        contentView.addSubview(leftArrowButton)
        contentView.addSubview(rightArrowButton)

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

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Header
            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            notifButton.widthAnchor.constraint(equalToConstant: 40),
            notifButton.heightAnchor.constraint(equalToConstant: 40),

            // Balance Card
            balanceCard.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            balanceCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            balanceCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            // Goals title
            goalsTitleLabel.topAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: 24),
            goalsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            // Goals card
            savingsGoalCard.topAnchor.constraint(equalTo: goalsTitleLabel.bottomAnchor, constant: 12),
            savingsGoalCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            savingsGoalCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            // Paging container — минимальная высота гарантирует видимость контента
            pagingContainer.topAnchor.constraint(equalTo: savingsGoalCard.bottomAnchor, constant: 24),
            pagingContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pagingContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pagingContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            pagingContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 420),

            // Horizontal scroll заполняет контейнер
            horizontalScrollView.topAnchor.constraint(equalTo: pagingContainer.topAnchor),
            horizontalScrollView.leadingAnchor.constraint(equalTo: pagingContainer.leadingAnchor),
            horizontalScrollView.trailingAnchor.constraint(equalTo: pagingContainer.trailingAnchor),
            horizontalScrollView.bottomAnchor.constraint(equalTo: pagingContainer.bottomAnchor),

            // Stack внутри scroll
            horizontalStack.topAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.trailingAnchor),
            horizontalStack.heightAnchor.constraint(equalTo: horizontalScrollView.frameLayoutGuide.heightAnchor),

            // Стрелки по бокам — тонкие и вписанные в боковые 20pt отступы
            leftArrowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftArrowButton.centerYAnchor.constraint(equalTo: pagingContainer.centerYAnchor),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 20),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 100),

            rightArrowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightArrowButton.centerYAnchor.constraint(equalTo: pagingContainer.centerYAnchor),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 20),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    // MARK: - Actions & Binding

    private func setupActions() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        savingsGoalCard.onFightTapped = { [weak self] in self?.navigateToBattle() }
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

    // MARK: - Update UI

    private func updateUI() {
        refreshControl.endRefreshing()

        // Header  — динамическое имя из API
        if let username = viewModel.dashboard?.userInfo.username {
            nameLabel.text = username
        }

        // Balance Card
        if let balance = viewModel.dashboard?.balanceInfo {
            let totalStr   = formatCurrency(NSDecimalNumber(decimal: balance.totalBalance).doubleValue)
            let incomeStr  = formatCurrency(NSDecimalNumber(decimal: balance.monthlyIncome).doubleValue)
            let expenseStr = formatCurrency(NSDecimalNumber(decimal: balance.monthlyExpense).doubleValue)
            let total      = NSDecimalNumber(decimal: balance.totalBalance).doubleValue
            let income     = NSDecimalNumber(decimal: balance.monthlyIncome).doubleValue
            let expense    = NSDecimalNumber(decimal: balance.monthlyExpense).doubleValue
            let incPct     = total > 0 ? String(format: "%.0f%%", (income / total) * 100) : "—"
            let expPct     = total > 0 ? String(format: "%.0f%%", (expense / total) * 100) : "—"
            balanceCard.configure(balance: totalStr, income: incomeStr, expense: expenseStr,
                                  isHidden: false, incomePercent: incPct, expensePercent: expPct)
        } else {
            // Моковые данные, пока API не вернул ответ
            balanceCard.configure(balance: "145,000.99₽", income: "100,000₽", expense: "45,000₽",
                                  isHidden: false, incomePercent: "27%", expensePercent: "12%")
        }

        // Savings Goals
        if let goal = viewModel.dashboard?.activeGoal {
            savingsCurrentAmount = NSDecimalNumber(decimal: goal.currentAmount).doubleValue
            savingsTargetAmount  = NSDecimalNumber(decimal: goal.targetAmount).doubleValue
            savingsGoalName      = goal.goalName
        }
        refreshSavingsCard()

        // Recent Activity
        let transactions = viewModel.dashboard?.recentTransactions ?? []
        recentActivityView.configure(transactions: transactions)

        // Expense Chart
        let categories = viewModel.dashboard?.expenseCategories ?? []
        expenseChartView.configure(categories: categories)

        // Battle
        let battles = viewModel.dashboard?.recentBattles ?? []
        battleCardView.configure(battles: battles)

        updateArrowStates()
    }

    private func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","
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

    // MARK: - Paging

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
