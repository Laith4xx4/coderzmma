using System;
using System.ComponentModel.DataAnnotations;

namespace WebApplication1.DTOs
{
    public class UserDto
    {
        // التعريف بالمستخدم باسم المستخدم بدلاً من الإيميل
        [Required]
        [StringLength(100)]
        public string UserName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;

        public DateTime? DateOfBirth { get; set; }

        [EmailAddress]
        public string? Email { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        // دور ASP.NET Identity (Admin, Coach, Member, ...)
        public string? RoleName { get; set; }
    }
}
