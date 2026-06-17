/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: BalanceCardView.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/Components/UIKit/
Назначение: Увеличенная карточка баланса, оригинальные SVG и плавная анимация
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class BalanceCardView: UIView {

    // MARK: - Properties
    private var isBalanceHidden = false
    private var currentBalance = ""
    
    // Карточка стала больше, чтобы дышалось свободнее (430x240)
    private let cardWidth: CGFloat = 440
    private let cardHeight: CGFloat = 240
    private let cornerRadius: CGFloat = 24
    
    // MARK: - Background
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "card_ruble") ?? UIImage(named: "card_ruble.svg")
        iv.image = img
        iv.contentMode = .scaleToFill
        iv.layer.cornerCurve = .continuous
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Header
    private let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Balance"
        label.font = DS.interLight(20)      // Inter Light 20
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let eyeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: config), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.92)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Balance Amount
    private let balanceAmountLabel: UILabel = {
        let label = UILabel()
        label.font = DS.interExtraBold(32)       // Inter ExtraBold 32
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Income Section
    private let incomeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Income"
        label.font = DS.interLight(16)      // Inter Light 16
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let incomeAmountLabel: UILabel = {
        let label = UILabel()
        label.font = DS.interBold(20)       // Inter Bold 20
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Пилюля дохода (берет свой оригинальный intrinsic size из SVG)
    private let incomePillImageView: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "income_pill") ?? UIImage(named: "income_pill.svg")
        iv.image = img
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Ваша авторская стрелочка
    private let incomeArrowImageView: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "arrow_up") ?? UIImage(named: "arrow_up.svg")
        iv.image = img
        // Сохраняем пропорции оригинальной стрелки
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let incomePercentLabel: UILabel = {
        let label = UILabel()
        label.font = DS.interMedium(13)     // Inter Medium 13
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Стек для центрирования контента внутри пилюли
    private let incomeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Expense Section
    private let expenseTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Expense"
        label.font = DS.interLight(16)      // Inter Light 16
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let expenseAmountLabel: UILabel = {
        let label = UILabel()
        label.font = DS.interBold(20)       // Inter Bold 20
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Пилюля расхода (берет свой оригинальный intrinsic size из SVG)
    private let expensePillImageView: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "expense_pill") ?? UIImage(named: "expense_pill.svg")
        iv.image = img
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Ваша авторская стрелочка
    private let expenseArrowImageView: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "arrow_down") ?? UIImage(named: "arrow_down.svg")
        iv.image = img
        // Сохраняем пропорции оригинальной стрелки
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let expensePercentLabel: UILabel = {
        let label = UILabel()
        label.font = DS.interMedium(13)     // Inter Medium 13
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expenseStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Accounts Section
    private let accountsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Affiliated savings accounts"
        label.font = DS.interLight(16)      // Inter Light 16
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let accountsValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Main / Additional"
        label.font = DS.interBold(20)       // Inter Bold 20
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
        updateLocalization()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: cardWidth, height: cardHeight)
    }

    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
        
        backgroundImageView.layer.cornerRadius = cornerRadius
        
        // Тень карточки
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.masksToBounds = false
        
        addSubview(backgroundImageView)
        addSubview(totalBalanceLabel)
        addSubview(balanceAmountLabel)
        // MARK: - FIX 2: eyeButton добавляется после balanceAmountLabel,
        // чтобы не перекрывать лейбл и не блокировать transition-анимацию
        addSubview(eyeButton)
        
        addSubview(incomeTitleLabel)
        addSubview(incomeAmountLabel)
        
        // Income (Сначала процент, потом стрелочка)
        incomeStack.addArrangedSubview(incomePercentLabel)
        incomeStack.addArrangedSubview(incomeArrowImageView)
        addSubview(incomePillImageView)
        incomePillImageView.addSubview(incomeStack)
        
        addSubview(expenseTitleLabel)
        addSubview(expenseAmountLabel)
        
        // Expense (Сначала стрелочка, потом процент)
        expenseStack.addArrangedSubview(expenseArrowImageView)
        expenseStack.addArrangedSubview(expensePercentLabel)
        addSubview(expensePillImageView)
        expensePillImageView.addSubview(expenseStack)
        
        addSubview(accountsTitleLabel)
        addSubview(accountsValueLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Header
            totalBalanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            totalBalanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // Balance Amount
            balanceAmountLabel.topAnchor.constraint(equalTo: totalBalanceLabel.bottomAnchor, constant: 2),
            balanceAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // FIX 1: явный размер кнопки — иконка больше не схлопывается в 0
            eyeButton.widthAnchor.constraint(equalToConstant: 30),
            eyeButton.heightAnchor.constraint(equalToConstant: 30),
            eyeButton.centerYAnchor.constraint(equalTo: balanceAmountLabel.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: balanceAmountLabel.trailingAnchor, constant: 10),
            
            // Income Section (Строго 1 пиксель от низа баланса)
            incomeTitleLabel.topAnchor.constraint(equalTo: balanceAmountLabel.bottomAnchor, constant: 1),
            incomeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            incomeAmountLabel.topAnchor.constraint(equalTo: incomeTitleLabel.bottomAnchor, constant: 0),
            incomeAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            incomePillImageView.topAnchor.constraint(equalTo: incomeAmountLabel.bottomAnchor, constant: 6),
            incomePillImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // Центрируем стек внутри оригинальной SVG-пилюли
            incomeStack.centerXAnchor.constraint(equalTo: incomePillImageView.centerXAnchor),
            incomeStack.centerYAnchor.constraint(equalTo: incomePillImageView.centerYAnchor),
            
            // ЖЕСТКО ФИКСИРУЕМ РАЗМЕР ВАШЕЙ SVG СТРЕЛОЧКИ, ЧТОБЫ ОНА НЕ РАЗДУВАЛАСЬ
            incomeArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            incomeArrowImageView.heightAnchor.constraint(equalToConstant: 12),

            // FIX 3: Expense сдвинут с 200 → 160, ближе к Income, дальше от рубля
            expenseTitleLabel.topAnchor.constraint(equalTo: balanceAmountLabel.bottomAnchor, constant: 1),
            expenseTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 160),
            
            expenseAmountLabel.topAnchor.constraint(equalTo: expenseTitleLabel.bottomAnchor, constant: 0),
            expenseAmountLabel.leadingAnchor.constraint(equalTo: expenseTitleLabel.leadingAnchor),
            
            expensePillImageView.topAnchor.constraint(equalTo: expenseAmountLabel.bottomAnchor, constant: 6),
            expensePillImageView.leadingAnchor.constraint(equalTo: expenseTitleLabel.leadingAnchor),
            
            // Центрируем стек внутри оригинальной SVG-пилюли
            expenseStack.centerXAnchor.constraint(equalTo: expensePillImageView.centerXAnchor),
            expenseStack.centerYAnchor.constraint(equalTo: expensePillImageView.centerYAnchor),
            
            // ЖЕСТКО ФИКСИРУЕМ РАЗМЕР ВАШЕЙ SVG СТРЕЛОЧКИ, ЧТОБЫ ОНА НЕ РАЗДУВАЛАСЬ
            expenseArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            expenseArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Accounts Section (Располагаем внизу с учетом новой высоты карточки)
            accountsTitleLabel.topAnchor.constraint(equalTo: incomePillImageView.bottomAnchor, constant: 26),
            accountsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            accountsValueLabel.topAnchor.constraint(equalTo: accountsTitleLabel.bottomAnchor, constant: 0),
            accountsValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
    private func setupActions() {
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        eyeButton.layer.cornerRadius = eyeButton.bounds.height / 2
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        totalBalanceLabel.text = isRu ? "Общий баланс" : "Total Balance"
        incomeTitleLabel.text = isRu ? "Доходы" : "Income"
        expenseTitleLabel.text = isRu ? "Расходы" : "Expense"
        accountsTitleLabel.text = isRu ? "Связанные счета накоплений" : "Affiliated savings accounts"
        accountsValueLabel.text = isRu ? "Основной / Дополнительный" : "Main / Additional"
    }
    
    // MARK: - Public Methods
    func configure(balance: String, income: String, expense: String,
                   isHidden: Bool, incomePercent: String, expensePercent: String) {
        currentBalance = balance
        self.isBalanceHidden = isHidden
        
        balanceAmountLabel.text = isHidden ? "••••••" : balance
        incomeAmountLabel.text = income
        expenseAmountLabel.text = expense
        incomePercentLabel.text = incomePercent
        expensePercentLabel.text = expensePercent
    }
    
    // MARK: - Actions & Animations
    @objc private func eyeButtonTapped() {
        // Тактильный отклик (Haptic Feedback) для премиального ощущения
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        isBalanceHidden.toggle()
        let newText = isBalanceHidden ? "••••••" : currentBalance
        let newIconName = isBalanceHidden ? "eye.fill" : "eye.slash.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)

        // Пружинящая анимация кнопки
        UIView.animate(withDuration: 0.08, animations: {
            self.eyeButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }) { _ in
            // Меняем иконку в момент минимального масштаба — не заметно глазу
            self.eyeButton.setImage(UIImage(systemName: newIconName, withConfiguration: config), for: .normal)
            UIView.animate(withDuration: 0.18,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 6,
                           options: [],
                           animations: {
                self.eyeButton.transform = .identity
            })
        }

        // Анимация лейбла: уезжает вверх + растворяется, потом новый текст влетает снизу
        bringSubviewToFront(balanceAmountLabel)
        UIView.animate(withDuration: 0.15, delay: 0,
                       options: .curveEaseIn,
                       animations: {
            self.balanceAmountLabel.alpha = 0
            self.balanceAmountLabel.transform = CGAffineTransform(translationX: 0, y: -6)
        }) { _ in
            self.balanceAmountLabel.text = newText
            self.balanceAmountLabel.transform = CGAffineTransform(translationX: 0, y: 6)
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                self.balanceAmountLabel.alpha = 1
                self.balanceAmountLabel.transform = .identity
            }, completion: { _ in
                self.bringSubviewToFront(self.eyeButton)
            })
        }
    }
}
