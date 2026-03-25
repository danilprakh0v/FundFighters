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
        l.text      = "Expenses Type"
        l.font      = DS.golosBold(20)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let datePillContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.93, alpha: 1)
        v.layer.cornerRadius = 12
        v.layer.cornerCurve  = .continuous
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
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let yearButton: UIButton = {
        let b = UIButton(type: .custom)
        let attrs = NSAttributedString(string: "Year", attributes: [
            .font: DS.inter(13),
            .foregroundColor: DS.textPrimary
        ])
        b.setAttributedTitle(attrs, for: .normal)
        let icon = UIImage(systemName: "chevron.up.chevron.down",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
        b.setImage(icon, for: .normal)
        b.tintColor = DS.accent
        b.semanticContentAttribute = .forceRightToLeft
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        b.translatesAutoresizingMaskIntoConstraints = false
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
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { fatalError() }

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
            datePillContainer.heightAnchor.constraint(equalToConstant: 30),

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
        if categories.isEmpty {
            showMock()
            emptyLabel.isHidden = true
            return
        }
        
        // Always try to apply date filter if we hook this up, but for now just show default items
        renderRows(categories)
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
        monthLabel.text = df.string(from: selectedDate)
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
        if categories.isEmpty {
            breakdownBar.configure(weights: [], colors: colors)
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            emptyLabel.isHidden = false
            return
        }
        
        emptyLabel.isHidden = true
        let total = categories.reduce(0.0) { $0 + NSDecimalNumber(decimal: $1.totalAmount).doubleValue }
        let weights = categories.map { NSDecimalNumber(decimal: $0.totalAmount).doubleValue / total * 100 }
        breakdownBar.configure(weights: weights, colors: colors)

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, cat) in categories.enumerated() {
            let amount = NSDecimalNumber(decimal: cat.totalAmount).doubleValue
            let pct    = total > 0 ? amount / total * 100 : 0
            stackView.addArrangedSubview(makeRow(name: cat.name, amount: amount, percent: pct, color: colors[i % colors.count]))
            if i < categories.count - 1 { stackView.addArrangedSubview(makeDivider()) }
        }
    }

    private func showMock() {
        let mocked: [(String, Double, Double)] = [
            ("Food",          12150, 27),
            ("Groceries",     11250, 25),
            ("Entertainment",  9000, 20),
            ("Subscriptions",  6750, 15),
            ("Utilities",      5850, 13)
        ]
        breakdownBar.configure(weights: mocked.map { $0.2 }, colors: colors)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, cat) in mocked.enumerated() {
            stackView.addArrangedSubview(makeRow(name: cat.0, amount: cat.1, percent: cat.2, color: colors[i % colors.count]))
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

    private func makeRow(name: String, amount: Double, percent: Double, color: UIColor) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let dot = UIView()
        dot.backgroundColor    = color
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false

        let nameLbl = UILabel()
        nameLbl.text      = name
        nameLbl.font      = DS.golosBold(15)
        nameLbl.textColor = .white
        nameLbl.translatesAutoresizingMaskIntoConstraints = false

        let amtLbl = UILabel()
        amtLbl.text          = formatAmount(amount)
        amtLbl.font          = DS.golosBold(15)
        amtLbl.textColor     = .white
        amtLbl.textAlignment = .right
        amtLbl.translatesAutoresizingMaskIntoConstraints = false

        let pctBadge = UILabel()
        pctBadge.text              = String(format: "%.0f%%", percent)
        pctBadge.font              = DS.inter(11)
        pctBadge.textColor         = .white
        pctBadge.backgroundColor   = UIColor.white.withAlphaComponent(0.18)
        pctBadge.layer.cornerRadius = 8
        pctBadge.clipsToBounds     = true
        pctBadge.textAlignment     = .center
        pctBadge.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.square"))
        checkmark.tintColor = UIColor.white.withAlphaComponent(0.7)
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        [dot, nameLbl, amtLbl, pctBadge, checkmark].forEach { row.addSubview($0) }
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12),

            nameLbl.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 10),
            nameLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),

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
