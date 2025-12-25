namespace WebApplication1.Models
{
    public class MemberSetProgress
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public DateTime Date { get; set; }
        public int SetsCompleted { get; set; }
        public DateTime? PromotionDate { get; set; }

        public MemberProfile Member { get; set; }
    }
}
