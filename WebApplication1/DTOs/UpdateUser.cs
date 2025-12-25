using System;
using System.ComponentModel.DataAnnotations;

namespace WebApplication1.DTOs
{
    public class UpdateUserDto
    {
        // نعرّف UserName حتى نستخدمه بدلاً من Email في التحديث/التعرّف على المستخدم
        [StringLength(100)]
        public string? UserName { get; set; }

        // نجعل الاسم الأول والآخر اختياريين في التحديث
        [StringLength(100)]
        public string? FirstName { get; set; }

        [StringLength(100)]
        public string? LastName { get; set; }

        public DateTime? DateOfBirth { get; set; }

        // يمكن إبقاء Email اختياري أو حذفه لاحقاً إذا لم تعد تحتاجه
        [EmailAddress]
        public string? Email { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        // دور ASP.NET Identity (Admin, Coach, Member, ... إلخ)
        public string? RoleName { get; set; }
    }
}
