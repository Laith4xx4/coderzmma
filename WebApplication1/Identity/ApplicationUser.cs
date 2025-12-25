using Microsoft.AspNetCore.Identity;
using WebApplication1.Models;
using System;
using System.Collections.Generic;

namespace WebApplication1.Identity
{
    public class ApplicationUser : IdentityUser
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateTime? DateOfBirth { get; set; }

        // ✅ الآن الدور كسلسلة نصية
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;

      
    }
}
