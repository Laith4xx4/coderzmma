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
    public class FeedbacksController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public FeedbacksController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<FeedbackResponseDto>>> GetAll()
        {
            var feedbacks = await _context.Feedbacks
                .Include(f => f.Member)
                    .ThenInclude(m => m.User)
                .Include(f => f.Coach)
                    .ThenInclude(c => c.User)
                .Include(f => f.Session)
                .ToListAsync();

            return _mapper.Map<List<FeedbackResponseDto>>(feedbacks);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<FeedbackResponseDto>> Get(int id)
        {
            var feedback = await _context.Feedbacks
                .Include(f => f.Member)
                    .ThenInclude(m => m.User)
                .Include(f => f.Coach)
                    .ThenInclude(c => c.User)
                .Include(f => f.Session)
                .FirstOrDefaultAsync(f => f.Id == id);

            if (feedback == null) return NotFound();
            return _mapper.Map<FeedbackResponseDto>(feedback);
        }

        [HttpPost]
        public async Task<ActionResult<FeedbackResponseDto>> Create(CreateFeedbackDto dto)
        {
            var feedback = _mapper.Map<Feedback>(dto);
            _context.Feedbacks.Add(feedback);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(Get), new { id = feedback.Id }, _mapper.Map<FeedbackResponseDto>(feedback));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateFeedbackDto dto)
        {
            var feedback = await _context.Feedbacks.FindAsync(id);
            if (feedback == null) return NotFound();

            _mapper.Map(dto, feedback);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var feedback = await _context.Feedbacks.FindAsync(id);
            if (feedback == null) return NotFound();

            _context.Feedbacks.Remove(feedback);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
