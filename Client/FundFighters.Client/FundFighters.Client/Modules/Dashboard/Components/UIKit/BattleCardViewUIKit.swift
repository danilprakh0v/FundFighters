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
        l.text      = "Recent Battle"
        l.font      = DS.golosBold(20)
        l.textColor = DS.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let datePillContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.93, alpha: 1)
        v.layer.cornerRadius = 12
        v.layer.cornerCurve = .continuous
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
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateSortButton: UIButton = {
        let b = UIButton(type: .custom)
        let attrs = NSAttributedString(string: "November 29", attributes: [
            .font: DS.inter(13), .foregroundColor: DS.textPrimary
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
        l.text      = "No Recent Battles"
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
        l.text          = "Nothing happened on this day."
        l.font          = DS.inter(14)
        l.textColor     = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        l.isHidden      = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { fatalError() }

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

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), datePillContainer, dateSortButton])
        headerStack.axis = .horizontal; headerStack.spacing = 8; headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

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
            datePillContainer.heightAnchor.constraint(equalToConstant: 30),

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
            
            emptyLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor, constant: 10),

            // Враг (Playstation monster) слева направо снизу — сделан крупнее
            enemyImageView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 20),
            enemyImageView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -5),
            enemyImageView.widthAnchor.constraint(equalToConstant: 180),
            enemyImageView.heightAnchor.constraint(equalToConstant: 215),

            nemesisLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -12),
            nemesisLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Configure

    func configure(battles: [BattleResponse]) {
        self.allBattles = battles
        
        applyDateFilter()
    }
    
    // MARK: - Date Logic
    
    private func applyDateFilter() {
        let cal = Calendar.current
        let valids = allBattles.filter { cal.isDate($0.battleDate, inSameDayAs: selectedDate) }
        
        if let last = valids.first, !last.enemyName.isEmpty {
            nemesisLabel.text = last.enemyName
            enemyImageView.isHidden = false
            emptyLabel.isHidden = true
        } else {
            nemesisLabel.text = "No Recent Battles"
            enemyImageView.isHidden = true
            emptyLabel.isHidden = false
        }
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
        periodLabel.text = cal.isDateInToday(selectedDate) ? "Today" : shortDay(selectedDate)
        
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
        dateSortButton.setImage(nil, for: .normal) // clean up generic image
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
