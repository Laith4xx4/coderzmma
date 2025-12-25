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
    public class BookingsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public BookingsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetAll()
        {
            var bookings = await _context.Bookings
                .Include(b => b.Member)
                    .ThenInclude(m => m.User)
                .Include(b => b.Session)
                .ToListAsync();

            return _mapper.Map<List<BookingResponseDto>>(bookings);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BookingResponseDto>> Get(int id)
        {
            var booking = await _context.Bookings
                .Include(b => b.Member)
                    .ThenInclude(m => m.User)
                .Include(b => b.Session)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (booking == null) return NotFound();
            return _mapper.Map<BookingResponseDto>(booking);
        }

        [HttpPost]
        public async Task<ActionResult<BookingResponseDto>> Create(CreateBookingDto dto)
        {
            var booking = _mapper.Map<Booking>(dto);
            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(Get), new { id = booking.Id }, _mapper.Map<BookingResponseDto>(booking));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateBookingDto dto)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound();

            _mapper.Map(dto, booking);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound();

            _context.Bookings.Remove(booking);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
