/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: BattleStateDto.cs
Расположение: FundFighters.Backend.Application/DTOs/
Назначение: Объект передачи данных, содержащий полное состояние боевой системы
            для игрока. Возвращается в ответе API.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.Application.DTOs;

/// <summary>
/// DTO для передачи полного состояния боя игроку.
/// Содержит информацию о балансе игрока, уровне, враге и его здоровье.
/// Включает список недавних транзакций для виджета Recent Activity и URL картинки врага.
/// Используется в ответах API для мобильного клиента.
/// 
/// Data transfer object containing the current battle state for a player.
/// Contains information about player balance, level, enemy, and enemy health.
/// Includes recent transactions for Recent Activity widget and enemy image URL.
/// Used in API responses for mobile client.
/// </summary>
public class BattleStateDto
{
    /// <summary>
    /// Текущий баланс игрока в игре.
    /// Current player balance in the game.
    /// </summary>
    public decimal PlayerBalance { get; set; }

    /// <summary>
    /// Текущий уровень игрока (начинается с 1).
    /// Current player level (starts at 1).
    /// </summary>
    public int PlayerLevel { get; set; }

    /// <summary>
    /// Имя текущего врага/вызова (например, "Playstation 5 Slim", "Monthly Budget Dragon").
    /// Name of the current enemy/challenge (e.g., "Playstation 5 Slim", "Monthly Budget Dragon").
    /// </summary>
    public string EnemyName { get; set; } = string.Empty;

    /// <summary>
    /// Текущее количество здоровья врага (HP).
    /// Current health points of the enemy.
    /// </summary>
    public decimal EnemyCurrentHp { get; set; }

    /// <summary>
    /// Максимальное количество здоровья врага (Max HP).
    /// Maximum health points of the enemy.
    /// </summary>
    public decimal EnemyMaxHp { get; set; }

    /// <summary>
    /// Процент здоровья врага (0-100). Используется для UI полосы здоровья.
    /// Health percentage of the enemy (0-100). Used for UI health bar.
    /// </summary>
    public double HpPercentage { get; set; }

    /// <summary>
    /// Флаг, указывающий, был ли враг побежден в текущем раунде.
    /// Flag indicating if the enemy has been defeated in current round.
    /// </summary>
    public bool IsEnemyDefeated { get; set; }

    /// <summary>
    /// URL изображения врага для отрисовки спрайта на экране боя.
    /// URL to the enemy's image for rendering sprite on battle screen.
    /// </summary>
    public string EnemyImageUrl { get; set; } = string.Empty;

    /// <summary>
    /// Список последних 5 транзакций игрока для отображения в виджете Recent Activity.
    /// Используется на главном экране (Dashboard) для показания активности.
    /// 
    /// List of last 5 transactions for Recent Activity widget display.
    /// Used on main screen (Dashboard) to show player activity.
    /// </summary>
    public List<TransactionPreviewDto> RecentTransactions { get; set; } = new();
}
