using System;
using System.ComponentModel.DataAnnotations;

namespace WebApplication1.DTOs
{
    public class CreateUserDto
    {
        // نضيف UserName لأنه سيكون الأساس بدلاً من الإيميل
        [Required]
        [StringLength(100)]
        public string UserName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Phone]
        public string? PhoneNumber { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [Required]
        [StringLength(100, MinimumLength = 6)]
        public string Password { get; set; } = string.Empty;

        // ممكن تستغله لاحقاً لو عندك نظام أدوار فني داخلي
        public int? TechnicianRoleId { get; set; }

        // دور ASP.NET Identity (Admin, Coach, Member, ...)
        public string? RoleName { get; set; }
    }
}
