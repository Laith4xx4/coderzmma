using System;
using System.ComponentModel.DataAnnotations;

namespace WebApplication1.DTOs
{
    public class RegisterDto
    {
        [Required]
        [StringLength(30, MinimumLength = 3)]
        public string UserName { get; set; }

        public string? Role { get; set; }   

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        public string? FirstName { get; set; }
        public string? LastName { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        public DateTime? DateOfBirth { get; set; }
    }
}