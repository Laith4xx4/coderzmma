using WebApplication1.Identity;

namespace WebApplication1.Models
{
    public class MemberProfile
    {
        public int Id { get; set; }
        public string UserId { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EmergencyContactName { get; set; }
        public string? EmergencyContactPhone { get; set; }
        public string? MedicalInfo { get; set; }
        public DateTime JoinDate { get; set; }

        public ApplicationUser User { get; set; }
        public ICollection<Booking> Bookings { get; set; }
        public ICollection<Attendance> Attendances { get; set; }
        public ICollection<Feedback> FeedbacksGiven { get; set; }
        public ICollection<MemberSetProgress> ProgressRecords { get; set; }
    }
}
