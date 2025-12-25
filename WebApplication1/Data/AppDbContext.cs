using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WebApplication1.Identity;
using WebApplication1.Models;

namespace WebApplication1.Data
{
    public class AppDbContext : IdentityDbContext<ApplicationUser>
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<MemberProfile> MemberProfiles { get; set; }
        public DbSet<CoachProfile> CoachProfiles { get; set; }
        public DbSet<ClassType> ClassTypes { get; set; }
        public DbSet<Session> Sessions { get; set; }
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<Attendance> Attendances { get; set; }
        public DbSet<Feedback> Feedbacks { get; set; }
        public DbSet<MemberSetProgress> MemberSetProgresses { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // MemberProfile ↔ ApplicationUser
            builder.Entity<MemberProfile>()
                .HasOne(m => m.User)
                .WithOne()
                .HasForeignKey<MemberProfile>(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // CoachProfile ↔ ApplicationUser
            builder.Entity<CoachProfile>()
                .HasOne(c => c.User)
                .WithOne()
                .HasForeignKey<CoachProfile>(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Booking
            builder.Entity<Booking>()
                .HasOne(b => b.Member)
                .WithMany(m => m.Bookings)
                .HasForeignKey(b => b.MemberId)
                .OnDelete(DeleteBehavior.Restrict); // منع multiple cascade paths

            builder.Entity<Booking>()
                .HasOne(b => b.Session)
                .WithMany(s => s.Bookings)
                .HasForeignKey(b => b.SessionId)
                .OnDelete(DeleteBehavior.Restrict); // منع multiple cascade paths

            // Attendance
            builder.Entity<Attendance>()
                .HasOne(a => a.Member)
                .WithMany(m => m.Attendances)
                .HasForeignKey(a => a.MemberId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<Attendance>()
                .HasOne(a => a.Session)
                .WithMany(s => s.Attendances)
                .HasForeignKey(a => a.SessionId)
                .OnDelete(DeleteBehavior.Restrict);

            // Feedback
            builder.Entity<Feedback>()
                .HasOne(f => f.Member)
                .WithMany(m => m.FeedbacksGiven)
                .HasForeignKey(f => f.MemberId)
                .OnDelete(DeleteBehavior.Restrict); // منع multiple cascade paths

            builder.Entity<Feedback>()
                .HasOne(f => f.Coach)
                .WithMany(c => c.FeedbacksReceived)
                .HasForeignKey(f => f.CoachId)
                .OnDelete(DeleteBehavior.Restrict); // منع multiple cascade paths

            builder.Entity<Feedback>()
                .HasOne(f => f.Session)
                .WithMany()
                .HasForeignKey(f => f.SessionId)
                .OnDelete(DeleteBehavior.Restrict);

            // MemberSetProgress
            builder.Entity<MemberSetProgress>()
                .HasOne(p => p.Member)
                .WithMany(m => m.ProgressRecords)
                .HasForeignKey(p => p.MemberId)
                .OnDelete(DeleteBehavior.Cascade);

            // CoachProfile ↔ Sessions
            builder.Entity<Session>()
                .HasOne(s => s.Coach)
                .WithMany(c => c.Sessions)
                .HasForeignKey(s => s.CoachId)
                .OnDelete(DeleteBehavior.Restrict);

            // ClassType ↔ Sessions
            builder.Entity<Session>()
                .HasOne(s => s.ClassType)
                .WithMany(ct => ct.Sessions)
                .HasForeignKey(s => s.ClassTypeId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
