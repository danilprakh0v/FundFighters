/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: ExpenseChartViewUIKit.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/Components/UIKit/
Назначение: Карточка расходов по категориям с цветным breakdown баром.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class ExpenseChartViewUIKit: UIView {

    // MARK: - State
    private var allCategories: [ExpenseCategoryResponse] = []
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    private var disabledCategoryKeys = Set<String>()
    private var showingMock = false

    // MARK: - Colors
    private let colors: [UIColor] = [
        UIColor(red: 0.20, green: 0.87, blue: 0.45, alpha: 1), // зелёный
        UIColor(red: 0.24, green: 0.56, blue: 1.00, alpha: 1), // синий
        UIColor(red: 1.00, green: 0.55, blue: 0.20, alpha: 1), // оранжевый
        UIColor(red: 1.00, green: 0.24, blue: 0.43, alpha: 1), // розово-красный
        UIColor(red: 0.74, green: 0.20, blue: 1.00, alpha: 1)  // фиолетовый
    ]

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text      = UserManager.shared.isRussian ? "Тип расходов" : "Expenses Type"
        l.font      = DS.golosBold(20)
        l.textColor = DS.textPrimary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.78
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let datePillContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.70)
        v.layer.cornerRadius = 15
        v.layer.cornerCurve  = .continuous
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.78).cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 9
        v.layer.shadowOffset = CGSize(width: 0, height: 5)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var prevDayButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.3)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(prevMonthAction(_:)), for: .touchUpInside)
        return b
    }()

    private lazy var nextDayButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.3)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(nextMonthAction(_:)), for: .touchUpInside)
        return b
    }()

    private let monthLabel: UILabel = {
        let l = UILabel()
        l.text      = "November"
        l.font      = DS.inter(13)
        l.textColor = DS.textPrimary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.75
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var yearButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.70)
        b.layer.cornerRadius = 15
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.78).cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.06
        b.layer.shadowRadius = 9
        b.layer.shadowOffset = CGSize(width: 0, height: 5)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(showMonthPicker), for: .touchUpInside)
        return b
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = DS.cardRadius
        v.layer.cornerCurve  = .continuous
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let breakdownBar = BreakdownBarView()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis    = .vertical
        s.spacing = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text          = "Nothing here yet."
        l.font          = DS.inter(14)
        l.textColor     = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        l.isHidden      = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var gradientLayer: CAGradientLayer?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
        updateLocalization()
    }
    required init?(coder: NSCoder) { fatalError() }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = containerView.bounds
    }

    // MARK: - Setup
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        let pillStack = UIStackView(arrangedSubviews: [prevDayButton, monthLabel, nextDayButton])
        pillStack.axis = .horizontal; pillStack.spacing = 6; pillStack.alignment = .center
        pillStack.translatesAutoresizingMaskIntoConstraints = false
        datePillContainer.addSubview(pillStack)

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), datePillContainer, yearButton])
        headerStack.axis = .horizontal; headerStack.spacing = 8; headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerStack)
        addSubview(containerView)
        containerView.addSubview(breakdownBar)
        containerView.addSubview(stackView)
        containerView.addSubview(emptyLabel)

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 16/255,  green: 185/255, blue: 129/255, alpha: 1).cgColor,
            UIColor(red: 5/255,   green: 150/255, blue: 105/255, alpha: 1).cgColor
        ]
        gradient.startPoint   = CGPoint(x: 0.5, y: 0)
        gradient.endPoint     = CGPoint(x: 0.5, y: 1)
        gradient.cornerRadius = DS.cardRadius
        containerView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient

        breakdownBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            prevDayButton.widthAnchor.constraint(equalToConstant: 20),
            prevDayButton.heightAnchor.constraint(equalToConstant: 20),
            nextDayButton.widthAnchor.constraint(equalToConstant: 20),
            nextDayButton.heightAnchor.constraint(equalToConstant: 20),
            
            pillStack.topAnchor.constraint(equalTo: datePillContainer.topAnchor, constant: 5),
            pillStack.bottomAnchor.constraint(equalTo: datePillContainer.bottomAnchor, constant: -5),
            pillStack.leadingAnchor.constraint(equalTo: datePillContainer.leadingAnchor, constant: 8),
            pillStack.trailingAnchor.constraint(equalTo: datePillContainer.trailingAnchor, constant: -8),
            datePillContainer.heightAnchor.constraint(equalToConstant: 34),

            headerStack.topAnchor.constraint(equalTo: topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            containerView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // Минимальная высота:
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            breakdownBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            breakdownBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            breakdownBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            breakdownBar.heightAnchor.constraint(equalToConstant: 10),

            stackView.topAnchor.constraint(equalTo: breakdownBar.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 15)
        ])
    }

    // MARK: - Configure

    func configure(categories: [ExpenseCategoryResponse]) {
        self.allCategories = categories
        self.showingMock = categories.isEmpty
        if categories.isEmpty {
            showMock()
            emptyLabel.isHidden = true
            return
        }
        
        // Always try to apply date filter if we hook this up, but for now just show default items
        renderRows(categories)
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Тип расходов" : "Expenses Type"
        emptyLabel.text = isRu ? "Пока ничего нет." : "Nothing here yet."
        updateYearButton()
        updateDateLabel()
        showingMock ? showMock() : applyMockDateFilter()
    }
    
    // MARK: - Date Logic
    
    @objc private func prevMonthAction(_ sender: UIButton) {
        handleDateChangeAnimation(sender)
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        applyMockDateFilter() // Fallback to empty states if shifted away from initial data
    }

    @objc private func nextMonthAction(_ sender: UIButton) {
        handleDateChangeAnimation(sender)
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        applyMockDateFilter() // Fallback to empty states if shifted away from initial data
    }
    
    private func updateDateLabel() {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        df.locale = Locale(identifier: UserManager.shared.isRussian ? "ru_RU" : "en_US")
        monthLabel.text = df.string(from: selectedDate)
    }

    private func updateYearButton() {
        let isRu = UserManager.shared.isRussian
        let attrs = NSAttributedString(string: "\(isRu ? "Год" : "Year") ", attributes: [
            .font: DS.inter(13),
            .foregroundColor: DS.textPrimary
        ])
        let icon = NSTextAttachment()
        icon.image = UIImage(systemName: "chevron.up.chevron.down")?
            .withTintColor(DS.accent, renderingMode: .alwaysOriginal)
        icon.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
        let full = NSMutableAttributedString(attributedString: attrs)
        full.append(NSAttributedString(attachment: icon))
        yearButton.setAttributedTitle(full, for: .normal)
    }

    @objc private func showMonthPicker() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(title: isRu ? "Выберите месяц" : "Select Month", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = selectedDate
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor)
        ])

        alert.addAction(UIAlertAction(title: isRu ? "Применить" : "Apply", style: .default) { [weak self] _ in
            guard let self else { return }
            self.selectedDate = picker.date
            self.updateDateLabel()
            self.applyMockDateFilter()
        })
        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))
        findViewController()?.present(alert, animated: true)
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController { return viewController }
            responder = current.next
        }
        return nil
    }
    
    private func applyMockDateFilter() {
        let isCurrentMonth = Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .month)
        if !isCurrentMonth {
            renderRows([])
        } else {
            if allCategories.isEmpty { showMock() }
            else { renderRows(allCategories) }
        }
    }
    
    private func handleDateChangeAnimation(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: { sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85) }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { sender.transform = .identity })
        }
    }

    private func renderRows(_ categories: [ExpenseCategoryResponse]) {
        let visibleCategories = categories.filter { !disabledCategoryKeys.contains($0.name) }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if visibleCategories.isEmpty {
            breakdownBar.configure(weights: [], colors: colors)
            emptyLabel.isHidden = false
            return
        }
        
        emptyLabel.isHidden = true
        let total = visibleCategories.reduce(0.0) { $0 + NSDecimalNumber(decimal: $1.totalAmount).doubleValue }
        let weights = visibleCategories.map { NSDecimalNumber(decimal: $0.totalAmount).doubleValue / total * 100 }
        let visibleColors = visibleCategories.enumerated().map { colors[$0.offset % colors.count] }
        breakdownBar.configure(weights: weights, colors: visibleColors)

        for (i, cat) in categories.enumerated() {
            let amount = NSDecimalNumber(decimal: cat.totalAmount).doubleValue
            let isEnabled = !disabledCategoryKeys.contains(cat.name)
            let pct = isEnabled && total > 0 ? amount / total * 100 : 0
            stackView.addArrangedSubview(makeRow(nameKey: cat.name, amount: amount, percent: pct, color: colors[i % colors.count]))
            if i < categories.count - 1 { stackView.addArrangedSubview(makeDivider()) }
        }
    }

    private func showMock() {
        showingMock = true
        let mocked: [(String, Double, Double)] = [
            ("Food",          12150, 27),
            ("Groceries",     11250, 25),
            ("Entertainment",  9000, 20),
            ("Subscriptions",  6750, 15),
            ("Utilities",      5850, 13)
        ]
        let visible = mocked.filter { !disabledCategoryKeys.contains($0.0) }
        breakdownBar.configure(weights: visible.map { $0.2 }, colors: visible.enumerated().map { colors[$0.offset % colors.count] })
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !visible.isEmpty else {
            emptyLabel.isHidden = false
            return
        }
        emptyLabel.isHidden = true
        for (i, cat) in mocked.enumerated() {
            stackView.addArrangedSubview(makeRow(nameKey: cat.0, amount: cat.1, percent: cat.2, color: colors[i % colors.count]))
            if i < mocked.count - 1 { stackView.addArrangedSubview(makeDivider()) }
        }
    }

    private func formatAmount(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","
        fmt.maximumFractionDigits = 0
        return (fmt.string(from: NSNumber(value: value)) ?? "\(Int(value))") + "\u{20BD}"
    }

    private func makeRow(nameKey: String, amount: Double, percent: Double, color: UIColor) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 52).isActive = true
        row.accessibilityIdentifier = nameKey
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCategoryFromGesture(_:)))
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true
        let isEnabled = !disabledCategoryKeys.contains(nameKey)

        let dot = UIView()
        dot.backgroundColor    = color
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false

        let nameLbl = UILabel()
        nameLbl.text      = localizedCategory(nameKey)
        nameLbl.font      = DS.golosBold(16)
        nameLbl.textColor = isEnabled ? .white : UIColor.white.withAlphaComponent(0.45)
        nameLbl.translatesAutoresizingMaskIntoConstraints = false

        let amtLbl = UILabel()
        amtLbl.text          = formatAmount(amount)
        amtLbl.font          = DS.golosBold(16)
        amtLbl.textColor     = isEnabled ? .white : UIColor.white.withAlphaComponent(0.45)
        amtLbl.textAlignment = .right
        amtLbl.translatesAutoresizingMaskIntoConstraints = false

        let pctBadge = UILabel()
        pctBadge.text              = String(format: "%.0f%%", percent)
        pctBadge.font              = DS.inter(11)
        pctBadge.textColor         = .white
        pctBadge.backgroundColor   = UIColor.white.withAlphaComponent(isEnabled ? 0.20 : 0.10)
        pctBadge.layer.cornerRadius = 8
        pctBadge.clipsToBounds     = true
        pctBadge.textAlignment     = .center
        pctBadge.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIButton(type: .system)
        let symbol = isEnabled ? "checkmark.square.fill" : "square"
        checkmark.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)), for: .normal)
        checkmark.tintColor = UIColor.white.withAlphaComponent(isEnabled ? 0.86 : 0.42)
        checkmark.isUserInteractionEnabled = false
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        [dot, nameLbl, amtLbl, pctBadge, checkmark].forEach { row.addSubview($0) }
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12),

            nameLbl.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 10),
            nameLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            nameLbl.trailingAnchor.constraint(lessThanOrEqualTo: amtLbl.leadingAnchor, constant: -10),

            checkmark.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 20),
            checkmark.heightAnchor.constraint(equalToConstant: 20),

            pctBadge.trailingAnchor.constraint(equalTo: checkmark.leadingAnchor, constant: -10),
            pctBadge.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            pctBadge.widthAnchor.constraint(equalToConstant: 44),
            pctBadge.heightAnchor.constraint(equalToConstant: 22),

            amtLbl.trailingAnchor.constraint(equalTo: pctBadge.leadingAnchor, constant: -10),
            amtLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    @objc private func toggleCategoryFromGesture(_ gesture: UITapGestureRecognizer) {
        guard let key = gesture.view?.accessibilityIdentifier else { return }
        toggleCategory(key)
    }

    private func toggleCategory(_ key: String) {
        if disabledCategoryKeys.contains(key) {
            disabledCategoryKeys.remove(key)
        } else {
            disabledCategoryKeys.insert(key)
        }
        showingMock ? showMock() : applyMockDateFilter()
    }

    private func localizedCategory(_ category: String) -> String {
        guard UserManager.shared.isRussian else { return category }
        switch category {
        case "Food": return "Еда"
        case "Groceries": return "Продукты"
        case "Entertainment": return "Развлечения"
        case "Subscriptions": return "Подписки"
        case "Utilities": return "Коммунальные"
        case "Rent": return "Аренда"
        case "Tech": return "Техника"
        case "Transport": return "Транспорт"
        case "Health": return "Здоровье"
        default: return category
        }
    }

    private func makeDivider() -> UIView {
        let w = UIView(); w.translatesAutoresizingMaskIntoConstraints = false
        let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.translatesAutoresizingMaskIntoConstraints = false
        w.addSubview(v)
        NSLayoutConstraint.activate([
            w.heightAnchor.constraint(equalToConstant: 1),
            v.heightAnchor.constraint(equalToConstant: 1),
            v.centerYAnchor.constraint(equalTo: w.centerYAnchor),
            v.leadingAnchor.constraint(equalTo: w.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: w.trailingAnchor, constant: -16)
        ])
        return w
    }
}

// MARK: - BreakdownBarView

private final class BreakdownBarView: UIView {
    private var segs: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(weights: [Double], colors: [UIColor]) {
        segs.forEach { $0.removeFromSuperview() }
        segs.removeAll()
        let total = weights.reduce(0, +)
        guard total > 0 else { return }
        var last = leadingAnchor
        for (i, w) in weights.enumerated() {
            let s = UIView()
            s.backgroundColor = colors[i % colors.count]
            s.translatesAutoresizingMaskIntoConstraints = false
            addSubview(s)
            NSLayoutConstraint.activate([
                s.topAnchor.constraint(equalTo: topAnchor),
                s.bottomAnchor.constraint(equalTo: bottomAnchor),
                s.leadingAnchor.constraint(equalTo: last),
                s.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(w / total))
            ])
            last = s.trailingAnchor
            segs.append(s)
        }
    }
}
