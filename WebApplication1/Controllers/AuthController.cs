using Microsoft.AspNetCore.Mvc;
using WebApplication1.DTOs;

namespace WebApplication1.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        // -----------------------------
        // Register User
        // -----------------------------
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            try
            {
                var userId = await _authService.RegisterAsync(model);
                return Ok(new { Message = "User registered successfully!", UserId = userId });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // -----------------------------
        // Login User
        // -----------------------------
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            try
            {
                var token = await _authService.LoginAsync(model); // لاحقًا يمكن تعديل Login لإرجاع JWT
                return Ok(new { Token = token });
            }
            catch (Exception ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }
    }
}
