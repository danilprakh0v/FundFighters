/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client/Backend Service])
Файл: BattleViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Battle/
Назначение: Экран битвы — игровая визуализация процесса накопления средств
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - LightLiquidGlassContainerView (Светлый стеклянный контейнер)

fileprivate class LightLiquidGlassContainerView: UIView {
    private(set) var tintOverlay = UIView()
    private let blurContainer    = UIView()
    private let accentBackground = UIView()
    private let specularGradient = CAGradientLayer()
    private var didSetup         = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }

    // Настройка эффекта стекла
    func setupGlass() {
        guard !didSetup else { return }
        didSetup = true

        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 12

        accentBackground.translatesAutoresizingMaskIntoConstraints = false
        accentBackground.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        blurContainer.translatesAutoresizingMaskIntoConstraints = false
        blurContainer.clipsToBounds = true

        specularGradient.colors     = [UIColor.white.withAlphaComponent(0.8).cgColor,
                                       UIColor.white.withAlphaComponent(0.0).cgColor]
        specularGradient.locations  = [0.0, 0.6]
        specularGradient.startPoint = CGPoint(x: 0.3, y: 0)
        specularGradient.endPoint   = CGPoint(x: 0.7, y: 1)

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let vev = UIVisualEffectView(effect: blurEffect)
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.clipsToBounds     = true
        vev.layer.borderWidth = 1.2
        vev.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor

        blurContainer.addSubview(vev)
        pinEdges(vev, to: blurContainer)

        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        vev.contentView.addSubview(tintOverlay)
        pinEdges(tintOverlay, to: vev.contentView)
        vev.contentView.layer.addSublayer(specularGradient)

        insertSubview(accentBackground, at: 0)
        insertSubview(blurContainer, aboveSubview: accentBackground)
        pinEdges(blurContainer, to: self)
        pinEdges(accentBackground, to: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.height / 2
        accentBackground.layer.cornerRadius = r
        accentBackground.layer.cornerCurve  = .continuous
        blurContainer.layer.cornerRadius    = r
        blurContainer.layer.cornerCurve     = .continuous
        if let ev = blurContainer.subviews.first as? UIVisualEffectView {
            ev.layer.cornerRadius         = r
            ev.layer.cornerCurve          = .continuous
            specularGradient.frame        = ev.contentView.bounds
            specularGradient.cornerRadius = r
        }
    }

    private func pinEdges(_ child: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
    }
}

// MARK: - GlassCircleButton (Стеклянная круглая кнопка)

fileprivate final class GlassCircleButton: UIControl {
    private let glassContainer = LightLiquidGlassContainerView()
    private let iconImageView = UIImageView()
    private let badgeView = UIView()
    private var didLayout = false

    init(iconName: String, iconColor: UIColor, hasBadge: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        glassContainer.isUserInteractionEnabled = false
        addSubview(glassContainer)

        iconImageView.image = UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        badgeView.backgroundColor = UIColor(red: 160/255, green: 160/255, blue: 165/255, alpha: 1)
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 2.0
        badgeView.isHidden = !hasBadge
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView)

        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            badgeView.widthAnchor.constraint(equalToConstant: 12),
            badgeView.heightAnchor.constraint(equalToConstant: 12)
        ])

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchCancel), for: [.touchUpOutside, .touchCancel, .touchUpInside])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        badgeView.layer.cornerRadius = badgeView.bounds.height / 2
        if !didLayout, bounds.height > 0 {
            didLayout = true
            glassContainer.setupGlass()
        }
    }

    @objc private func touchDown() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            self.glassContainer.tintOverlay.alpha = 0.8
        }
    }

    @objc private func touchCancel() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
            self.transform = .identity
            self.glassContainer.tintOverlay.alpha = 1.0
        }
    }
}

// MARK: - BattleViewController

final class BattleViewController: UIViewController {

    // MARK: - Обратные вызовы (Callbacks)
    
    // Вызывается после каждого изменения суммы накоплений
    var onSavingsUpdated: ((Double, Double, String) -> Void)?

    // MARK: - Состояние (State)
    
    private var currentAmount: Double = 23250
    private var targetAmount: Double  = 62000
    private var goalName: String      = "Playstation 5 Slim"
    private var isAnimating = false

    private var progress: Double { min(1.0, max(0, currentAmount / targetAmount)) }

    // MARK: - Инициализатор (Init)
    
    convenience init(currentAmount: Double, targetAmount: Double, goalName: String) {
        self.init()
        self.currentAmount = currentAmount
        self.targetAmount  = targetAmount
        self.goalName      = goalName
    }

    // MARK: - UI Элементы

    private let headerContainer = UIView()

    private lazy var backButton = GlassCircleButton(iconName: "chevron.left", iconColor: .black)
    private lazy var notificationButton = GlassCircleButton(iconName: "bell.fill", iconColor: .systemGray, hasBadge: true)

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Сцена битвы"
        lbl.font = .systemFont(ofSize: 28, weight: .black)
        lbl.textColor = .black
        return lbl
    }()

    private let goalCardView = SavingsGoalCardView()

    private let battleContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "battle_bg")
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    // Спрайт игрока
    private let playerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "player_m")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // Спрайт врага
    private let enemyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "plst_obj")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // Визуальный эффект удара
    private let slashEffectView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.alpha = 0
        v.layer.cornerRadius = 24
        return v
    }()

    private let actionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()

    private let saveMoneyButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "save_bt"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.backgroundColor = .clear
        return btn
    }()

    private let trackSpendingButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "track_bt"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.backgroundColor = .clear
        return btn
    }()

    // MARK: - Жизненный цикл (Lifecycle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 244/255, green: 250/255, blue: 247/255, alpha: 1.0)
        setupViews()
        setupConstraints()
        setupActions()
        refreshCard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        forceDesignOverrides()
    }

    // Принудительная настройка стилей карточки
    private func forceDesignOverrides() {
        goalCardView.layer.borderWidth = 0
        goalCardView.layer.shadowColor = UIColor.black.cgColor
        goalCardView.layer.shadowOpacity = 0.05
        goalCardView.layer.shadowRadius = 15
        goalCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        for subview in goalCardView.subviews {
            if let btn = subview as? UIButton {
                btn.setImage(UIImage(named: "fight_act"), for: .normal)
            }
        }
    }

    // MARK: - Настройка верстки (Setup)

    private func setupViews() {
        [headerContainer, backButton, titleLabel, notificationButton,
         goalCardView, battleContainer, backgroundImageView,
         playerImageView, enemyImageView, slashEffectView, actionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        headerContainer.addSubview(backButton)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(notificationButton)
        view.addSubview(headerContainer)

        view.addSubview(goalCardView)

        battleContainer.addSubview(backgroundImageView)
        battleContainer.addSubview(playerImageView)
        battleContainer.addSubview(enemyImageView)
        battleContainer.addSubview(slashEffectView)
        view.addSubview(battleContainer)

        actionsStackView.addArrangedSubview(saveMoneyButton)
        actionsStackView.addArrangedSubview(trackSpendingButton)
        view.addSubview(actionsStackView)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Заголовок (Header)
            headerContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            notificationButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            notificationButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 44),
            notificationButton.heightAnchor.constraint(equalToConstant: 44),

            // Карточка (Card)
            goalCardView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            goalCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            goalCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Контейнер битвы
            battleContainer.topAnchor.constraint(equalTo: goalCardView.bottomAnchor, constant: 20),
            battleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            battleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            battleContainer.bottomAnchor.constraint(equalTo: actionsStackView.topAnchor, constant: -20),

            backgroundImageView.topAnchor.constraint(equalTo: battleContainer.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: battleContainer.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor),

            slashEffectView.topAnchor.constraint(equalTo: battleContainer.topAnchor),
            slashEffectView.leadingAnchor.constraint(equalTo: battleContainer.leadingAnchor),
            slashEffectView.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor),
            slashEffectView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor),

            // Спрайты
            playerImageView.leadingAnchor.constraint(equalTo: battleContainer.leadingAnchor, constant: 30),
            playerImageView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor, constant: -35),
            playerImageView.widthAnchor.constraint(equalToConstant: 120),
            playerImageView.heightAnchor.constraint(equalToConstant: 150),

            enemyImageView.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor, constant: -30),
            enemyImageView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor, constant: -35),
            enemyImageView.widthAnchor.constraint(equalToConstant: 120),
            enemyImageView.heightAnchor.constraint(equalToConstant: 150),

            // Действия внизу (Bottom Actions)
            actionsStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            actionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionsStackView.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        goalCardView.onFightTapped = { [weak self] in
            self?.performPlayerAttack()
        }

        saveMoneyButton.addTarget(self, action: #selector(animateButtonPress(_:)), for: .touchDown)
        saveMoneyButton.addTarget(self, action: #selector(animateButtonRelease(_:)), for: [.touchUpOutside, .touchCancel])
        saveMoneyButton.addTarget(self, action: #selector(saveMoneyTapped), for: .touchUpInside)

        trackSpendingButton.addTarget(self, action: #selector(animateButtonPress(_:)), for: .touchDown)
        trackSpendingButton.addTarget(self, action: #selector(animateButtonRelease(_:)), for: [.touchUpOutside, .touchCancel])
        trackSpendingButton.addTarget(self, action: #selector(trackSpendingTapped), for: .touchUpInside)
    }

    // MARK: - Обновление данных (Refresh)

    private func refreshCard(animated: Bool = false) {
        let pct = progress * 100
        goalCardView.configure(
            goalName: goalName,
            current:  formatCurrency(currentAmount),
            target:   formatCurrency(targetAmount),
            percent:  String(format: "%.1f%%", pct),
            progress: progress
        )

        // Анимация карточки при обновлении
        if animated {
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseIn, animations: {
                self.goalCardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }) { _ in
                UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.6, options: .curveEaseOut) {
                    self.goalCardView.transform = .identity
                }
            }
        }

        // Синхронизация с Dashboard
        onSavingsUpdated?(currentAmount, targetAmount, goalName)
    }

    private func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = " "
        fmt.maximumFractionDigits = 0
        return (fmt.string(from: NSNumber(value: value)) ?? "\(Int(value))") + "₽"
    }

    // MARK: - Сохранение средств (Игрок атакует врага)

    @objc private func saveMoneyTapped() {
        animateButtonRelease(saveMoneyButton)
        showAmountMenu(title: "Накопить ⚔️",
                       subtitle: "Сколько вы отложили?",
                       presets: [500, 1000, 2500, 5000]) { [weak self] amount in
            guard let self = self else { return }
            self.currentAmount = min(self.targetAmount, self.currentAmount + amount)
            self.performPlayerAttack()
        }
    }

    // MARK: - Учет расходов (Враг атакует игрока)

    @objc private func trackSpendingTapped() {
        animateButtonRelease(trackSpendingButton)
        showAmountMenu(title: "Расход 💸",
                       subtitle: "Сколько вы потратили?",
                       presets: [500, 1000, 2500, 5000]) { [weak self] amount in
            guard let self = self else { return }
            self.currentAmount = max(0, self.currentAmount - amount)
            self.performEnemyAttack()
        }
    }

    // MARK: - Меню выбора суммы (Amount Menu)

    private func showAmountMenu(title: String, subtitle: String,
                                 presets: [Int], completion: @escaping (Double) -> Void) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)

        for preset in presets {
            let fmt = NumberFormatter()
            fmt.numberStyle = .decimal
            fmt.groupingSeparator = " "
            let label = fmt.string(from: NSNumber(value: preset)) ?? "\(preset)"
            alert.addAction(UIAlertAction(title: "\(label)₽", style: .default) { _ in
                completion(Double(preset))
            })
        }

        alert.addAction(UIAlertAction(title: "Своя сумма…", style: .default) { [weak self] _ in
            self?.showCustomAmountInput(completion: completion)
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        // Цветовой акцент для кнопок
        alert.view.tintColor = UIColor(red: 37/255, green: 163/255, blue: 115/255, alpha: 1)
        present(alert, animated: true)
    }

    private func showCustomAmountInput(completion: @escaping (Double) -> Void) {
        let alert = UIAlertController(title: "Введите сумму", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Сумма в ₽"
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let text = alert.textFields?.first?.text,
               let val = Double(text.replacingOccurrences(of: " ", with: "")), val > 0 {
                completion(val)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.view.tintColor = UIColor(red: 37/255, green: 163/255, blue: 115/255, alpha: 1)
        present(alert, animated: true)
    }

    // MARK: - Анимации (Animations)

    @objc private func backTapped() { dismiss(animated: true) }

    @objc private func animateButtonPress(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private func animateButtonRelease(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    // Анимация атаки игрока
    private func performPlayerAttack() {
        guard !isAnimating else { return }
        isAnimating = true
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // 1. Смена спрайта на атакующую позу
        UIView.transition(with: playerImageView, duration: 0.1, options: .transitionCrossDissolve) {
            self.playerImageView.image = UIImage(named: "player_attack")
        }

        // 2. Рывок вперёд
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            self.playerImageView.transform = CGAffineTransform(translationX: 55, y: -8).scaledBy(x: 1.12, y: 1.12)
        } completion: { _ in
            // Визуальный эффект удара
            self.flashSlash()

            // 3. Враг получает урон
            UIView.animate(withDuration: 0.08, animations: {
                self.enemyImageView.transform = CGAffineTransform(translationX: 30, y: -8).rotated(by: 0.2)
                self.enemyImageView.alpha = 0.3
            }) { _ in
                // 4. Возврат на исходную позицию
                UIView.animate(withDuration: 0.4, delay: 0.05, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.playerImageView.transform = .identity
                    self.enemyImageView.transform = .identity
                    self.enemyImageView.alpha = 1.0
                } completion: { _ in
                    // Возврат спрайта покоя
                    UIView.transition(with: self.playerImageView, duration: 0.2, options: .transitionCrossDissolve) {
                        self.playerImageView.image = UIImage(named: "player_m")
                    }
                    self.refreshCard(animated: true)
                    self.isAnimating = false
                }
            }
        }
    }

    // Анимация атаки врага
    private func performEnemyAttack() {
        guard !isAnimating else { return }
        isAnimating = true
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // 1. Рывок врага
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            self.enemyImageView.transform = CGAffineTransform(translationX: -50, y: -5).scaledBy(x: 1.15, y: 1.15)
        } completion: { _ in
            self.flashSlash()

            // 2. Игрок получает урон
            UIView.animate(withDuration: 0.08, animations: {
                self.playerImageView.transform = CGAffineTransform(translationX: -30, y: -5).rotated(by: -0.2)
                self.playerImageView.alpha = 0.3
            }) { _ in
                // 3. Возврат на исходную позицию
                UIView.animate(withDuration: 0.4, delay: 0.05, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.enemyImageView.transform = .identity
                    self.playerImageView.transform = .identity
                    self.playerImageView.alpha = 1.0
                } completion: { _ in
                    self.refreshCard(animated: true)
                    self.isAnimating = false
                }
            }
        }
    }

    // Белая вспышка
    private func flashSlash() {
        slashEffectView.alpha = 0.6
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.slashEffectView.alpha = 0
        }
    }
}
