/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: ReportsViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Reports/
Назначение: Экран отчетов. Визуализация расходов по категориям.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
===============================================================================
*/

import UIKit

// MARK: - Токены дизайна (ReportsDT)

private enum ReportsDT {
    static let accentTeal   = UIColor(red: 46/255,  green: 166/255, blue: 155/255, alpha: 1.0)
    static let accentGreen  = UIColor(red: 30/255,  green: 140/255, blue: 98/255,  alpha: 1.0)
    static let background   = UIColor.white
    static let cardBg       = UIColor.white
    static let pillInactive = UIColor(red: 220/255, green: 220/255, blue: 216/255, alpha: 1.0)
}

private struct FundsReportItem {
    let name: String
    let amount: Double
    let share: Double
    let icon: String
    let isPositive: Bool
}

// MARK: - Liquid Glass Контейнер

private final class LiquidGlassView: UIView {
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
    private let gradientLayer = CAGradientLayer()
    private let tintView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true

        // Тонкая "стеклянная" рамка с эффектом объема
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor

        // Нейтральный светлый тинт (имитация прозрачного серебристого стекла)
        tintView.backgroundColor = UIColor(white: 0.98, alpha: 0.15)
        tintView.translatesAutoresizingMaskIntoConstraints = false

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blurEffectView)
        addSubview(tintView)

        // Блик стекла (диагональный градиент)
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tintView.topAnchor.constraint(equalTo: topAnchor),
            tintView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Интерактивная строка категории

private final class CategoryRowView: UIView {
    var tapAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
    }

    required init?(coder: NSCoder) { fatalError() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.04)
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
            self.backgroundColor = .clear
            self.transform = .identity
        }
        tapAction?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.25, delay: 0, options: .allowUserInteraction) {
            self.backgroundColor = .clear
            self.transform = .identity
        }
    }
}

// MARK: - Вспомогательная кнопка (Зеленый круг)


// MARK: - ReportsViewController

final class ReportsViewController: UIViewController {

    // MARK: - Свойства

    private let viewModel = DashboardViewModel()
    private var selectedPeriodIndex = 1
    private var dashboard: DashboardResponse?
    private var reportItems: [FundsReportItem] = []
    private var sortByValue = true
    private var selectedCategoryFilter: String? = nil

    private var netCashFlow = 0.0
    private var totalIncome = 0.0
    private var totalExpense = 0.0

    // MARK: - UI Элементы

    private lazy var backButton: GreenCircleButton = {
        let b = GreenCircleButton(iconName: "chevron.left")
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "Funds Report"
        l.font          = DS.golosBold(27)
        l.textColor     = DS.textPrimary
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.75
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let pdfButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        b.setImage(UIImage(systemName: "doc.richtext.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.22)
        b.backgroundColor = UIColor.white
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.10
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let pillSwitcher: PillTabSwitcher = {
        let isRu = UserManager.shared.isRussian
        let titles = isRu ? ["Неделя", "Месяц", "Год"] : ["Week", "Month", "Year"]
        let s = PillTabSwitcher(items: titles)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private let summaryCard = UIView()

    private let listTitleLabel = UILabel()
    private let sortButton = UIButton(type: .system)
    private let filterButton = UIButton(type: .system)
    private let listControlsStack = UIStackView()

    private let listCard = UIView()
    private let listScrollView = UIScrollView()
    private let listStack = UIStackView()

    private let netTitleLabel = UILabel()
    private let netValueLabel = UILabel()
    private let efficiencyLabel = UILabel()
    private let incomeMetricTitleLabel = UILabel()
    private let incomeMetricValueLabel = UILabel()
    private let expenseMetricTitleLabel = UILabel()
    private let expenseMetricValueLabel = UILabel()
    private let predictionFooterLabel = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ReportsDT.background
        setupLayout()
        loadData()

        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
        updateLocalization()
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        navTitleLabel.text = isRu ? "Отчёт средств" : "Funds Report"
        listTitleLabel.text = isRu ? "Список" : "The List"
        netTitleLabel.text = isRu ? "Чистый денежный поток" : "Net Cash Flow"
        incomeMetricTitleLabel.text = isRu ? "Всего доходов" : "Total Income"
        expenseMetricTitleLabel.text = isRu ? "Всего расходов" : "Total Expenses"

        setupControlsMenu()
        updatePeriodTitles()
        renderReport()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Верстка

    private func setupLayout() {
        setupReportViews()

        [backButton, navTitleLabel, pdfButton, pillSwitcher, summaryCard, listTitleLabel, listControlsStack, listCard]
            .forEach { view.addSubview($0) }

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            navTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12),

            pdfButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            pdfButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pdfButton.widthAnchor.constraint(equalToConstant: 40),
            pdfButton.heightAnchor.constraint(equalToConstant: 40),

            pillSwitcher.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 26),
            pillSwitcher.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            pillSwitcher.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            pillSwitcher.heightAnchor.constraint(equalToConstant: 44),

            summaryCard.topAnchor.constraint(equalTo: pillSwitcher.bottomAnchor, constant: 22),
            summaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            summaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            summaryCard.heightAnchor.constraint(equalToConstant: 168),

            // Исправление привязки заголовка и кнопок
            listTitleLabel.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 5),
            listTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            listTitleLabel.centerYAnchor.constraint(equalTo: listControlsStack.centerYAnchor),

            listControlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            listControlsStack.leadingAnchor.constraint(greaterThanOrEqualTo: listTitleLabel.trailingAnchor, constant: 12),

            listCard.topAnchor.constraint(equalTo: listTitleLabel.bottomAnchor, constant: 12),
            listCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            listCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            listCard.bottomAnchor.constraint(lessThanOrEqualTo: safe.bottomAnchor, constant: -20),

            listScrollView.topAnchor.constraint(equalTo: listCard.topAnchor, constant: 12),
            listScrollView.leadingAnchor.constraint(equalTo: listCard.leadingAnchor),
            listScrollView.trailingAnchor.constraint(equalTo: listCard.trailingAnchor),
            listScrollView.heightAnchor.constraint(lessThanOrEqualToConstant: 260),

            listStack.topAnchor.constraint(equalTo: listScrollView.contentLayoutGuide.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: listScrollView.contentLayoutGuide.leadingAnchor),
            listStack.trailingAnchor.constraint(equalTo: listScrollView.contentLayoutGuide.trailingAnchor),
            listStack.bottomAnchor.constraint(equalTo: listScrollView.contentLayoutGuide.bottomAnchor),
            listStack.widthAnchor.constraint(equalTo: listScrollView.frameLayoutGuide.widthAnchor),

            predictionFooterLabel.topAnchor.constraint(equalTo: listScrollView.bottomAnchor, constant: 16),
            predictionFooterLabel.leadingAnchor.constraint(equalTo: listCard.leadingAnchor, constant: 14),
            predictionFooterLabel.trailingAnchor.constraint(equalTo: listCard.trailingAnchor, constant: -14),
            predictionFooterLabel.bottomAnchor.constraint(equalTo: listCard.bottomAnchor, constant: -12),
            predictionFooterLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        let scrollHeight = listScrollView.heightAnchor.constraint(equalTo: listStack.heightAnchor)
        scrollHeight.priority = .defaultHigh
        scrollHeight.isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfButton.layer.cornerRadius = pdfButton.bounds.height / 2
    }

    private func setupReportViews() {
        pdfButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)

        // Wire up PillTabSwitcher
        pillSwitcher.onTabChanged = { [weak self] index in
            guard let self, self.selectedPeriodIndex != index else { return }
            self.selectedPeriodIndex = index
            UIView.transition(with: self.summaryCard, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.renderReport()
            }, completion: nil)
            self.animateListUpdate()
        }
        // Start on Month (index 1) to match Analytics default
        pillSwitcher.selectIndex(1)

        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 18
        summaryCard.layer.cornerCurve = .continuous
        summaryCard.layer.shadowColor = UIColor.black.cgColor
        summaryCard.layer.shadowOpacity = 0.12
        summaryCard.layer.shadowOffset = CGSize(width: 0, height: 5)
        summaryCard.layer.shadowRadius = 12
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        buildSummaryCard()

        listTitleLabel.font = DS.golosBold(25)
        listTitleLabel.textColor = DS.textPrimary
        listTitleLabel.adjustsFontSizeToFitWidth = true // Сжимаем текст, если длинный
        listTitleLabel.minimumScaleFactor = 0.7 // Минимальный масштаб сжатия
        listTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Настройка кнопок управления списком
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), for: .normal)
        filterButton.tintColor = .black
        filterButton.showsMenuAsPrimaryAction = true

        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down.circle.fill"), for: .normal)
        sortButton.tintColor = .black
        sortButton.showsMenuAsPrimaryAction = true

        listControlsStack.axis = .horizontal
        listControlsStack.spacing = 10
        listControlsStack.addArrangedSubview(filterButton)
        listControlsStack.addArrangedSubview(sortButton)
        listControlsStack.translatesAutoresizingMaskIntoConstraints = false

        setupControlsMenu()

        listCard.backgroundColor = .white
        listCard.layer.cornerRadius = 20
        listCard.layer.cornerCurve = .continuous
        listCard.layer.shadowColor = UIColor.black.cgColor
        listCard.layer.shadowOpacity = 0.10
        listCard.layer.shadowOffset = CGSize(width: 0, height: 5)
        listCard.layer.shadowRadius = 12
        listCard.translatesAutoresizingMaskIntoConstraints = false

        listScrollView.translatesAutoresizingMaskIntoConstraints = false
        listScrollView.showsVerticalScrollIndicator = false

        listStack.axis = .vertical
        listStack.spacing = 0
        listStack.translatesAutoresizingMaskIntoConstraints = false

        listCard.addSubview(listScrollView)
        listScrollView.addSubview(listStack)

        renderRows([])
        buildPredictionFooter()
    }

    private func setupControlsMenu() {
        let isRu = UserManager.shared.isRussian

        // --- Сортировка ---
        let sortByValueAction = UIAction(
            title: isRu ? "Сортировать по сумме" : "Sort by value",
            image: UIImage(systemName: "dollarsign.circle"),
            state: sortByValue ? .on : .off
        ) { [weak self] _ in
            self?.sortByValue = true
            self?.setupControlsMenu()
            self?.animateListUpdate()
        }

        let sortByNameAction = UIAction(
            title: isRu ? "Сортировать по имени" : "Sort by name",
            image: UIImage(systemName: "textformat.abc"),
            state: !sortByValue ? .on : .off
        ) { [weak self] _ in
            self?.sortByValue = false
            self?.setupControlsMenu()
            self?.animateListUpdate()
        }
        sortButton.menu = UIMenu(title: isRu ? "Отображение" : "Display Options", children: [sortByValueAction, sortByNameAction])

        // --- Фильтрация с иконками ---
        var filterActions = [UIAction]()

        let allCategoriesAction = UIAction(
            title: isRu ? "Все категории" : "All Categories",
            image: UIImage(systemName: "list.dash"), // Нейтральная иконка списка
            state: selectedCategoryFilter == nil ? .on : .off
        ) { [weak self] _ in
            self?.selectedCategoryFilter = nil
            self?.setupControlsMenu()
            self?.animateListUpdate()
        }
        filterActions.append(allCategoriesAction)

        // Получаем уникальные категории из загруженных данных
        let uniqueCategories = Array(Set(reportItems.map { $0.name })).sorted()
        for cat in uniqueCategories {
            let action = UIAction(
                title: localizedCategory(cat),
                image: UIImage(systemName: iconForCategory(cat)), // Добавляем иконку категории
                state: selectedCategoryFilter == cat ? .on : .off
            ) { [weak self] _ in
                self?.selectedCategoryFilter = cat
                self?.setupControlsMenu()
                self?.animateListUpdate()
            }
            filterActions.append(action)
        }
        filterButton.menu = UIMenu(title: isRu ? "Фильтр" : "Filter", children: filterActions)

        // Визуальная подсветка активного фильтра
        filterButton.tintColor = selectedCategoryFilter == nil ? .black : ReportsDT.accentGreen
    }

    private func buildSummaryCard() {
        let glassContainer = LiquidGlassView()
        glassContainer.translatesAutoresizingMaskIntoConstraints = false

        netTitleLabel.font = DS.interSemi(14)
        netTitleLabel.textAlignment = .center
        netTitleLabel.textColor = DS.textPrimary

        netValueLabel.font = DS.golosBold(26)
        netValueLabel.textColor = DS.textPrimary // Цвет более строгий, так как фон нейтральный
        netValueLabel.textAlignment = .center

        efficiencyLabel.font = DS.inter(12)
        efficiencyLabel.textAlignment = .center
        efficiencyLabel.textColor = .systemGray

        let top = UIStackView(arrangedSubviews: [netTitleLabel, netValueLabel, efficiencyLabel])
        top.axis = .vertical
        top.spacing = 2
        top.translatesAutoresizingMaskIntoConstraints = false

        let income = makeSummaryMetric(titleLabel: incomeMetricTitleLabel, valueLabel: incomeMetricValueLabel, color: DS.accent)
        let outcome = makeSummaryMetric(titleLabel: expenseMetricTitleLabel, valueLabel: expenseMetricValueLabel, color: .systemRed)
        let bottom = UIStackView(arrangedSubviews: [income, outcome])
        bottom.axis = .horizontal
        bottom.distribution = .fillEqually
        bottom.translatesAutoresizingMaskIntoConstraints = false

        summaryCard.addSubview(glassContainer)
        summaryCard.addSubview(top)
        summaryCard.addSubview(bottom)

        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 10),
            glassContainer.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 10),
            glassContainer.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -10),
            glassContainer.heightAnchor.constraint(equalToConstant: 88),

            top.centerYAnchor.constraint(equalTo: glassContainer.centerYAnchor),
            top.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 12),
            top.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -12),

            bottom.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -4),
            bottom.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    private func makeSummaryMetric(titleLabel: UILabel, valueLabel: UILabel, color: UIColor) -> UIView {
        let view = UIView()
        titleLabel.font = DS.interSemi(12)
        titleLabel.textAlignment = .center
        valueLabel.font = DS.golosBold(18)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }

    private func renderRows(_ items: [FundsReportItem]) {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let filteredItems = items.filter { item in
            guard let activeFilter = selectedCategoryFilter else { return true }
            return item.name == activeFilter
        }

        guard !filteredItems.isEmpty else {
            let label = UILabel()
            label.text = UserManager.shared.isRussian ? "Нет данных" : "No data"
            label.font = DS.inter(14)
            label.textColor = DS.textSecondary
            label.textAlignment = .center
            label.heightAnchor.constraint(equalToConstant: 61).isActive = true
            listStack.addArrangedSubview(label)
            return
        }

        let sorted = sortByValue
            ? filteredItems.sorted { $0.amount > $1.amount }
            : filteredItems.sorted { localizedCategory($0.name) < localizedCategory($1.name) }

        sorted.prefix(10).forEach { listStack.addArrangedSubview(makeReportRow($0)) }
    }

    private func makeReportRow(_ item: FundsReportItem) -> UIView {
        let row = CategoryRowView()
        row.heightAnchor.constraint(equalToConstant: 54).isActive = true

        row.tapAction = { [weak self] in
            print("Selected: \(item.name)")
        }

        let iconBox = UIView()
        iconBox.backgroundColor = (item.isPositive ? DS.accent : DS.red).withAlphaComponent(0.13)
        iconBox.layer.cornerRadius = 10
        iconBox.layer.cornerCurve = .continuous
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: item.icon))
        icon.tintColor = item.isPositive ? DS.accent : DS.red
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconBox.addSubview(icon)

        let title = UILabel()
        title.text = localizedCategory(item.name)
        title.font = DS.golosBold(14)
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.78
        let xp = UILabel()
        xp.text = "\(Int(item.amount / 10)) XP"
        xp.font = DS.inter(10)
        xp.textColor = .systemGray
        let left = UIStackView(arrangedSubviews: [title, xp])
        left.axis = .vertical
        left.spacing = 2
        left.translatesAutoresizingMaskIntoConstraints = false

        let amount = UILabel()
        amount.text = formatCurrency(item.amount, signed: item.isPositive)
        amount.font = DS.golosBold(14)
        amount.textAlignment = .right
        amount.setContentCompressionResistancePriority(.required, for: .horizontal)
        let delta = UILabel()
        delta.text = String(format: "%@%.0f%%", item.isPositive ? "+" : "-", abs(item.share))
        delta.font = DS.inter(11)
        delta.textColor = item.isPositive ? DS.accent : DS.red
        delta.textAlignment = .right
        let right = UIStackView(arrangedSubviews: [amount, delta])
        right.axis = .vertical
        right.spacing = 2
        right.translatesAutoresizingMaskIntoConstraints = false

        let track = UIView()
        track.backgroundColor = (item.isPositive ? DS.accent : DS.red).withAlphaComponent(0.13)
        track.layer.cornerRadius = 2
        track.translatesAutoresizingMaskIntoConstraints = false
        let fill = UIView()
        fill.backgroundColor = item.isPositive ? DS.accent : DS.red
        fill.layer.cornerRadius = 2
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)

        let divider = UIView()
        divider.backgroundColor = UIColor.black.withAlphaComponent(0.06)
        divider.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(iconBox)
        row.addSubview(left)
        row.addSubview(right)
        row.addSubview(track)
        row.addSubview(divider)
        let fillWidth = max(0.08, min(1.0, abs(item.share) / 100.0))

        NSLayoutConstraint.activate([
            iconBox.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            iconBox.centerYAnchor.constraint(equalTo: row.centerYAnchor, constant: -4),
            iconBox.widthAnchor.constraint(equalToConstant: 34),
            iconBox.heightAnchor.constraint(equalToConstant: 34),
            icon.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            left.leadingAnchor.constraint(equalTo: iconBox.trailingAnchor, constant: 12),
            left.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            right.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            right.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            left.trailingAnchor.constraint(lessThanOrEqualTo: right.leadingAnchor, constant: -12),

            track.leadingAnchor.constraint(equalTo: left.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: right.leadingAnchor, constant: -14),
            track.topAnchor.constraint(equalTo: left.bottomAnchor, constant: 6),
            track.heightAnchor.constraint(equalToConstant: 4),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: fillWidth),

            divider.leadingAnchor.constraint(equalTo: left.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            divider.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
        return row
    }

    private func buildPredictionFooter() {
        predictionFooterLabel.font = DS.interSemi(14)
        predictionFooterLabel.textAlignment = .center
        predictionFooterLabel.adjustsFontSizeToFitWidth = true
        predictionFooterLabel.minimumScaleFactor = 0.75
        predictionFooterLabel.textColor = DS.textPrimary
        predictionFooterLabel.backgroundColor = UIColor.black.withAlphaComponent(0.035)
        predictionFooterLabel.layer.cornerRadius = 12
        predictionFooterLabel.layer.cornerCurve = .continuous
        predictionFooterLabel.clipsToBounds = true
        predictionFooterLabel.translatesAutoresizingMaskIntoConstraints = false
        listCard.addSubview(predictionFooterLabel)
    }

    private func updatePeriodButtons() {
        // PillTabSwitcher handles its own animation; nothing extra to do
    }

    private func animateListUpdate() {
        UIView.transition(with: listCard, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.renderRows(self.reportItems)
        }, completion: nil)

        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func exportTapped() {
        let text = reportExportText()
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activity, animated: true)
    }

    private func updatePeriodTitles() {
        // PillTabSwitcher is initialized with localized titles.
        // For live language switch support, update via recreating or by syncing:
        // (pillSwitcher does not expose a public setTitles API, so we rely on restart)
    }

    private func renderReport() {
        guard let dashboard else {
            netTitleLabel.text = UserManager.shared.isRussian ? "Чистый денежный поток" : "Net Cash Flow"
            netValueLabel.text = "0₽"
            efficiencyLabel.text = UserManager.shared.isRussian ? "Нет данных за период" : "No data for period"
            incomeMetricValueLabel.text = "0₽"
            expenseMetricValueLabel.text = "0₽"
            setPredictionFooter(amount: nil)
            renderRows([])
            return
        }

        let periodTransactions = dashboard.recentTransactions.filter { isInSelectedPeriod($0.createdAt) }
        let txIncome = periodTransactions
            .filter { !$0.type.lowercased().contains("expense") && NSDecimalNumber(decimal: $0.amount).doubleValue > 0 }
            .reduce(0.0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
        let txExpense = periodTransactions
            .filter { $0.type.lowercased().contains("expense") || NSDecimalNumber(decimal: $0.amount).doubleValue < 0 }
            .reduce(0.0) { $0 + abs(NSDecimalNumber(decimal: $1.amount).doubleValue) }

        if selectedPeriodIndex == 1 {
            totalIncome = max(txIncome, NSDecimalNumber(decimal: dashboard.balanceInfo.monthlyIncome).doubleValue)
            totalExpense = max(txExpense, NSDecimalNumber(decimal: dashboard.balanceInfo.monthlyExpense).doubleValue)
        } else {
            totalIncome = txIncome
            totalExpense = txExpense
        }
        netCashFlow = totalIncome - totalExpense

        let efficiency = totalIncome > 0 ? (netCashFlow / totalIncome) * 100 : 0
        netValueLabel.text = formatCurrency(netCashFlow, signed: true)

        // Цвет подстраиваем в зависимости от знака, но на светлом фоне
        if netCashFlow == 0 {
            netValueLabel.textColor = DS.textPrimary
        } else {
            netValueLabel.textColor = netCashFlow > 0 ? DS.accent : DS.red
        }

        efficiencyLabel.text = UserManager.shared.isRussian
            ? String(format: "Эффективность: %.0f%% за период", efficiency)
            : String(format: "Efficiency: %.0f%% for period", efficiency)
        incomeMetricValueLabel.text = formatCurrency(totalIncome, signed: true)
        expenseMetricValueLabel.text = formatCurrency(totalExpense, signed: false, forceNegative: true)

        reportItems = makeReportItems(from: dashboard, transactions: periodTransactions)

        setupControlsMenu() // Обновляем меню фильтров после получения новых категорий
        renderRows(reportItems)

        let predicted = max(0, netCashFlow)
        setPredictionFooter(amount: predicted == 0 ? nil : predicted)
    }

    private func setPredictionFooter(amount: Double?) {
        let isRu = UserManager.shared.isRussian
        guard let amount else {
            predictionFooterLabel.attributedText = nil
            predictionFooterLabel.text = isRu ? "Прогноз: Выходим в ноль" : "Prediction: Breaking even"
            return
        }

        let value = formatCurrency(amount, signed: true)
        let text = isRu ? "Прогноз накоплений: \(value)" : "Predicted saving: \(value)"
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: DS.golosBold(17),
                .foregroundColor: DS.textPrimary
            ]
        )
        attributed.addAttributes(
            [
                .font: DS.golosBold(17),
                .foregroundColor: DS.accent
            ],
            range: (text as NSString).range(of: value)
        )
        predictionFooterLabel.attributedText = attributed
    }

    private func makeReportItems(from dashboard: DashboardResponse, transactions: [TransactionResponse]) -> [FundsReportItem] {
        let expenseTransactions = transactions.filter {
            $0.type.lowercased().contains("expense") || NSDecimalNumber(decimal: $0.amount).doubleValue < 0
        }
        let grouped = Dictionary(grouping: expenseTransactions, by: { $0.category })
        let groupedItems = grouped.map { key, values in
            let amount = values.reduce(0.0) { $0 + abs(NSDecimalNumber(decimal: $1.amount).doubleValue) }
            return FundsReportItem(
                name: key,
                amount: amount,
                share: totalExpense > 0 ? amount / totalExpense * 100 : 0,
                icon: iconForCategory(key),
                isPositive: false
            )
        }

        let categoryItems = dashboard.expenseCategories.map { category in
            let amount = NSDecimalNumber(decimal: category.totalAmount).doubleValue
            return FundsReportItem(
                name: category.name,
                amount: amount,
                share: totalExpense > 0 ? amount / totalExpense * 100 : NSDecimalNumber(decimal: category.percentage).doubleValue,
                icon: iconForCategory(category.name),
                isPositive: false
            )
        }.filter { $0.amount > 0 }

        var items = groupedItems.isEmpty ? categoryItems : groupedItems
        if totalIncome > 0 {
            items.append(FundsReportItem(
                name: "Savings",
                amount: max(0, netCashFlow),
                share: totalIncome > 0 ? max(0, netCashFlow) / totalIncome * 100 : 0,
                icon: "dollarsign.circle.fill",
                isPositive: true
            ))
        }
        return items
    }

    private func isInSelectedPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        switch selectedPeriodIndex {
        case 0:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        case 2:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .year)
        default:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        }
    }

    private func formatCurrency(_ value: Double, signed: Bool = false, forceNegative: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        let amount = formatter.string(from: NSNumber(value: abs(value))) ?? "\(Int(abs(value)))"
        if forceNegative { return "-\(amount)₽" }
        if signed { return "\(value >= 0 ? "+" : "-")\(amount)₽" }
        return "\(amount)₽"
    }

    private func localizedCategory(_ category: String) -> String {
        guard UserManager.shared.isRussian else { return category }
        switch category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "food": return "Еда"
        case "groceries": return "Продукты"
        case "entertainment": return "Развлечения"
        case "subscription", "subscriptions": return "Подписки"
        case "utilities", "utility": return "Коммунальные"
        case "rent": return "Аренда"
        case "transport": return "Транспорт"
        case "saving", "savings", "income", "salary": return "Накопления"
        case "health": return "Здоровье"
        case "tech", "technology": return "Техника"
        case "other", "misc", "miscellaneous": return "Другое"
        default: return category
        }
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "rent": return "house.fill"
        case "transport": return "car.fill"
        case "entertainment": return "play.rectangle.fill"
        case "food", "groceries": return "cart.fill"
        case "subscription", "subscriptions": return "play.circle.fill"
        case "health": return "heart.fill"
        case "tech": return "laptopcomputer"
        case "other", "misc", "miscellaneous": return "tag.fill"
        default: return "tag.fill"
        }
    }

    private func reportExportText() -> String {
        let isRu = UserManager.shared.isRussian
        let width = 38 // Оптимальная ширина для чистой ASCII-таблицы
        let periodTitles = isRu ? ["Неделя", "Месяц", "Год"] : ["Week", "Month", "Year"]
        let period = periodTitles.indices.contains(selectedPeriodIndex) ? periodTitles[selectedPeriodIndex] : ""
        let isSaving = netCashFlow > 0

        // Строгий ASCII заголовок без эмодзи
        var report = """
        ╭──────────────────────────────────────╮
        │          FUND FIGHTERS REPORT        │
        ╰──────────────────────────────────────╯

        [i] \(isRu ? "ПЕРИОД:" : "PERIOD:") \(period.uppercased())
        [i] \(isRu ? "СТАТУС:" : "STATUS:") \(isRu ? (isSaving ? "НАКОПЛЕНИЯ" : "ДЕФИЦИТ") : (isSaving ? "SURPLUS" : "DEFICIT"))

        ────────────────────────────────────────
        """

        let netTitle = (isRu ? "ЧИСТЫЙ ПОТОК:" : "NET FLOW:")
        let netValue = formatCurrency(netCashFlow, signed: true)
        report += "\n[*] " + netTitle + String(repeating: " ", count: max(0, width - 4 - netTitle.count - netValue.count)) + netValue

        let incomeTitle = (isRu ? "Всего доходов:" : "Total Income:")
        let incomeValue = formatCurrency(totalIncome, signed: true)
        report += "\n[+] " + incomeTitle + String(repeating: " ", count: max(0, width - 4 - incomeTitle.count - incomeValue.count)) + incomeValue

        let outcomeTitle = (isRu ? "Всего расходов:" : "Total Expenses:")
        let outcomeValue = formatCurrency(totalExpense, signed: false, forceNegative: true)
        report += "\n[-] " + outcomeTitle + String(repeating: " ", count: max(0, width - 4 - outcomeTitle.count - outcomeValue.count)) + outcomeValue

        report += "\n\n────────────────────────────────────────\n"
        report += "[i] \(isRu ? "ДЕТАЛИЗАЦИЯ:" : "DETAILS:")\n\n"

        // Категории без эмодзи, только строгие маркеры
        for item in reportItems {
            let catName = localizedCategory(item.name)
            let catAmount = formatCurrency(item.amount)
            let prefix = item.isPositive ? "+" : "-"
            let percentage = String(format: "%@%.0f%%", prefix, abs(item.share))
            let marker = item.isPositive ? "[+]" : "[-]"

            let leftPart = "\(marker) \(catName)"
            let rightPart = "\(catAmount) (\(percentage))"

            let spaceCount = max(1, width - leftPart.count - rightPart.count)
            let spaces = String(repeating: " ", count: spaceCount)

            report += leftPart + spaces + rightPart + "\n"
        }

        report += "────────────────────────────────────────"
        return report
    }

    // MARK: - Данные

    private func loadData() {
        viewModel.onDataLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.dashboard = self?.viewModel.dashboard
                self?.renderReport()
            }
        }
        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.dashboard = self?.viewModel.dashboard
                self?.renderReport()
            }
        }
        viewModel.loadDashboard()
    }

    // MARK: - Обработка действий

    @objc private func closeTapped() {
        if let tabBar = self.tabBarController as? MainTabBarController {
            tabBar.switchToTab(2)
        } else {
            dismiss(animated: true)
        }
    }
}
