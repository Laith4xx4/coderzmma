using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApplication1.Migrations
{
    /// <inheritdoc />
    public partial class z1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_ApplicationUserId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_TechnicianRoles_TechnicianRoleId",
                table: "AspNetUsers");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "ServiceRequests");

            migrationBuilder.DropTable(
                name: "TechnicianRoles");

            migrationBuilder.DropIndex(
                name: "IX_AspNetUsers_TechnicianRoleId",
                table: "AspNetUsers");

            migrationBuilder.DropIndex(
                name: "IX_AspNetUserRoles_ApplicationUserId",
                table: "AspNetUserRoles");

            migrationBuilder.DropColumn(
                name: "TechnicianRoleId",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                table: "AspNetUserRoles");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "AspNetUsers",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "Role",
                table: "AspNetUsers",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "ClassTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClassTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CoachProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Bio = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Specialization = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Certifications = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CoachProfiles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CoachProfiles_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MemberProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    FirstName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LastName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    EmergencyContactName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    EmergencyContactPhone = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    MedicalInfo = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    JoinDate = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberProfiles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MemberProfiles_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Sessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CoachId = table.Column<int>(type: "int", nullable: false),
                    ClassTypeId = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Capacity = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Sessions_ClassTypes_ClassTypeId",
                        column: x => x.ClassTypeId,
                        principalTable: "ClassTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Sessions_CoachProfiles_CoachId",
                        column: x => x.CoachId,
                        principalTable: "CoachProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MemberSetProgresses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MemberId = table.Column<int>(type: "int", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    SetsCompleted = table.Column<int>(type: "int", nullable: false),
                    PromotionDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberSetProgresses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MemberSetProgresses_MemberProfiles_MemberId",
                        column: x => x.MemberId,
                        principalTable: "MemberProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Attendances",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SessionId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Attendances", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Attendances_MemberProfiles_MemberId",
                        column: x => x.MemberId,
                        principalTable: "MemberProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Attendances_Sessions_SessionId",
                        column: x => x.SessionId,
                        principalTable: "Sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Bookings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SessionId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<int>(type: "int", nullable: false),
                    BookingTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bookings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Bookings_MemberProfiles_MemberId",
                        column: x => x.MemberId,
                        principalTable: "MemberProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bookings_Sessions_SessionId",
                        column: x => x.SessionId,
                        principalTable: "Sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Feedbacks",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MemberId = table.Column<int>(type: "int", nullable: false),
                    CoachId = table.Column<int>(type: "int", nullable: false),
                    SessionId = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Comments = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Timestamp = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Feedbacks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Feedbacks_CoachProfiles_CoachId",
                        column: x => x.CoachId,
                        principalTable: "CoachProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Feedbacks_MemberProfiles_MemberId",
                        column: x => x.MemberId,
                        principalTable: "MemberProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Feedbacks_Sessions_SessionId",
                        column: x => x.SessionId,
                        principalTable: "Sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Attendances_MemberId",
                table: "Attendances",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Attendances_SessionId",
                table: "Attendances",
                column: "SessionId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_MemberId",
                table: "Bookings",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_SessionId",
                table: "Bookings",
                column: "SessionId");

            migrationBuilder.CreateIndex(
                name: "IX_CoachProfiles_UserId",
                table: "CoachProfiles",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Feedbacks_CoachId",
                table: "Feedbacks",
                column: "CoachId");

            migrationBuilder.CreateIndex(
                name: "IX_Feedbacks_MemberId",
                table: "Feedbacks",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Feedbacks_SessionId",
                table: "Feedbacks",
                column: "SessionId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberProfiles_UserId",
                table: "MemberProfiles",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MemberSetProgresses_MemberId",
                table: "MemberSetProgresses",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Sessions_ClassTypeId",
                table: "Sessions",
                column: "ClassTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_Sessions_CoachId",
                table: "Sessions",
                column: "CoachId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Attendances");

            migrationBuilder.DropTable(
                name: "Bookings");

            migrationBuilder.DropTable(
                name: "Feedbacks");

            migrationBuilder.DropTable(
                name: "MemberSetProgresses");

            migrationBuilder.DropTable(
                name: "Sessions");

            migrationBuilder.DropTable(
                name: "MemberProfiles");

            migrationBuilder.DropTable(
                name: "ClassTypes");

            migrationBuilder.DropTable(
                name: "CoachProfiles");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "Role",
                table: "AspNetUsers");

            migrationBuilder.AddColumn<int>(
                name: "TechnicianRoleId",
                table: "AspNetUsers",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ApplicationUserId",
                table: "AspNetUserRoles",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TechnicianId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Rating = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_AspNetUsers_TechnicianId",
                        column: x => x.TechnicianId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reviews_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TechnicianRoles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleName = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechnicianRoles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ServiceRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TechnicianId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    TechnicianRoleId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsCompleted = table.Column<bool>(type: "bit", nullable: false),
                    Location = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Rating = table.Column<int>(type: "int", nullable: true),
                    ServiceType = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ServiceRequests_AspNetUsers_TechnicianId",
                        column: x => x.TechnicianId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_ServiceRequests_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ServiceRequests_TechnicianRoles_TechnicianRoleId",
                        column: x => x.TechnicianRoleId,
                        principalTable: "TechnicianRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_TechnicianRoleId",
                table: "AspNetUsers",
                column: "TechnicianRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_ApplicationUserId",
                table: "AspNetUserRoles",
                column: "ApplicationUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_TechnicianId",
                table: "Reviews",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId",
                table: "Reviews",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_TechnicianId",
                table: "ServiceRequests",
                column: "TechnicianId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_TechnicianRoleId",
                table: "ServiceRequests",
                column: "TechnicianRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_UserId",
                table: "ServiceRequests",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_ApplicationUserId",
                table: "AspNetUserRoles",
                column: "ApplicationUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_TechnicianRoles_TechnicianRoleId",
                table: "AspNetUsers",
                column: "TechnicianRoleId",
                principalTable: "TechnicianRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
