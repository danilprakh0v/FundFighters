/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: AppDbContext.cs
Расположение: Backend/FundFighters.Backend.Infrastructure/Data/
Назначение: Контекст базы данных Entity Framework Core.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FundFighters.Backend.Infrastructure.Data;

/// <summary>
/// Контекст базы данных для приложения FundFighters.
/// </summary>
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Player> Players { get; set; } = null!;
    public DbSet<Enemy> Enemies { get; set; } = null!;
    public DbSet<Transaction> Transactions { get; set; } = null!;
    public DbSet<SavingsGoal> SavingsGoals { get; set; } = null!;
    public DbSet<Battle> Battles { get; set; } = null!;
    public DbSet<ExpenseCategory> ExpenseCategories { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Маппинг таблиц
        modelBuilder.Entity<SavingsGoal>().ToTable("EnemyGoals");
        modelBuilder.Entity<Battle>().ToTable("Battles");

        // Конфигурация игрока
        modelBuilder.Entity<Player>(entity =>
        {
            entity.HasKey(p => p.Id);

            entity.Property(p => p.Username)
                .IsRequired()
                .HasMaxLength(255);

            entity.Property(p => p.Balance)
                .HasPrecision(18, 2);

            entity.Property(p => p.Level)
                .HasDefaultValue(1);

            entity.Property(p => p.CurrentXp)
                .HasDefaultValue(0);

            entity.Property(p => p.XpToNextLevel)
                .HasDefaultValue(100);

            entity.Property(p => p.IsTwoFactorEnabled)
                .HasDefaultValue(false);

            entity.Property(p => p.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(p => p.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasMany(p => p.Transactions)
                .WithOne(t => t.Player)
                .HasForeignKey(t => t.PlayerId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Конфигурация врага
        modelBuilder.Entity<Enemy>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Name)
                .IsRequired()
                .HasMaxLength(255);

            entity.Property(e => e.MaxHp)
                .HasPrecision(18, 2);

            entity.Property(e => e.CurrentHp)
                .HasPrecision(18, 2);

            entity.Property(e => e.ImageUrl)
                .HasMaxLength(500);

            entity.Property(e => e.IsDefeated)
                .HasDefaultValue(false);

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");
        });

        // Конфигурация транзакции
        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(t => t.Id);

            entity.Property(t => t.Title)
                .IsRequired()
                .HasMaxLength(255);

            entity.Property(t => t.Category)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(t => t.Amount)
                .HasPrecision(18, 2)
                .IsRequired();

            entity.Property(t => t.Type)
                .IsRequired();

            entity.Property(t => t.PlayerId)
                .IsRequired();

            entity.Property(t => t.Date)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(t => t.IconUrl)
                .HasMaxLength(500);

            entity.Property(t => t.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(t => t.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(t => t.Player)
                .WithMany(p => p.Transactions)
                .HasForeignKey(t => t.PlayerId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(t => t.PlayerId);
            entity.HasIndex(t => t.Date).IsDescending();
        });

        // Конфигурация цели сбережения
        modelBuilder.Entity<SavingsGoal>(entity =>
        {
            entity.HasKey(g => g.Id);

            entity.Property(g => g.PlayerId)
                .IsRequired();

            entity.Property(g => g.GoalName)
                .IsRequired()
                .HasMaxLength(255);

            entity.Property(g => g.Description)
                .HasMaxLength(1000);

            entity.Property(g => g.TargetAmount)
                .HasPrecision(18, 2);

            entity.Property(g => g.CurrentAmount)
                .HasPrecision(18, 2);

            entity.Property(g => g.ImageUrl)
                .HasMaxLength(500);

            entity.Property(g => g.IsActive)
                .HasDefaultValue(true);

            entity.Property(g => g.TotalHearts)
                .HasDefaultValue(10);

            entity.Property(g => g.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(g => g.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasIndex(g => g.PlayerId);
        });

        // Конфигурация боя
        modelBuilder.Entity<Battle>(entity =>
        {
            entity.HasKey(b => b.Id);

            entity.Property(b => b.PlayerId)
                .IsRequired();

            entity.Property(b => b.DamageDealt)
                .HasPrecision(18, 2);

            entity.Property(b => b.BattleResult)
                .HasMaxLength(50);

            entity.Property(b => b.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(b => b.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasIndex(b => b.PlayerId);
            entity.HasIndex(b => b.BattleDate).IsDescending();
        });

        // Конфигурация категорий расходов
        modelBuilder.Entity<ExpenseCategory>(entity =>
        {
            entity.HasKey(c => c.Id);

            entity.Property(c => c.PlayerId)
                .IsRequired();

            entity.Property(c => c.Name)
                .IsRequired()
                .HasMaxLength(255);

            entity.Property(c => c.ColorHex)
                .HasMaxLength(7);

            entity.Property(c => c.IconUrl)
                .HasMaxLength(500);

            entity.Property(c => c.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(c => c.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasIndex(c => c.PlayerId);
        });
    }
}
