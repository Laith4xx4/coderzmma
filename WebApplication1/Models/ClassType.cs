namespace WebApplication1.Models
{
    public class ClassType
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }

        public ICollection<Session> Sessions { get; set; }
    }
}
