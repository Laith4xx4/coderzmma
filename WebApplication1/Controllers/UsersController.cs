using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebApplication1.Data;
using WebApplication1.DTOs;
using WebApplication1.Identity;

namespace WebApplication1.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly AppDbContext _context;

        public UsersController(
            UserManager<ApplicationUser> userManager,
            RoleManager<IdentityRole> roleManager,
            AppDbContext context)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _context = context;
        }

        // Helper: Get current user from JWT (Id من الـ token)
        private async Task<ApplicationUser?> GetUserFromToken()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return null;

            return await _userManager.FindByIdAsync(userId);
        }

        // GET: api/users/me
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var user = await GetUserFromToken();
            if (user == null)
                return Unauthorized(new { message = "Invalid or expired token." });

            var roles = await _userManager.GetRolesAsync(user);
            var role = roles.FirstOrDefault() ?? "User";

            return Ok(new
            {
                user.Id,
                user.UserName,
                user.Email,
                user.PhoneNumber,
                user.FirstName,
                user.LastName,
                user.DateOfBirth,
                Role = role
            });
        }

        // PUT: api/users/me  (المستخدم يحدّث نفسه – بدون تغيير Email أو Role غالباً)
        [HttpPut("me")]
        public async Task<IActionResult> UpdateCurrentUser([FromBody] UpdateUserDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await GetUserFromToken();
            if (user == null)
                return Unauthorized(new { message = "User not found." });

            if (!string.IsNullOrWhiteSpace(model.FirstName))
                user.FirstName = model.FirstName;

            if (!string.IsNullOrWhiteSpace(model.LastName))
                user.LastName = model.LastName;

            if (model.DateOfBirth.HasValue)
                user.DateOfBirth = model.DateOfBirth.Value;

            if (!string.IsNullOrWhiteSpace(model.PhoneNumber))
                user.PhoneNumber = model.PhoneNumber;

            // ⚠️ لا نغيّر الـ Email هنا لتجنّب DuplicateEmail
            // يمكن تركه ثابتاً أو عمل Endpoint خاص لتغيير الإيميل مع تحقق إضافي
            // if (!string.IsNullOrWhiteSpace(model.Email) && model.Email != user.Email)
            //     user.Email = model.Email;

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
                return BadRequest(result.Errors);

            // عادة لا يسمح للمستخدم بتغيير دوره بنفسه؛ لذا نتجاهل RoleName هنا
            // إذا أردت السماح بذلك، يجب تقييده مثلاً RoleName = "Member" فقط للمستخدم

            var roles = await _userManager.GetRolesAsync(user);

            return Ok(new
            {
                message = "Profile updated successfully.",
                user.Id,
                user.UserName,
                user.Email,
                user.PhoneNumber,
                user.FirstName,
                user.LastName,
                user.DateOfBirth,
                Role = roles.FirstOrDefault() ?? "User"
            });
        }

        // GET: api/users (Admin فقط) – يمكن لاحقاً الفلترة بالـ UserName
        [HttpGet]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _userManager.Users.ToListAsync();
            var result = new List<object>();

            foreach (var user in users)
            {
                var roles = await _userManager.GetRolesAsync(user);
                result.Add(new
                {
                    user.Id,
                    user.UserName,
                    user.Email,
                    user.PhoneNumber,
                    user.FirstName,
                    user.LastName,
                    user.DateOfBirth,
                    Role = roles.FirstOrDefault() ?? "User"
                });
            }

            return Ok(result);
        }

        // GET: api/users/{userName} (Admin فقط) – البحث بـ UserName بدل Id
        [HttpGet("{userName}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetUserByUserName(string userName)
        {
            var user = await _userManager.FindByNameAsync(userName);
            if (user == null)
                return NotFound(new { message = "User not found." });

            var roles = await _userManager.GetRolesAsync(user);

            return Ok(new
            {
                user.Id,
                user.UserName,
                user.Email,
                user.PhoneNumber,
                user.FirstName,
                user.LastName,
                user.DateOfBirth,
                Role = roles.FirstOrDefault() ?? "User"
            });
        }

        // PUT: api/users/{userName}/role  (Admin فقط – لتغيير أي دور لأي مستخدم)
        [HttpPut("{userName}/role")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ChangeUserRole(string userName, [FromBody] string roleName)
        {
            if (string.IsNullOrWhiteSpace(roleName))
                return BadRequest(new { message = "RoleName is required." });

            var user = await _userManager.FindByNameAsync(userName);
            if (user == null)
                return NotFound(new { message = "User not found." });

            if (!await _roleManager.RoleExistsAsync(roleName))
            {
                // ✅ Auto-create role if it fits Admin intent
                var createResult = await _roleManager.CreateAsync(new IdentityRole(roleName));
                if (!createResult.Succeeded)
                    return BadRequest(new { message = $"Failed to create role '{roleName}'." });
            }

            var currentRoles = await _userManager.GetRolesAsync(user);
            await _userManager.RemoveFromRolesAsync(user, currentRoles);
            await _userManager.AddToRoleAsync(user, roleName);

            return Ok(new { message = $"User '{userName}' role changed to '{roleName}'." });
        }

        // DELETE: api/users/{userName} (Admin فقط) – حذف بالـ UserName
        [HttpDelete("{userName}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteUser(string userName)
        {
            var user = await _userManager.FindByNameAsync(userName);
            if (user == null)
                return NotFound(new { message = "User not found." });

            var result = await _userManager.DeleteAsync(user);
            if (!result.Succeeded)
                return BadRequest(result.Errors);

            return Ok(new { message = "User deleted successfully." });
        }
    }
}
