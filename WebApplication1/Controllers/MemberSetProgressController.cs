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
    public class MemberSetProgressController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public MemberSetProgressController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/MemberSetProgress
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MemberSetProgressResponseDto>>> GetAll()
        {
            var progresses = await _context.MemberSetProgresses
                .Include(p => p.Member)
                    .ThenInclude(m => m.User)
                .ToListAsync();

            return _mapper.Map<List<MemberSetProgressResponseDto>>(progresses);
        }

        // GET: api/MemberSetProgress/5
        [HttpGet("{id}")]
        public async Task<ActionResult<MemberSetProgressResponseDto>> Get(int id)
        {
            var progress = await _context.MemberSetProgresses
                .Include(p => p.Member)
                    .ThenInclude(m => m.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (progress == null) return NotFound();

            return _mapper.Map<MemberSetProgressResponseDto>(progress);
        }

        // POST: api/MemberSetProgress
        [HttpPost]
        public async Task<ActionResult<MemberSetProgressResponseDto>> Create(CreateMemberSetProgressDto dto)
        {
            // التحقق من وجود العضو
            var member = await _context.MemberProfiles
                .Include(m => m.User)
                .FirstOrDefaultAsync(m => m.Id == dto.MemberId);

            if (member == null) return BadRequest("Member not found");

            // تحويل DTO إلى كائن MemberSetProgress وربطه بالعضو
            var progress = _mapper.Map<MemberSetProgress>(dto);
            progress.Member = member;

            _context.MemberSetProgresses.Add(progress);
            await _context.SaveChangesAsync();

            var responseDto = _mapper.Map<MemberSetProgressResponseDto>(progress);
            responseDto.MemberName = member.User.UserName; // التأكد من اسم العضو

            return CreatedAtAction(nameof(Get), new { id = progress.Id }, responseDto);
        }

        // PUT: api/MemberSetProgress/5
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateMemberSetProgressDto dto)
        {
            var progress = await _context.MemberSetProgresses
                .Include(p => p.Member)
                    .ThenInclude(m => m.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (progress == null) return NotFound();

            _mapper.Map(dto, progress);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/MemberSetProgress/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var progress = await _context.MemberSetProgresses.FindAsync(id);
            if (progress == null) return NotFound();

            _context.MemberSetProgresses.Remove(progress);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
