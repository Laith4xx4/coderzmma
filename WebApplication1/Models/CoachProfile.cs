using System.ComponentModel.DataAnnotations;
using WebApplication1.Identity;

namespace WebApplication1.Models
{
    public class CoachProfile
    {
        [Key]
        public int Id { get; set; }
        public string UserId { get; set; }
        public string Bio { get; set; }
        public string Specialization { get; set; }
        public string? Certifications { get; set; }

        public ApplicationUser User { get; set; }
        public ICollection<Session> Sessions { get; set; }
        public ICollection<Feedback> FeedbacksReceived { get; set; }
    }

    
}
