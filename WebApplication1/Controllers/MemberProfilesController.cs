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
    public class MemberProfilesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public MemberProfilesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/MemberProfiles
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MemberProfileResponseDto>>> GetAll()
        {
            var members = await _context.MemberProfiles
                .Include(m => m.User)
                .Include(m => m.Bookings)
                .Include(m => m.Attendances)
                .Include(m => m.FeedbacksGiven)
                .Include(m => m.ProgressRecords)
                .ToListAsync();

            return _mapper.Map<List<MemberProfileResponseDto>>(members);
        }

        // GET: api/MemberProfiles/me
        [HttpGet("me")]
        public async Task<ActionResult<MemberProfileResponseDto>> GetMyProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var member = await _context.MemberProfiles
                .Include(m => m.User)
                .Include(m => m.Bookings)
                .Include(m => m.Attendances)
                .Include(m => m.FeedbacksGiven)
                .Include(m => m.ProgressRecords)
                .FirstOrDefaultAsync(m => m.UserId == userId);

            if (member == null)
                return NotFound(new { message = "Member profile not found for current user" });

            return _mapper.Map<MemberProfileResponseDto>(member);
        }

        // GET: api/MemberProfiles/5
        [HttpGet("{id}")]
        public async Task<ActionResult<MemberProfileResponseDto>> Get(int id)
        {
            var member = await _context.MemberProfiles
                .Include(m => m.User)
                .Include(m => m.Bookings)
                .Include(m => m.Attendances)
                .Include(m => m.FeedbacksGiven)
                .Include(m => m.ProgressRecords)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (member == null)
                return NotFound();

            return _mapper.Map<MemberProfileResponseDto>(member);
        }

        // POST: api/MemberProfiles
        [HttpPost]
        public async Task<ActionResult<MemberProfileResponseDto>> Create(CreateMemberProfileDto dto)
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
                // Admin يحدد username
                var targetUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.UserName == dto.UserName);

                if (targetUser == null)
                    return BadRequest("User not found.");

                targetUserId = targetUser.Id;
                targetUserName = targetUser.UserName;
            }
            else
            {
                // المستخدم العادي ينشئ فقط لحسابه
                targetUserId = userId;
                targetUserName = userNameFromToken;
            }

            // منع التكرار
            var exists = await _context.MemberProfiles
                .AnyAsync(m => m.UserId == targetUserId);

            if (exists)
                return BadRequest("Member profile already exists for this user.");

            var member = _mapper.Map<MemberProfile>(dto);
            member.UserId = targetUserId;
            member.User = await _context.Users.FirstOrDefaultAsync(u => u.Id == targetUserId);

            _context.MemberProfiles.Add(member);
            await _context.SaveChangesAsync();

            var responseDto = _mapper.Map<MemberProfileResponseDto>(member);
            return CreatedAtAction(nameof(Get), new { id = member.Id }, responseDto);
        }

        // PUT: api/MemberProfiles/5
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateMemberProfileDto dto)
        {
            var member = await _context.MemberProfiles.FindAsync(id);
            if (member == null)
                return NotFound();

            _mapper.Map(dto, member);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/MemberProfiles/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var member = await _context.MemberProfiles.FindAsync(id);
            if (member == null)
                return NotFound();

            _context.MemberProfiles.Remove(member);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
