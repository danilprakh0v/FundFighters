/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: BaseEntity.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Абстрактный базовый класс для всех сущностей предметной области.
            Предоставляет общие поля идентификации и временные метки аудита.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Абстрактный базовый класс для всех сущностей предметной области.
/// Предоставляет общие поля идентификации и временные метки аудита.
/// 
/// Abstract base class for all domain model entities.
/// Provides common identity and audit timestamp fields.
/// </summary>
public abstract class BaseEntity
{
    /// <summary>
    /// Первичный ключ - уникальный идентификатор сущности.
    /// Primary key - unique entity identifier.
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Временная метка создания сущности (автоматически устанавливается БД).
    /// Creation timestamp (automatically set by database).
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Временная метка последнего обновления (автоматически устанавливается БД).
    /// Last update timestamp (automatically set by database).
    /// </summary>
    public DateTime UpdatedAt { get; set; }
}
