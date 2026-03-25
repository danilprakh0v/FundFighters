/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: 20260201195023_AddTwoFactorEnabledToPlayer.cs
Расположение: FundFighters.Backend.Infrastructure/Migrations/
Назначение: Основные компоненты логики приложения.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

﻿using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FundFighters.Backend.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddTwoFactorEnabledToPlayer : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsTwoFactorEnabled",
                table: "Players",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "TwoFactorCode",
                table: "Players",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsTwoFactorEnabled",
                table: "Players");

            migrationBuilder.DropColumn(
                name: "TwoFactorCode",
                table: "Players");
        }
    }
}
