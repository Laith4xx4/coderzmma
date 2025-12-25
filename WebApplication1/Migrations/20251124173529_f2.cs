using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApplication1.Migrations
{
    /// <inheritdoc />
    public partial class f2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TechnicianRoleId",
                table: "ServiceRequests",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_TechnicianRoleId",
                table: "ServiceRequests",
                column: "TechnicianRoleId");

            migrationBuilder.AddForeignKey(
                name: "FK_ServiceRequests_TechnicianRoles_TechnicianRoleId",
                table: "ServiceRequests",
                column: "TechnicianRoleId",
                principalTable: "TechnicianRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ServiceRequests_TechnicianRoles_TechnicianRoleId",
                table: "ServiceRequests");

            migrationBuilder.DropIndex(
                name: "IX_ServiceRequests_TechnicianRoleId",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "TechnicianRoleId",
                table: "ServiceRequests");
        }
    }
}
