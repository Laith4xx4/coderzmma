namespace WebApplication1.Models
{
    public class Session
    {
        public int Id { get; set; }
        public int CoachId { get; set; }
        public int ClassTypeId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public int Capacity { get; set; }
        public string? Description { get; set; }
        public string SessionName { get; set; } = string.Empty;  // تم إضافته

        public CoachProfile Coach { get; set; } = null!;
        public ClassType ClassType { get; set; } = null!;
        public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
        public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    }
}
