using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication1.Data;
using WebApplication1.DTOs;
using WebApplication1.Models;

namespace WebApplication1.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SessionsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public SessionsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<SessionResponseDto>>> GetAll()
        {
            var sessions = await _context.Sessions
                .Include(s => s.Coach)
                    .ThenInclude(c => c.User)
                .Include(s => s.ClassType)
                .Include(s => s.Bookings)
                .Include(s => s.Attendances)
                .ToListAsync();

            return _mapper.Map<List<SessionResponseDto>>(sessions);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SessionResponseDto>> Get(int id)
        {
            var session = await _context.Sessions
                .Include(s => s.Coach)
                    .ThenInclude(c => c.User)
                .Include(s => s.ClassType)
                .Include(s => s.Bookings)
                .Include(s => s.Attendances)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (session == null) return NotFound();
            return _mapper.Map<SessionResponseDto>(session);
        }

        [HttpPost]
        public async Task<ActionResult<SessionResponseDto>> Create(CreateSessionDto dto)
        {
            var session = _mapper.Map<Session>(dto);
            _context.Sessions.Add(session);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(Get), new { id = session.Id }, _mapper.Map<SessionResponseDto>(session));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateSessionDto dto)
        {
            var session = await _context.Sessions.FindAsync(id);
            if (session == null) return NotFound();

            _mapper.Map(dto, session);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var session = await _context.Sessions.FindAsync(id);
            if (session == null) return NotFound();

            _context.Sessions.Remove(session);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
