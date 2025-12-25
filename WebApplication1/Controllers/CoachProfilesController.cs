using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebApplication1.Data;
using WebApplication1.DTOs;
using WebApplication1.Models;

namespace WebApplication1.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // حماية بالـ JWT
    public class CoachProfilesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public CoachProfilesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/CoachProfiles
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CoachProfileResponseDto>>> GetAll()
        {
            var coaches = await _context.CoachProfiles
                .Include(c => c.User)
                .Include(c => c.Sessions)
                .Include(c => c.FeedbacksReceived)
                .ToListAsync();

            return _mapper.Map<List<CoachProfileResponseDto>>(coaches);
        }

        // GET: api/CoachProfiles/me
        [HttpGet("me")]
        public async Task<ActionResult<CoachProfileResponseDto>> GetMyProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var coach = await _context.CoachProfiles
                .Include(c => c.User)
                .Include(c => c.Sessions)
                .Include(c => c.FeedbacksReceived)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (coach == null)
                return NotFound(new { message = "Coach profile not found for current user" });

            return _mapper.Map<CoachProfileResponseDto>(coach);
        }

        // GET: api/CoachProfiles/5
        [HttpGet("{id}")]
        public async Task<ActionResult<CoachProfileResponseDto>> Get(int id)
        {
            var coach = await _context.CoachProfiles
                .Include(c => c.User)
                .Include(c => c.Sessions)
                .Include(c => c.FeedbacksReceived)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (coach == null)
                return NotFound();

            return _mapper.Map<CoachProfileResponseDto>(coach);
        }

        // POST: api/CoachProfiles
        [HttpPost]
        public async Task<ActionResult<CoachProfileResponseDto>> Create(CreateCoachProfileDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var userNameFromToken = User.FindFirstValue(ClaimTypes.Name);

            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            bool isAdmin = User.IsInRole("Admin");

            string targetUserId;
            string targetUserName;

            if (isAdmin && !string.IsNullOrEmpty(dto.UserName))
            {
                // Admin يمكنه تحديد أي مستخدم
                var targetUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.UserName == dto.UserName);

                if (targetUser == null)
                    return BadRequest("User not found.");

                targetUserId = targetUser.Id;
                targetUserName = targetUser.UserName;
            }
            else
            {
                // المستخدم العادي فقط لحسابه
                targetUserId = userId;
                targetUserName = userNameFromToken;
            }

            // منع التكرار
            var exists = await _context.CoachProfiles
                .AnyAsync(c => c.UserId == targetUserId);

            if (exists)
                return BadRequest("Coach profile already exists for this user.");

            var coach = _mapper.Map<CoachProfile>(dto);
            coach.UserId = targetUserId;
            coach.User = await _context.Users.FirstOrDefaultAsync(u => u.Id == targetUserId);

            _context.CoachProfiles.Add(coach);
            await _context.SaveChangesAsync();

            var responseDto = _mapper.Map<CoachProfileResponseDto>(coach);
            return CreatedAtAction(nameof(Get), new { id = coach.Id }, responseDto);
        }

        // PUT: api/CoachProfiles/5
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateCoachProfileDto dto)
        {
            var coach = await _context.CoachProfiles.FindAsync(id);
            if (coach == null)
                return NotFound();

            _mapper.Map(dto, coach);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/CoachProfiles/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var coach = await _context.CoachProfiles.FindAsync(id);
            if (coach == null)
                return NotFound();

            _context.CoachProfiles.Remove(coach);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
