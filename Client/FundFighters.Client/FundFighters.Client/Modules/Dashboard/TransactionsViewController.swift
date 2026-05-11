/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client/Backend Service])
Файл: TransactionsViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Dashboard/
Назначение: Контроллер списка транзакций пользователя
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class TransactionsViewController: UIViewController {

    // MARK: - Состояние (State)

    private var transactions: [TransactionResponse] = []
    private var filteredTransactions: [TransactionResponse] = []
    private var currentDate = Date()

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        df.locale = Locale(identifier: "en_US")
        return df
    }()

    private let timeFmt: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    // MARK: - UI Элементы: Заголовок

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        b.tintColor = .black
        b.backgroundColor = UIColor(red: 30/255, green: 140/255, blue: 98/255, alpha: 1)
        b.layer.cornerRadius = 22
        b.layer.cornerCurve = .continuous
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Транзакции"
        l.font = DS.golosBold(34)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bellButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "notf_inact"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - UI Элементы: Карточка баланса

    private let balanceCard = BalanceCardView()

    // MARK: - UI Элементы: Контейнер

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.96, alpha: 1)
        v.layer.cornerRadius = 32
        v.layer.cornerCurve = .continuous
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - UI Элементы: Переключатель дат

    private lazy var prevDayButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        b.tintColor = DS.accent
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(prevDay), for: .touchUpInside)
        return b
    }()

    private lazy var nextDayButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.right", withConfiguration: cfg), for: .normal)
        b.tintColor = DS.accent
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(nextDay), for: .touchUpInside)
        return b
    }()

    private let todayLabel: UILabel = {
        let l = UILabel()
        l.text = "Сегодня"
        l.font = DS.golosBold(15)
        l.textColor = DS.accent
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateSwitcherView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.07
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = DS.golosMedium(15)
        l.textColor = UIColor.secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateArrow: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down",
                                            withConfiguration: cfg))
        iv.tintColor = UIColor.tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - UI Элементы: Таблица

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Нет транзакций за этот день"
        l.font = DS.golosMedium(16)
        l.textColor = .systemGray3
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    // MARK: - UI Элементы: Кнопка добавления

    private lazy var addBtn: LiquidGlassActionButton = {
        let b = LiquidGlassActionButton(title: "Добавить транзакцию")
        b.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Жизненный цикл (Lifecycle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupTableView()
        updateDateUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Настройка верстки (Layout)

    private func setupLayout() {
        [backButton, titleLabel, bellButton, balanceCard, containerView].forEach {
            view.addSubview($0)
        }

        [dateSwitcherView, dateLabel, dateArrow, tableView, emptyLabel, addBtn]
            .forEach { containerView.addSubview($0) }

        [prevDayButton, todayLabel, nextDayButton].forEach { dateSwitcherView.addSubview($0) }

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 4),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            bellButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            bellButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bellButton.widthAnchor.constraint(equalToConstant: 48),
            bellButton.heightAnchor.constraint(equalToConstant: 48),

            balanceCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            balanceCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            balanceCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            containerView.topAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            dateSwitcherView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            dateSwitcherView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateSwitcherView.heightAnchor.constraint(equalToConstant: 36),

            prevDayButton.leadingAnchor.constraint(equalTo: dateSwitcherView.leadingAnchor, constant: 10),
            prevDayButton.centerYAnchor.constraint(equalTo: dateSwitcherView.centerYAnchor),
            prevDayButton.widthAnchor.constraint(equalToConstant: 28),
            prevDayButton.heightAnchor.constraint(equalToConstant: 36),

            todayLabel.leadingAnchor.constraint(equalTo: prevDayButton.trailingAnchor, constant: 4),
            todayLabel.centerYAnchor.constraint(equalTo: dateSwitcherView.centerYAnchor),

            nextDayButton.leadingAnchor.constraint(equalTo: todayLabel.trailingAnchor, constant: 4),
            nextDayButton.centerYAnchor.constraint(equalTo: dateSwitcherView.centerYAnchor),
            nextDayButton.widthAnchor.constraint(equalToConstant: 28),
            nextDayButton.heightAnchor.constraint(equalToConstant: 36),
            
            dateSwitcherView.trailingAnchor.constraint(equalTo: nextDayButton.trailingAnchor, constant: 10),

            dateLabel.centerYAnchor.constraint(equalTo: dateSwitcherView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateSwitcherView.trailingAnchor, constant: 12),

            dateArrow.centerYAnchor.constraint(equalTo: dateSwitcherView.centerYAnchor),
            dateArrow.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 4),
            dateArrow.widthAnchor.constraint(equalToConstant: 13),
            dateArrow.heightAnchor.constraint(equalToConstant: 13),

            addBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140),
            addBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            addBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            addBtn.heightAnchor.constraint(equalToConstant: 56),

            tableView.topAnchor.constraint(equalTo: dateSwitcherView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addBtn.topAnchor, constant: -16),

            emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "Cell")
        tableView.contentInset = .zero
    }

    // MARK: - Загрузка данных

    private func loadData() {
        APIService.shared.getDashboard { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let dashboard):
                    self.transactions = dashboard.recentTransactions
                    let b = dashboard.balanceInfo
                    let total   = NSDecimalNumber(decimal: b.totalBalance).doubleValue
                    let income  = NSDecimalNumber(decimal: b.monthlyIncome).doubleValue
                    let expense = NSDecimalNumber(decimal: b.monthlyExpense).doubleValue
                    self.balanceCard.configure(
                        balance:        self.formatCurrency(total),
                        income:         self.formatCurrency(income),
                        expense:        self.formatCurrency(expense),
                        isHidden:       false,
                        incomePercent:  total > 0 ? String(format: "%.0f%%", income  / total * 100) : "0%",
                        expensePercent: total > 0 ? String(format: "%.0f%%", expense / total * 100) : "0%"
                    )
                    self.filterAndReload()

                case .failure:
                    self.transactions = []
                    self.balanceCard.configure(
                        balance: "0₽", income: "0₽", expense: "0₽",
                        isHidden: false, incomePercent: "0%", expensePercent: "0%"
                    )
                    self.filterAndReload()
                }
            }
        }
    }

    private func filterAndReload() {
        let cal = Calendar.current
        filteredTransactions = transactions.filter {
            cal.isDate($0.createdAt, inSameDayAs: currentDate)
        }
        emptyLabel.isHidden = !filteredTransactions.isEmpty
        tableView.reloadData()
    }

    private func updateDateUI() {
        let cal = Calendar.current
        if cal.isDateInToday(currentDate) {
            todayLabel.text = "Today"
        } else if cal.isDateInYesterday(currentDate) {
            todayLabel.text = "Yesterday"
        } else {
            todayLabel.text = dateFormatter.string(from: currentDate)
        }
        dateLabel.text = dateFormatter.string(from: currentDate)
        let isToday = cal.isDateInToday(currentDate)
        nextDayButton.alpha      = isToday ? 0.3 : 1
        nextDayButton.isEnabled  = !isToday
    }

    private func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = " "
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 0
        return (fmt.string(from: NSNumber(value: value)) ?? "\(value)") + "₽"
    }

    // MARK: - Обработка действий (Actions)

    @objc private func backTapped() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func prevDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        updateDateUI()
        filterAndReload()
    }

    @objc private func nextDay() {
        guard !Calendar.current.isDateInToday(currentDate) else { return }
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        updateDateUI()
        filterAndReload()
    }

    @objc private func addTapped() {
        let addVC = AddTransactionViewController()
        addVC.modalPresentationStyle = .overFullScreen
        addVC.modalTransitionStyle   = .crossDissolve
        addVC.onTransactionAdded = { [weak self] in
            self?.loadData()
        }
        present(addVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTransactions.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath) as! TransactionCell
        cell.configure(with: filteredTransactions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat { 82 }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil
        ) { [weak self] _, _, completionHandler in
            guard let self else { completionHandler(false); return }
            self.deleteTransaction(at: indexPath, completionHandler: completionHandler)
        }

        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        deleteAction.image           = UIImage(systemName: "trash.fill", withConfiguration: cfg)
        deleteAction.backgroundColor = UIColor(red: 1, green: 0.27, blue: 0.23, alpha: 1)

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    private func deleteTransaction(at indexPath: IndexPath,
                                   completionHandler: @escaping (Bool) -> Void) {
        let tx = filteredTransactions[indexPath.row]

        APIService.shared.deleteTransaction(transactionId: tx.id) { [weak self] result in
            guard let self else { completionHandler(false); return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.filteredTransactions.remove(at: indexPath.row)
                    if let fullIdx = self.transactions.firstIndex(where: { $0.id == tx.id }) {
                        self.transactions.remove(at: fullIdx)
                    }
                    
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    self.emptyLabel.isHidden = !self.filteredTransactions.isEmpty
                    completionHandler(true)
                    
                    // Обновляем данные для синхронизации с сервером
                    self.loadData()

                case .failure(let error):
                    print("⚠️ deleteTransaction error: \(error)")
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось удалить транзакцию. Попробуйте еще раз.",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    completionHandler(false)
                }
            }
        }
    }
}

// MARK: - TransactionCell

final class TransactionCell: UITableViewCell {

    private let bgView        = UIView()
    private let iconContainer = UIView()
    private let iconImg       = UIImageView()
    private let titleL        = UILabel()
    private let subL          = UILabel()
    private let amountL       = UILabel()
    private let typeL         = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle  = .none

        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 18
        bgView.layer.cornerCurve  = .continuous
        bgView.layer.shadowColor   = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.05
        bgView.layer.shadowRadius  = 6
        bgView.layer.shadowOffset  = CGSize(width: 0, height: 2)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)

        iconContainer.layer.cornerRadius = 22
        iconContainer.layer.cornerCurve  = .continuous
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(iconContainer)

        iconImg.contentMode = .scaleAspectFill
        iconImg.clipsToBounds = true
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImg)

        titleL.font      = DS.golosBold(16)
        titleL.textColor = UIColor(white: 0.10, alpha: 1)

        subL.font      = DS.inter(13)
        subL.textColor = DS.accent

        amountL.font           = DS.golosBold(17)
        amountL.textAlignment  = .right

        typeL.font        = DS.golosMedium(13)
        typeL.textColor   = UIColor.secondaryLabel
        typeL.textAlignment = .right

        [titleL, subL, amountL, typeL].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            iconContainer.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),

            iconImg.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            iconImg.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            iconImg.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            iconImg.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),

            amountL.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            amountL.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 18),

            typeL.trailingAnchor.constraint(equalTo: amountL.trailingAnchor),
            typeL.topAnchor.constraint(equalTo: amountL.bottomAnchor, constant: 2),

            titleL.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleL.trailingAnchor.constraint(equalTo: amountL.leadingAnchor, constant: -8),
            titleL.topAnchor.constraint(equalTo: amountL.topAnchor),

            subL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
            subL.trailingAnchor.constraint(equalTo: titleL.trailingAnchor),
            subL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 3)
        ])
    }

    func configure(with tx: TransactionResponse) {
        titleL.text = tx.description
        let isExp   = tx.type.lowercased() == "expense"

        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "HH:mm"
        subL.text = "\(tx.category), \(timeFmt.string(from: tx.createdAt))"

        let absAmt = abs(NSDecimalNumber(decimal: tx.amount).doubleValue)
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumFractionDigits = 0
        let amtStr = fmt.string(from: NSNumber(value: absAmt)) ?? "\(Int(absAmt))"

        amountL.text      = "\(isExp ? "-" : "+")\(amtStr)₽"
        amountL.textColor = isExp
            ? UIColor(red: 1, green: 0.27, blue: 0.23, alpha: 1)
            : DS.accent

        typeL.text = tx.type

        if let image = UIImage(named: tx.iconUrl) {
            iconImg.image = image
            iconImg.contentMode = .scaleAspectFill
            iconImg.tintColor = nil
            iconContainer.backgroundColor = .clear
        } else {
            let (bgColor, sfSymbol) = iconForCategory(tx.category, isExpense: isExp)
            iconContainer.backgroundColor = bgColor
            let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconImg.image = UIImage(systemName: sfSymbol, withConfiguration: cfg)
            iconImg.contentMode = .scaleAspectFit
            iconImg.tintColor = .white
        }
    }

    private func iconForCategory(_ category: String, isExpense: Bool) -> (UIColor, String) {
        switch category.lowercased() {
        case "subscription", "subscriptions":
            return (UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1), "play.circle.fill")
        case "food", "groceries":
            return (.systemOrange, "cart.fill")
        case "rent", "housing":
            return (.systemBrown, "house.fill")
        case "income", "salary", "transfer":
            return (.systemYellow, "briefcase.fill")
        case "entertainment":
            return (.systemPurple, "tv.fill")
        case "tech", "technology":
            return (.systemBlue, "laptopcomputer")
        case "transport":
            return (.systemIndigo, "car.fill")
        case "health":
            return (.systemRed, "heart.fill")
        default:
            return (isExpense ? .systemGray4 : DS.accent,
                    isExpense ? "bag.fill" : "plus.circle.fill")
        }
    }
}
