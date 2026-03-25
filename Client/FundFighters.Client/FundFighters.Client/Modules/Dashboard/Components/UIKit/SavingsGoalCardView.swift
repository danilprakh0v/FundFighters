/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: SavingsGoalCardView.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/Components/UIKit/
Назначение: UI/Логика компонента SavingsGoalCardView.swift
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class SavingsGoalCardView: UIView {

    // MARK: - Props
    var onFightTapped: (() -> Void)?

    // MARK: - Constants
    private let accentColor   = UIColor(red: 37/255, green: 163/255, blue: 115/255, alpha: 1)
    private let totalHearts   = 8
    private let heartW: CGFloat       = 34
    private let heartSpacing: CGFloat = 3

    private var swordOverhang: CGFloat { heartW * (57.0 / 45.0) - heartW }

    // MARK: - Subviews

    // InterSemiBold 14 — название цели
    private let goalNameLabel: UILabel = {
        let l = UILabel()
        l.font = DS.interSemi(14)
        l.textColor = DS.textPrimary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.85
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // InterExtraBold 14 — «23,250₽ / 62,000₽»
    private let amountLabel: UILabel = {
        let l = UILabel()
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Пилюля — высота = высота текстовой строки
    private lazy var percentBadge: PaddedLabel = {
        let l = PaddedLabel()
        l.font = DS.golosMedium(13)
        l.textColor = .white
        l.backgroundColor = accentColor
        l.textAlignment = .center
        l.layer.masksToBounds = true
        l.edgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Контейнер сердец
    private let heartsRow: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // InterBold 14 (зелёный) + InterMedium 14 (тёмный)
    private let messageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Кнопка FIGHT — 56×56
    private lazy var fightButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "fight_inact"), for: .normal)
        b.imageView?.contentMode     = .scaleAspectFit
        b.contentVerticalAlignment   = .fill
        b.contentHorizontalAlignment = .fill
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(fightTouchDown), for: .touchDown)
        b.addTarget(self, action: #selector(fightTouchUp),
                    for: [.touchUpInside, .touchUpOutside, .touchCancel])
        b.addTarget(self, action: #selector(fightTapped), for: .touchUpInside)
        return b
    }()

    // SVG-рамка поверх всего содержимого — userInteractionEnabled = false,
    // чтобы не блокировать тапы на кнопку и сердца
    private let borderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "borderline_sg")
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = false
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.layer.cornerCurve = .continuous
        iv.clipsToBounds = true
        iv.alpha = 0.9
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - layoutSubviews

    override func layoutSubviews() {
        super.layoutSubviews()
        percentBadge.layer.cornerRadius = percentBadge.bounds.height / 2
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor    = .white
        
        // Улучшенная рамка карточки
        layer.cornerRadius = 20
        layer.cornerCurve  = .continuous
        layer.borderWidth  = 2
        layer.borderColor  = accentColor.cgColor
        
        // Усиленная тень для большей заметности
        layer.shadowColor   = accentColor.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius  = 12
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.masksToBounds = false

        // Контент добавляем первым
        addSubview(goalNameLabel)
        addSubview(amountLabel)
        addSubview(percentBadge)
        addSubview(heartsRow)
        addSubview(messageLabel)
        addSubview(fightButton)

        // Рамка — последней, лежит поверх всего как декоративный оверлей
        addSubview(borderImageView)

        let heartsContainerH = heartW + swordOverhang

        NSLayoutConstraint.activate([

            // ── Строка 1 ──
            goalNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            goalNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            amountLabel.firstBaselineAnchor.constraint(equalTo: goalNameLabel.firstBaselineAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: goalNameLabel.trailingAnchor, constant: 8),

            percentBadge.topAnchor.constraint(equalTo: goalNameLabel.topAnchor),
            percentBadge.bottomAnchor.constraint(equalTo: goalNameLabel.bottomAnchor),
            percentBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            percentBadge.leadingAnchor.constraint(greaterThanOrEqualTo: amountLabel.trailingAnchor, constant: 8),

            // ── Строка 2: сердца ──
            heartsRow.topAnchor.constraint(equalTo: goalNameLabel.bottomAnchor, constant: 14),
            heartsRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            heartsRow.heightAnchor.constraint(equalToConstant: heartsContainerH),

            // ── Строка 3: сообщение ──
            messageLabel.topAnchor.constraint(equalTo: heartsRow.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: fightButton.leadingAnchor, constant: -10),

            // ── Кнопка ──
            fightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            fightButton.centerYAnchor.constraint(equalTo: heartsRow.bottomAnchor,
                                                  constant: (10 + 20) / 2),
            fightButton.widthAnchor.constraint(equalToConstant: 56),
            fightButton.heightAnchor.constraint(equalToConstant: 56),

            // ── Рамка: точно по границам карточки ──
            borderImageView.topAnchor.constraint(equalTo: topAnchor),
            borderImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            borderImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    // MARK: - Configure

    func configure(goalName: String,
                   current: String,
                   target: String,
                   percent: String,
                   progress: Double) {

        goalNameLabel.text = goalName
        percentBadge.text  = percent.replacingOccurrences(of: ".", with: ",")

        let attrs = NSMutableAttributedString()
        attrs.append(NSAttributedString(
            string: formatAmount(parseAmount(current)) + "₽",
            attributes: [.font: DS.interExtraBold(14), .foregroundColor: accentColor]))
        attrs.append(NSAttributedString(
            string: " / " + formatAmount(parseAmount(target)) + "₽",
            attributes: [.font: DS.interExtraBold(14), .foregroundColor: DS.textPrimary]))
        amountLabel.attributedText = attrs

        messageLabel.attributedText = buildMessage(current: current, target: target)
        buildHearts(progress: progress)
    }

    // MARK: - Hearts

    private var heartsWidthConstraint: NSLayoutConstraint?

    private func buildHearts(progress: Double) {
        heartsRow.subviews.forEach { $0.removeFromSuperview() }
        heartsWidthConstraint?.isActive = false

        let savedCount = min(totalHearts, max(0, Int(round(progress * Double(totalHearts)))))

        let totalW = CGFloat(totalHearts) * heartW + CGFloat(totalHearts - 1) * heartSpacing
        heartsWidthConstraint = heartsRow.widthAnchor.constraint(equalToConstant: totalW)
        heartsWidthConstraint?.isActive = true

        for i in 0..<totalHearts {
            let isSaved = i < savedCount
            let x = CGFloat(i) * (heartW + heartSpacing)
            let iv = UIImageView()
            iv.contentMode   = .scaleAspectFit
            iv.clipsToBounds = false

            if isSaved {
                iv.image = UIImage(named: "heart_empty")
                let aspectH = heartW * (57.0 / 45.0)
                iv.frame = CGRect(x: x, y: heartW - aspectH, width: heartW, height: aspectH)
            } else {
                iv.image = UIImage(named: "heart_full")
                let aspectH = heartW * (37.0 / 39.0)
                iv.frame = CGRect(x: x, y: (heartW - aspectH) / 2, width: heartW, height: aspectH)
            }

            heartsRow.addSubview(iv)

            if #available(iOS 13.0, *) {
                iv.isUserInteractionEnabled = true
                let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
                iv.addGestureRecognizer(hover)
            }
        }
    }

    // MARK: - Message

    private func buildMessage(current: String, target: String) -> NSAttributedString {
        let rem = max(0, parseAmount(target) - parseAmount(current))
        guard rem > 0 else {
            return NSAttributedString(
                string: "Goal achieved! 🎉",
                attributes: [.font: DS.interBold(14), .foregroundColor: accentColor])
        }
        let msg = NSMutableAttributedString()
        msg.append(NSAttributedString(
            string: formatAmount(rem) + "₽",
            attributes: [.font: DS.interBold(14), .foregroundColor: accentColor]))
        msg.append(NSAttributedString(
            string: " more to win your enemy",
            attributes: [.font: DS.interMedium(14), .foregroundColor: DS.textPrimary]))
        return msg
    }

    // MARK: - Helpers

    private func parseAmount(_ s: String) -> Double {
        Double(s.replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "₽", with: "")
                .replacingOccurrences(of: "P",  with: "")
                .trimmingCharacters(in: .whitespaces)) ?? 0
    }

    private func formatAmount(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle       = .decimal
        fmt.groupingSeparator = ","
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    // MARK: - Hover

    @available(iOS 13.0, *)
    @objc private func handleHover(_ g: UIHoverGestureRecognizer) {
        guard let v = g.view else { return }
        switch g.state {
        case .began:
            UIView.animate(withDuration: 0.18, delay: 0,
                           usingSpringWithDamping: 0.45, initialSpringVelocity: 10,
                           options: .allowUserInteraction) {
                v.transform = CGAffineTransform(translationX: 0, y: -7)
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.24, delay: 0,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 4,
                           options: .allowUserInteraction) {
                v.transform = .identity
            }
        default: break
        }
    }

    // MARK: - Fight button animations

    @objc private func fightTouchDown() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.fightButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }
        UIView.transition(with: fightButton, duration: 0.15, options: .transitionCrossDissolve) {
            self.fightButton.setImage(UIImage(named: "fight_act"), for: .normal)
        }
    }

    @objc private func fightTouchUp() {
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            self.fightButton.transform = .identity
        }
        UIView.transition(with: fightButton, duration: 0.25, options: .transitionCrossDissolve) {
            self.fightButton.setImage(UIImage(named: "fight_inact"), for: .normal)
        }
    }

    @objc private func fightTapped() { onFightTapped?() }
}

// MARK: - PaddedLabel

private final class PaddedLabel: UILabel {
    var edgeInsets = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width:  s.width  + edgeInsets.left + edgeInsets.right,
                      height: s.height + edgeInsets.top  + edgeInsets.bottom)
    }
}
