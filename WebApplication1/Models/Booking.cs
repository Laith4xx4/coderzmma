namespace WebApplication1.Models
{

    
    public class Booking
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public int MemberId { get; set; }
        public DateTime BookingTime { get; set; }
        public BookingStatus Status { get; set; }

        public Session Session { get; set; }
        public MemberProfile Member { get; set; }
    }
}
