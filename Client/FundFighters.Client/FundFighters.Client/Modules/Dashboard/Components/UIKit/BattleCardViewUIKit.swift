/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: BattleCardViewUIKit.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/Components/UIKit/
Назначение: Карточка "Recent Battle" с изображением врага и заголовком.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class BattleCardViewUIKit: UIView {

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text      = UserManager.shared.isRussian ? "Недавняя битва" : "Recent Battle"
        l.font      = DS.golosBold(19)
        l.textColor = DS.textPrimary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.62
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let datePillContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.70)
        v.layer.cornerRadius = 15
        v.layer.cornerCurve = .continuous
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
        b.addTarget(self, action: #selector(prevDayAction(_:)), for: .touchUpInside)
        return b
    }()

    private lazy var nextDayButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        b.tintColor = UIColor.black.withAlphaComponent(0.3)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(nextDayAction(_:)), for: .touchUpInside)
        return b
    }()

    private let periodLabel: UILabel = {
        let l = UILabel()
        l.text      = "Today"
        l.font      = DS.inter(13)
        l.textColor = DS.textPrimary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.75
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var dateSortButton: UIButton = {
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
        b.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        return b
    }()

    private let bannerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = DS.cardRadius
        v.layer.cornerCurve  = .continuous
        v.clipsToBounds      = true
        return v
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

    private let enemyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "recent_enemy")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let axeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "axe")
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.95
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let shieldImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "shield")
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.95
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - State
    private var allBattles: [BattleResponse] = []
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    private let nemesisLabel: UILabel = {
        let l = UILabel()
        l.text      = UserManager.shared.isRussian ? "Битв пока нет" : "No Recent Battles"
        l.font      = DS.golosBold(22)
        l.textColor = .white
        l.layer.shadowColor   = UIColor.black.cgColor
        l.layer.shadowOpacity = 0.5
        l.layer.shadowRadius  = 4
        l.layer.shadowOffset  = CGSize(width: 0, height: 2)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text          = ""
        l.font          = DS.golosSemi(16)
        l.textColor     = UIColor.white.withAlphaComponent(0.78)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.72
        l.isHidden      = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

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
        gradientLayer.frame = bannerView.bounds
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        bannerView.layer.insertSublayer(gradientLayer, at: 0)

        let pillStack = UIStackView(arrangedSubviews: [prevDayButton, periodLabel, nextDayButton])
        pillStack.axis = .horizontal; pillStack.spacing = 6; pillStack.alignment = .center
        pillStack.translatesAutoresizingMaskIntoConstraints = false
        datePillContainer.addSubview(pillStack)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, spacer, datePillContainer, dateSortButton])
        headerStack.axis = .horizontal; headerStack.spacing = 8; headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(headerStack)
        addSubview(bannerView)
        bannerView.addSubview(overlayView)
        // Иконки фона (декорации)
        bannerView.addSubview(axeImageView)
        bannerView.addSubview(shieldImageView)
        bannerView.addSubview(emptyLabel)
        // Враг спереди
        bannerView.addSubview(enemyImageView)
        bannerView.addSubview(nemesisLabel)

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

            bannerView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            bannerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 220),

            overlayView.topAnchor.constraint(equalTo: bannerView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor),

            // Щит аккуратно под топором
            shieldImageView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -90),
            shieldImageView.topAnchor.constraint(equalTo: axeImageView.bottomAnchor, constant: -50),
            shieldImageView.widthAnchor.constraint(equalToConstant: 60),
            shieldImageView.heightAnchor.constraint(equalToConstant: 70),

            // Топор справа сверху
            axeImageView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -10),
            axeImageView.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 10),
            axeImageView.widthAnchor.constraint(equalToConstant: 130),
            axeImageView.heightAnchor.constraint(equalToConstant: 130),
            
            emptyLabel.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -24),
            emptyLabel.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 62),

            // Враг (Playstation monster) слева направо снизу — сделан крупнее
            enemyImageView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 20),
            enemyImageView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -5),
            enemyImageView.widthAnchor.constraint(equalToConstant: 180),
            enemyImageView.heightAnchor.constraint(equalToConstant: 215),

            nemesisLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -12),
            nemesisLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -16),
            nemesisLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bannerView.leadingAnchor, constant: 24)
        ])
    }

    // MARK: - Configure

    func configure(battles: [BattleResponse]) {
        self.allBattles = battles
        
        applyDateFilter()
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Недавняя битва" : "Recent Battle"
        emptyLabel.text = ""
        updateDateLabel()
        applyDateFilter()
    }
    
    // MARK: - Date Logic
    
    private func applyDateFilter() {
        let cal = Calendar.current
        let valids = allBattles.filter { cal.isDate($0.battleDate, inSameDayAs: selectedDate) }
        
        if let last = valids.first, !last.enemyName.isEmpty {
            nemesisLabel.text = last.enemyName
            enemyImageView.image = enemyImageForActiveGoal()
            enemyImageView.isHidden = false
            emptyLabel.isHidden = true
        } else {
            if !UserManager.shared.session.customEnemyName.isEmpty {
                nemesisLabel.text = UserManager.shared.isRussian
                    ? "Готов к битве"
                    : "Ready to Fight"
            } else {
                nemesisLabel.text = UserManager.shared.isRussian ? "Битв пока нет" : "No Recent Battles"
            }
            enemyImageView.image = enemyImageForActiveGoal()
            enemyImageView.isHidden = false
            emptyLabel.isHidden = true
        }
    }

    private func enemyImageForActiveGoal() -> UIImage? {
        let goal = UserManager.shared.activeEnemyGoal()
        if !goal.isDefault,
           let custom = UserManager.shared.customEnemyImage() {
            return custom
        }
        return UIImage(named: "recent_enemy")
    }
    
    @objc private func prevDayAction(_ sender: UIButton) {
        handleDateChangeAnimation(sender)
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        applyDateFilter()
    }

    @objc private func nextDayAction(_ sender: UIButton) {
        handleDateChangeAnimation(sender)
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        applyDateFilter()
    }
    
    private func updateDateLabel() {
        let cal = Calendar.current
        let isRu = UserManager.shared.isRussian
        if cal.isDateInToday(selectedDate) {
            periodLabel.text = isRu ? "Сегодня" : "Today"
        } else if cal.isDateInYesterday(selectedDate) {
            periodLabel.text = isRu ? "Вчера" : "Yesterday"
        } else {
            periodLabel.text = shortDay(selectedDate)
        }
        
        // update sort button 
        let dateStr = formattedDate(selectedDate)
        let attrs = NSAttributedString(string: "\(dateStr) ", attributes: [
            .font: DS.inter(13), .foregroundColor: DS.textPrimary
        ])
        let icon = NSTextAttachment()
        icon.image = UIImage(systemName: "chevron.up.chevron.down",
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))?
                     .withTintColor(DS.accent, renderingMode: .alwaysOriginal)
                     
                     // fallback to arrow down if previous fails
                     ?? UIImage(named: "arrow-down")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
                     
        icon.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
        let full = NSMutableAttributedString(attributedString: attrs)
        full.append(NSAttributedString(attachment: icon))
        dateSortButton.setAttributedTitle(full, for: .normal)
        dateSortButton.setImage(nil, for: .normal)
    }

    @objc private func showDatePicker() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(title: isRu ? "Выберите дату" : "Select Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = selectedDate
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor)
        ])

        alert.addAction(UIAlertAction(title: isRu ? "Применить" : "Apply", style: .default) { [weak self] _ in
            self?.selectedDate = Calendar.current.startOfDay(for: picker.date)
            self?.updateDateLabel()
            self?.applyDateFilter()
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

    private func shortDay(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        df.locale = Locale(identifier: UserManager.shared.isRussian ? "ru_RU" : "en_US")
        return df.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        df.locale = Locale(identifier: UserManager.shared.isRussian ? "ru_RU" : "en_US")
        return df.string(from: date)
    }

    @objc private func handleDateChangeAnimation(_ sender: UIButton) {
        // Добавляем красивую анимацию при смене даты
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                sender.transform = .identity
            })
        }
    }
}
