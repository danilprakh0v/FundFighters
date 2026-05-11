using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace FundFighters.Backend.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FinalFixMapping : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_EnemyGoals_Players_PlayerId",
                table: "EnemyGoals");

            migrationBuilder.DropColumn(
                name: "CurrentSavedAmount",
                table: "EnemyGoals");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "EnemyGoals",
                newName: "GoalName");

            migrationBuilder.AlterColumn<string>(
                name: "PlayerId",
                table: "EnemyGoals",
                type: "text",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "ImageUrl",
                table: "EnemyGoals",
                type: "character varying(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "character varying(1000)",
                oldMaxLength: 1000,
                oldNullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedDate",
                table: "EnemyGoals",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "CurrentAmount",
                table: "EnemyGoals",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "DefeatedHearts",
                table: "EnemyGoals",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "EnemyGoals",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "EnemyGoals",
                type: "boolean",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<int>(
                name: "TotalHearts",
                table: "EnemyGoals",
                type: "integer",
                nullable: false,
                defaultValue: 10);

            migrationBuilder.CreateTable(
                name: "Battles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    PlayerId = table.Column<string>(type: "text", nullable: false),
                    SavingsGoalId = table.Column<string>(type: "text", nullable: false),
                    DamageDealt = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    XpGained = table.Column<long>(type: "bigint", nullable: false),
                    BattleResult = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    BattleDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Battles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ExpenseCategories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    PlayerId = table.Column<string>(type: "text", nullable: false),
                    Name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    ColorHex = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: false),
                    IconUrl = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExpenseCategories", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Battles_BattleDate",
                table: "Battles",
                column: "BattleDate",
                descending: new bool[0]);

            migrationBuilder.CreateIndex(
                name: "IX_Battles_PlayerId",
                table: "Battles",
                column: "PlayerId");

            migrationBuilder.CreateIndex(
                name: "IX_ExpenseCategories_PlayerId",
                table: "ExpenseCategories",
                column: "PlayerId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Battles");

            migrationBuilder.DropTable(
                name: "ExpenseCategories");

            migrationBuilder.DropColumn(
                name: "CompletedDate",
                table: "EnemyGoals");

            migrationBuilder.DropColumn(
                name: "CurrentAmount",
                table: "EnemyGoals");

            migrationBuilder.DropColumn(
                name: "DefeatedHearts",
                table: "EnemyGoals");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "EnemyGoals");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "EnemyGoals");

            migrationBuilder.DropColumn(
                name: "TotalHearts",
                table: "EnemyGoals");

            migrationBuilder.RenameColumn(
                name: "GoalName",
                table: "EnemyGoals",
                newName: "Name");

            migrationBuilder.AlterColumn<int>(
                name: "PlayerId",
                table: "EnemyGoals",
                type: "integer",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "ImageUrl",
                table: "EnemyGoals",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(500)",
                oldMaxLength: 500);

            migrationBuilder.AddColumn<decimal>(
                name: "CurrentSavedAmount",
                table: "EnemyGoals",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddForeignKey(
                name: "FK_EnemyGoals_Players_PlayerId",
                table: "EnemyGoals",
                column: "PlayerId",
                principalTable: "Players",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
