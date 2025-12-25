using System;
using WebApplication1.Models;

namespace WebApplication1.DTOs
{
    // ---------------- CoachProfile DTOs ----------------
    public class CreateCoachProfileDto
    {
        public string UserName { get; set; } = string.Empty;
        public string Bio { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public string? Certifications { get; set; }
    }

    public class UpdateCoachProfileDto
    {
        public string? Bio { get; set; }
        public string? Specialization { get; set; }
        public string? Certifications { get; set; }
    }

    public class CoachProfileResponseDto
    {
        public int Id { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Bio { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public string? Certifications { get; set; }
        public int SessionsCount { get; set; }
        public int FeedbacksCount { get; set; }
    }

    // ---------------- Session DTOs ----------------
    public class CreateSessionDto
    {
        public int CoachId { get; set; }
        public int ClassTypeId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public int Capacity { get; set; }
        public string? Description { get; set; }
        public string SessionName { get; set; } = string.Empty;  // تم إضافته
    }

    public class UpdateSessionDto
    {
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public int? Capacity { get; set; }
        public string? Description { get; set; }
        public string? SessionName { get; set; }  // تم إضافته
    }

    public class SessionResponseDto
    {
        public int Id { get; set; }
        public int CoachId { get; set; }
        public string CoachName { get; set; } = string.Empty;
        public int ClassTypeId { get; set; }
        public string ClassTypeName { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public int Capacity { get; set; }
        public string? Description { get; set; }
        public string SessionName { get; set; } = string.Empty;  // تم إضافته
        public int BookingsCount { get; set; }
        public int AttendanceCount { get; set; }
    }

    // ---------------- MemberSetProgress DTOs ----------------
    public class CreateMemberSetProgressDto
    {
        public int MemberId { get; set; }
        public DateTime Date { get; set; }
        public int SetsCompleted { get; set; }
        public DateTime? PromotionDate { get; set; }
    }

    public class UpdateMemberSetProgressDto
    {
        public int? SetsCompleted { get; set; }
        public DateTime? PromotionDate { get; set; }
    }

    public class MemberSetProgressResponseDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public int SetsCompleted { get; set; }
        public DateTime? PromotionDate { get; set; }
    }

    // ---------------- Feedback DTOs ----------------
    public class CreateFeedbackDto
    {
        public int MemberId { get; set; }
        public int CoachId { get; set; }
        public int SessionId { get; set; }
        public decimal Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    public class UpdateFeedbackDto
    {
        public decimal? Rating { get; set; }
        public string? Comments { get; set; }
    }

    public class FeedbackResponseDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; } = string.Empty;
        public int CoachId { get; set; }
        public string CoachName { get; set; } = string.Empty;
        public int SessionId { get; set; }
        public string SessionName { get; set; } = string.Empty;
        public decimal Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime Timestamp { get; set; }
    }
    // ---------------- MemberProfile DTOs ----------------
    public class CreateMemberProfileDto
    {
        // كان UserId، الآن نستخدم UserName
        public string UserName { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EmergencyContactName { get; set; }
        public string? EmergencyContactPhone { get; set; }
        public string? MedicalInfo { get; set; }
        public DateTime JoinDate { get; set; }
    }

    public class UpdateMemberProfileDto
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EmergencyContactName { get; set; }
        public string? EmergencyContactPhone { get; set; }
        public string? MedicalInfo { get; set; }
    }

    public class MemberProfileResponseDto
    {
        public int Id { get; set; }
        // نعرض UserName فقط
        public string UserName { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EmergencyContactName { get; set; }
        public string? EmergencyContactPhone { get; set; }
        public string? MedicalInfo { get; set; }
        public DateTime JoinDate { get; set; }
        public int BookingsCount { get; set; }
        public int AttendanceCount { get; set; }
        public int FeedbacksGivenCount { get; set; }
        public int ProgressRecordsCount { get; set; }
    }

    // ---------------- ClassType DTOs ----------------
    public class CreateClassTypeDto
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
    }

    public class UpdateClassTypeDto
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
    }

    public class ClassTypeResponseDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
        public int SessionsCount { get; set; }
    }

    // ---------------- Booking DTOs ----------------
    public class CreateBookingDto
    {
        public int SessionId { get; set; }
        public int MemberId { get; set; }
        public DateTime BookingTime { get; set; }
        public BookingStatus Status { get; set; }
    }

    public class UpdateBookingDto
    {
        public BookingStatus Status { get; set; }
    }

    public class BookingResponseDto
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public string SessionName { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public DateTime BookingTime { get; set; }
        public BookingStatus Status { get; set; }
    }

    // ---------------- Attendance DTOs ----------------
    public class CreateAttendanceDto
    {
        public int SessionId { get; set; }
        public int MemberId { get; set; }
        public AttendanceStatus Status { get; set; }
    }

    public class UpdateAttendanceDto
    {
        public AttendanceStatus Status { get; set; }
    }

    public class AttendanceResponseDto
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public string SessionName { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public AttendanceStatus Status { get; set; }
    }
}