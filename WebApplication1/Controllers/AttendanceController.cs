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
    public class AttendancesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public AttendancesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<AttendanceResponseDto>>> GetAll()
        {
            var attendances = await _context.Attendances
                .Include(a => a.Member)
                    .ThenInclude(m => m.User)
                .Include(a => a.Session)
                .ToListAsync();

            return _mapper.Map<List<AttendanceResponseDto>>(attendances);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AttendanceResponseDto>> Get(int id)
        {
            var attendance = await _context.Attendances
                .Include(a => a.Member)
                    .ThenInclude(m => m.User)
                .Include(a => a.Session)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (attendance == null) return NotFound();
            return _mapper.Map<AttendanceResponseDto>(attendance);
        }

        [HttpPost]
        public async Task<ActionResult<AttendanceResponseDto>> Create(CreateAttendanceDto dto)
        {
            var attendance = _mapper.Map<Attendance>(dto);
            _context.Attendances.Add(attendance);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(Get), new { id = attendance.Id }, _mapper.Map<AttendanceResponseDto>(attendance));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateAttendanceDto dto)
        {
            var attendance = await _context.Attendances.FindAsync(id);
            if (attendance == null) return NotFound();

            _mapper.Map(dto, attendance);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var attendance = await _context.Attendances.FindAsync(id);
            if (attendance == null) return NotFound();

            _context.Attendances.Remove(attendance);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
