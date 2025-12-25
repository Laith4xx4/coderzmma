using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApplication1.Migrations
{
    /// <inheritdoc />
    public partial class q3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_TechnicianRole_TechnicianRoleId",
                table: "AspNetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TechnicianRole",
                table: "TechnicianRole");

            migrationBuilder.RenameTable(
                name: "TechnicianRole",
                newName: "TechnicianRoles");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TechnicianRoles",
                table: "TechnicianRoles",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_TechnicianRoles_TechnicianRoleId",
                table: "AspNetUsers",
                column: "TechnicianRoleId",
                principalTable: "TechnicianRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_TechnicianRoles_TechnicianRoleId",
                table: "AspNetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TechnicianRoles",
                table: "TechnicianRoles");

            migrationBuilder.RenameTable(
                name: "TechnicianRoles",
                newName: "TechnicianRole");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TechnicianRole",
                table: "TechnicianRole",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_TechnicianRole_TechnicianRoleId",
                table: "AspNetUsers",
                column: "TechnicianRoleId",
                principalTable: "TechnicianRole",
                principalColumn: "Id");
        }
    }
}
