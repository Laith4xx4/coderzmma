namespace WebApplication1.Models
{
    public class Feedback
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public int CoachId { get; set; }
        public int SessionId { get; set; }
        public decimal Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime Timestamp { get; set; }

        public MemberProfile Member { get; set; }
        public CoachProfile Coach { get; set; }
        public Session Session { get; set; }
    }
}
