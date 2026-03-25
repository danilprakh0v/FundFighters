/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ApplicationAssemblyMarker.cs
Расположение: FundFighters.Backend.Application/
Назначение: Маркер класса, используемый для сканирования сборки в конфигурации внедрения зависимостей.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.Application;

/// <summary>
/// Маркер класса, используемый для сканирования сборки в конфигурации внедрения зависимостей.
/// Используется MediatR для регистрации всех обработчиков в сборке Application.
/// 
/// Marker class used for assembly scanning in dependency injection configuration.
/// This is used by MediatR to register all handlers in the Application assembly.
/// </summary>
public sealed class ApplicationAssemblyMarker
{
}
