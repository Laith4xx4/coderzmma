using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication1.Data;

namespace WebApplication1.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PublicController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PublicController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            var sessions = await _context.Sessions.CountAsync();
            var members = await _context.MemberProfiles.CountAsync();
            var coaches = await _context.CoachProfiles.CountAsync();

            return Ok(new
            {
                Sessions = sessions,
                Members = members,
                Coaches = coaches
            });
        }
    }
}
