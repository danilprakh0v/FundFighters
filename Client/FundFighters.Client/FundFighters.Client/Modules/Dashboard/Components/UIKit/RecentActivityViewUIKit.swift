/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: RecentActivityViewUIKit.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/Components/UIKit/
Назначение: Карточка последних транзакций с фильтрацией по дате через UIDatePicker.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class RecentActivityViewUIKit: UIView {

    // MARK: - State
    private var allTransactions: [TransactionResponse] = []
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text      = "Recent Activity"
        l.font      = DS.golosBold(20)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Date pill: < Today >
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
        b.addTarget(self, action: #selector(prevDayAction(_:)), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var nextDayButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.3)
        b.addTarget(self, action: #selector(nextDayAction(_:)), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let todayLabel: UILabel = {
        let l = UILabel()
        l.text      = "Today"
        l.font      = DS.inter(13)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Date sort button: "November 29 ▼"
    private lazy var dateSortButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        return b
    }()

    // Container with green gradient
    private let containerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = DS.cardRadius
        v.layer.cornerCurve  = .continuous
        v.clipsToBounds      = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis    = .vertical
        s.spacing = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text          = "No transactions yet"
        l.font          = DS.inter(14)
        l.textColor     = UIColor.white.withAlphaComponent(0.65)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(red: 16/255,  green: 185/255, blue: 129/255, alpha: 1).cgColor,
            UIColor(red: 5/255,   green: 150/255, blue: 105/255, alpha: 1).cgColor
        ]
        g.startPoint   = CGPoint(x: 0, y: 0)
        g.endPoint     = CGPoint(x: 1, y: 1)
        g.cornerRadius = DS.cardRadius
        return g
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        updateDateLabel()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        // Pill inner stack: [←] Today [→]
        let pillStack = UIStackView(arrangedSubviews: [prevDayButton, todayLabel, nextDayButton])
        pillStack.axis      = .horizontal
        pillStack.spacing   = 6
        pillStack.alignment = .center
        pillStack.translatesAutoresizingMaskIntoConstraints = false
        datePillContainer.addSubview(pillStack)

        // Sort button with date label
        updateDateSortButton()

        // Header: "Recent Activity" + pill + sort
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), datePillContainer, dateSortButton])
        headerStack.axis      = .horizontal
        headerStack.spacing   = 8
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerStack)
        addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(emptyLabel)

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
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emptyLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 24),
            emptyLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Configure

    /// Принимает реальные транзакции с бэкенда; если пустой — показывает мок
    func configure(transactions: [TransactionResponse]) {
        allTransactions = transactions
        if transactions.isEmpty {
            showMockData()
        } else {
            applyDateFilter()
        }
    }

    private func applyDateFilter() {
        let cal = Calendar.current
        let filtered = allTransactions.filter { cal.isDate($0.createdAt, inSameDayAs: selectedDate) }
        let shown = Array(filtered.prefix(3))
        renderRows(shown)
    }

    private func showMockData() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.isHidden = true

        let rows: [(String, String, String, String, Bool, MockLogo)] = [
            ("Yandex Plus Subscription", "Subscription", "21:55", "-400₽", false, .yandex),
            ("Spotify Subscription",     "Subscription", "12:12", "-700₽", false, .spotify),
            ("UI/UX Designer Salary",    "Transfer",     "11:39", "+300₽", true,  .salary)
        ]

        for (i, r) in rows.enumerated() {
            stackView.addArrangedSubview(makeMockRow(title: r.0, cat: r.1, time: r.2, amount: r.3, isIncome: r.4, logo: r.5))
            if i < rows.count - 1 { stackView.addArrangedSubview(makeDivider()) }
        }
    }

    private func renderRows(_ transactions: [TransactionResponse]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.isHidden = !transactions.isEmpty

        for (i, tx) in transactions.enumerated() {
            stackView.addArrangedSubview(makeRow(tx))
            if i < transactions.count - 1 { stackView.addArrangedSubview(makeDivider()) }
        }
    }

    // MARK: - Date Actions

    @objc private func prevDayAction(_ sender: UIButton) {
        handleDateChangeAnimation(sender)
        prevDay()
    }

    @objc private func nextDayAction(_ sender: UIButton) {
        handleDateChangeAnimation(sender)
        nextDay()
    }

    @objc private func prevDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        updateDateSortButton()
        applyDateFilter()
    }

    @objc private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        updateDateSortButton()
        applyDateFilter()
    }

    private func handleDateChangeAnimation(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                sender.transform = .identity
            })
        }
    }

    @objc private func showDatePicker() {
        guard let vc = findViewController() else { return }

        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)

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

        alert.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            self?.selectedDate = Calendar.current.startOfDay(for: picker.date)
            self?.updateDateLabel()
            self?.updateDateSortButton()
            self?.applyDateFilter()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }

    private func updateDateLabel() {
        let cal = Calendar.current
        todayLabel.text = cal.isDateInToday(selectedDate) ? "Today" : shortDay(selectedDate)
    }

    private func updateDateSortButton() {
        let dateStr = formattedDate(selectedDate)
        let attrs = NSAttributedString(string: "\(dateStr) ", attributes: [
            .font: DS.inter(13),
            .foregroundColor: DS.textPrimary
        ])
        let icon = NSTextAttachment()
        icon.image = UIImage(named: "arrow-down")?.withRenderingMode(.alwaysOriginal)
        icon.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
        let full = NSMutableAttributedString(attributedString: attrs)
        full.append(NSAttributedString(attachment: icon))
        dateSortButton.setAttributedTitle(full, for: .normal)
    }

    private func shortDay(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        return df.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        return df.string(from: date)
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }

    // MARK: - Row Builders

    private enum MockLogo { case yandex, spotify, salary }

    private func makeMockRow(title: String, cat: String, time: String,
                             amount: String, isIncome: Bool, logo: MockLogo) -> UIView {
        let logoView = makeMockLogoView(logo)
        return buildRow(logoView: logoView, title: title, cat: cat, time: time,
                        amount: amount, isIncome: isIncome)
    }

    private func makeRow(_ tx: TransactionResponse) -> UIView {
        let isIncome = tx.type.lowercased() == "income" || tx.type.lowercased() == "saving"
        let amount   = NSDecimalNumber(decimal: tx.amount).doubleValue
        let amtText  = String(format: "%@%@", isIncome ? "+" : "-", formatAmount(abs(amount)))
        let time     = formatTime(tx.createdAt)

        // Иконка: ассет из iconUrl или программный placeholder
        let logoView: UIView
        if !tx.iconUrl.isEmpty, let img = UIImage(named: tx.iconUrl) {
            let iv = UIImageView(image: img)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 22
            iv.translatesAutoresizingMaskIntoConstraints = false
            logoView = iv
        } else {
            logoView = makeInitialsView(text: String(tx.category.prefix(2)).uppercased(),
                                        bg: DS.accent.withAlphaComponent(0.8))
        }
        return buildRow(logoView: logoView, title: tx.description.isEmpty ? tx.category : tx.description,
                        cat: tx.category, time: time, amount: amtText, isIncome: isIncome)
    }

    private func makeMockLogoView(_ logo: MockLogo) -> UIView {
        switch logo {
        case .yandex:
            // Gradient circle for Yandex with "SU" text
            let v = GradientCircleView(
                colors: [UIColor(red: 0.1, green: 0.7, blue: 0.6, alpha: 1),  // Имитация цвета макета для Yandex - это просто зеленый с "SU" на дизайне
                         UIColor(red: 0.1, green: 0.7, blue: 0.6, alpha: 1)], // На дизайне круги полупрозрачные или зеленые – мы сделаем их единым стилем - белый текст на чуть более светлом зелёном фоне.
                text: "SU"
            )
            v.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            // Уберем сам градиент для чистоты, если он сливается:
            v.removeGradient() 
            return v
        case .spotify:
            let v = GradientCircleView(colors: [], text: "SU")
            v.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            return v
        case .salary:
            let v = GradientCircleView(colors: [], text: "TR")
            v.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            return v
        }
    }

    private func formatAmount(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","
        fmt.maximumFractionDigits = 0
        return (fmt.string(from: NSNumber(value: value)) ?? "\(Int(value))") + "\u{20BD}"
    }

    private func makeInitialsView(text: String, bg: UIColor) -> UIView {
        return GradientCircleView(colors: [bg, bg.withAlphaComponent(0.8)], text: text)
    }

    private func buildRow(logoView: UIView, title: String, cat: String,
                          time: String, amount: String, isIncome: Bool) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 72).isActive = true

        logoView.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text      = title
        titleLbl.font      = DS.golosSemi(15)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let catAttr = NSAttributedString(string: cat, attributes: [
            .font: DS.inter(12),
            .foregroundColor: UIColor.white.withAlphaComponent(0.75)
        ])
        let timeAttr = NSAttributedString(string: ", \(time)", attributes: [
            .font: DS.inter(12),
            .foregroundColor: UIColor.white.withAlphaComponent(0.65)
        ])
        let subAttr = NSMutableAttributedString(attributedString: catAttr)
        subAttr.append(timeAttr)

        let subLbl = UILabel()
        subLbl.attributedText = subAttr
        subLbl.translatesAutoresizingMaskIntoConstraints = false

        let amountLbl = UILabel()
        amountLbl.text          = amount
        amountLbl.font          = DS.golosBold(17)
        // Red color for expenses, green for income
        amountLbl.textColor     = isIncome ? UIColor(red: 0.35, green: 0.86, blue: 0.51, alpha: 1) : UIColor(red: 1.00, green: 0.33, blue: 0.33, alpha: 1)
        amountLbl.textAlignment = .right
        amountLbl.translatesAutoresizingMaskIntoConstraints = false

        // Design-driven colored pills
        let pillBg = UIView()
        pillBg.layer.cornerRadius = 10
        pillBg.layer.borderWidth = 1
        pillBg.layer.borderColor = UIColor.white.cgColor
        pillBg.backgroundColor = isIncome ? UIColor(red: 0.35, green: 0.80, blue: 0.45, alpha: 1) : UIColor(red: 0.88, green: 0.25, blue: 0.25, alpha: 1)
        pillBg.translatesAutoresizingMaskIntoConstraints = false

        let pillLbl = UILabel()
        pillLbl.text          = isIncome ? "Income" : "Expense"
        pillLbl.font          = DS.inter(11)
        pillLbl.textColor     = .white
        pillLbl.textAlignment = .center
        pillLbl.translatesAutoresizingMaskIntoConstraints = false
        pillBg.addSubview(pillLbl)

        [logoView, titleLbl, subLbl, amountLbl, pillBg].forEach { row.addSubview($0) }

        NSLayoutConstraint.activate([
            logoView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            logoView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 44),
            logoView.heightAnchor.constraint(equalToConstant: 44),

            titleLbl.bottomAnchor.constraint(equalTo: row.centerYAnchor, constant: 1),
            titleLbl.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 14),
            titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: amountLbl.leadingAnchor, constant: -16),

            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 2),
            subLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subLbl.trailingAnchor.constraint(equalTo: titleLbl.trailingAnchor),

            amountLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            amountLbl.bottomAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 2),
            amountLbl.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),

            pillBg.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            pillBg.topAnchor.constraint(equalTo: subLbl.topAnchor, constant: -2),
            pillBg.widthAnchor.constraint(equalToConstant: 64),
            pillBg.heightAnchor.constraint(equalToConstant: 20),

            pillLbl.centerXAnchor.constraint(equalTo: pillBg.centerXAnchor),
            pillLbl.centerYAnchor.constraint(equalTo: pillBg.centerYAnchor),
        ])

        return row
    }

    private func makeDivider() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(v)
        NSLayoutConstraint.activate([
            wrapper.heightAnchor.constraint(equalToConstant: 1),
            v.heightAnchor.constraint(equalToConstant: 1),
            v.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            v.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 70),
            v.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -14)
        ])
        return wrapper
    }

    private func formatTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }
}

// MARK: - GradientCircleView (helper for mock company logos)

private final class GradientCircleView: UIView {
    private let gradColors: [UIColor]
    private let text: String

    private let gLayer = CAGradientLayer()

    private let lbl: UILabel = {
        let l = UILabel()
        l.textColor     = .white
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    init(colors: [UIColor], text: String) {
        self.gradColors = colors
        self.text       = text
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 22

        if !colors.isEmpty {
            gLayer.colors     = colors.map(\.cgColor)
            gLayer.startPoint = CGPoint(x: 0, y: 0)
            gLayer.endPoint   = CGPoint(x: 1, y: 1)
            layer.insertSublayer(gLayer, at: 0)
        }

        lbl.text = text
        lbl.font = DS.golosBold(text.count > 2 ? 11 : 14)
        addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !gradColors.isEmpty {
            gLayer.frame = bounds
        }
        layer.cornerRadius = bounds.height / 2
    }

    func removeGradient() {
        gLayer.removeFromSuperlayer()
    }
}
