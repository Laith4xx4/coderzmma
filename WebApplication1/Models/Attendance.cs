using System.ComponentModel.DataAnnotations.Schema;
using WebApplication1.Models;

public class Attendance
{
    public int Id { get; set; }

    [ForeignKey("Session")]
    public int SessionId { get; set; }

    [ForeignKey("Member")]
    public int MemberId { get; set; }

    public AttendanceStatus Status { get; set; }

    public Session Session { get; set; }
    public MemberProfile Member { get; set; }
}
