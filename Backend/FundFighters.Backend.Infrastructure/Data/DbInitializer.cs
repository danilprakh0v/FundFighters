/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: DbInitializer.cs
Расположение: FundFighters.Backend.Infrastructure/Data/
Назначение: Инициализатор БД для заполнения seed data при первом запуске.
===============================================================================
*/

using FundFighters.Backend.Domain.Entities;
using FundFighters.Backend.Domain.Enums;
using BCrypt.Net;

namespace FundFighters.Backend.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task InitializeAsync(AppDbContext context)
    {
        if (context.Players.Any())
        {
            return; 
        }

        // 1. Create Enemies
        var ps5Boss = new Enemy
        {
            Name = "Playstation 5 Slim",
            MaxHp = 62000,
            CurrentHp = 38750,
            ImageUrl = "ps5_slim_asset",
            IsDefeated = false,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var budgetDragon = new Enemy
        {
            Name = "Monthly Budget Dragon",
            MaxHp = 50000,
            CurrentHp = 0,
            ImageUrl = "boss_dragon_asset",
            IsDefeated = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        context.Enemies.AddRange(ps5Boss, budgetDragon);
        await context.SaveChangesAsync();

        // 2. Create Player
        var player = new Player
        {
            Username = "FinanceHero",
            Email = "test@example.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!"),
            IsVerified = true,
            Balance = 145000.99m,
            Level = 5,
            CurrentXp = 450,
            XpToNextLevel = 1000,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        context.Players.Add(player);
        await context.SaveChangesAsync();

        // 3. Create Savings Goal
        var activeGoal = new SavingsGoal
        {
            PlayerId = player.Id.ToString(),
            GoalName = "Playstation 5 Slim",
            Description = "Defeat the console boss to earn your reward!",
            TargetAmount = 62000,
            CurrentAmount = 23250,
            ImageUrl = "ps5_slim_asset",
            IsActive = true,
            TotalHearts = 10,
            DefeatedHearts = 3,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        context.SavingsGoals.Add(activeGoal);
        await context.SaveChangesAsync();

        // 4. Create Categories
        var categories = new List<ExpenseCategory>
        {
            new ExpenseCategory { PlayerId = player.Id.ToString(), Name = "Food", ColorHex = "#33DF72", SortOrder = 1 },
            new ExpenseCategory { PlayerId = player.Id.ToString(), Name = "Tech", ColorHex = "#3D8EFF", SortOrder = 2 },
            new ExpenseCategory { PlayerId = player.Id.ToString(), Name = "Rent", ColorHex = "#FF8C33", SortOrder = 3 },
            new ExpenseCategory { PlayerId = player.Id.ToString(), Name = "Entertainment", ColorHex = "#FF3D6E", SortOrder = 4 },
            new ExpenseCategory { PlayerId = player.Id.ToString(), Name = "Other", ColorHex = "#BE33FF", SortOrder = 5 }
        };

        context.ExpenseCategories.AddRange(categories);
        await context.SaveChangesAsync();

        // 5. Create Transactions
        var transactions = new List<Transaction>
        {
            new Transaction
            {
                PlayerId = player.Id,
                Title = "Salary Payment",
                Category = "Income",
                Amount = 180000,
                Type = TransactionType.Saving,
                Date = DateTime.UtcNow.AddDays(-5),
                IconUrl = "salary_icon",
                CreatedAt = DateTime.UtcNow.AddDays(-5)
            },
            new Transaction
            {
                PlayerId = player.Id,
                Title = "Grocery Store",
                Category = "Food",
                Amount = 4500,
                Type = TransactionType.Expense,
                Date = DateTime.UtcNow.AddDays(-2),
                IconUrl = "grocery_icon",
                CreatedAt = DateTime.UtcNow.AddDays(-2)
            },
            new Transaction
            {
                PlayerId = player.Id,
                Title = "Rent Payment",
                Category = "Rent",
                Amount = 45000,
                Type = TransactionType.Expense,
                Date = DateTime.UtcNow.AddDays(-1),
                IconUrl = "rent_icon",
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            }
        };

        context.Transactions.AddRange(transactions);
        await context.SaveChangesAsync();

        // 6. Create Battle History
        var battles = new List<Battle>
        {
            new Battle
            {
                PlayerId = player.Id.ToString(),
                SavingsGoalId = activeGoal.Id.ToString(),
                DamageDealt = 5000,
                XpGained = 200,
                BattleResult = "won",
                BattleDate = DateTime.UtcNow.AddDays(-3)
            },
            new Battle
            {
                PlayerId = player.Id.ToString(),
                SavingsGoalId = activeGoal.Id.ToString(),
                DamageDealt = 1200,
                XpGained = 50,
                BattleResult = "won",
                BattleDate = DateTime.UtcNow.AddDays(-1)
            }
        };

        context.Battles.AddRange(battles);
        await context.SaveChangesAsync();
    }
}
