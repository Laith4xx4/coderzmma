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
    public class ClassTypesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public ClassTypesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ClassTypeResponseDto>>> GetAll()
        {
            var classes = await _context.ClassTypes
                .Include(c => c.Sessions)
                .ToListAsync();

            return _mapper.Map<List<ClassTypeResponseDto>>(classes);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ClassTypeResponseDto>> Get(int id)
        {
            var classType = await _context.ClassTypes
                .Include(c => c.Sessions)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (classType == null) return NotFound();
            return _mapper.Map<ClassTypeResponseDto>(classType);
        }

        [HttpPost]
        public async Task<ActionResult<ClassTypeResponseDto>> Create(CreateClassTypeDto dto)
        {
            var classType = _mapper.Map<ClassType>(dto);
            _context.ClassTypes.Add(classType);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(Get), new { id = classType.Id }, _mapper.Map<ClassTypeResponseDto>(classType));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateClassTypeDto dto)
        {
            var classType = await _context.ClassTypes.FindAsync(id);
            if (classType == null) return NotFound();

            _mapper.Map(dto, classType);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var classType = await _context.ClassTypes.FindAsync(id);
            if (classType == null) return NotFound();

            _context.ClassTypes.Remove(classType);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
