using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using WebApplication1.DTOs;
using WebApplication1.Identity;

public class AuthService : IAuthService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;
    private readonly IConfiguration _configuration;

    public AuthService(
        UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole> roleManager,
        IConfiguration configuration)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _configuration = configuration;
    }

    public async Task<string> RegisterAsync(RegisterDto dto)
    {
        var user = new ApplicationUser
        {
            UserName = dto.UserName,
            Email = dto.Email,
            FirstName = dto.FirstName,
            LastName = dto.LastName,
            PhoneNumber = dto.PhoneNumber,
            DateOfBirth = dto.DateOfBirth,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded)
            throw new Exception(string.Join(", ", result.Errors.Select(e => e.Description)));

        // لا يوجد تعيين Role هنا

        // ✅ Assign Role
        string roleToAssign = !string.IsNullOrEmpty(dto.Role) ? dto.Role : "Client";

        // Create role if it doesn't exist (Safety check)
        if (!await _roleManager.RoleExistsAsync(roleToAssign))
        {
            await _roleManager.CreateAsync(new IdentityRole(roleToAssign));
        }

        await _userManager.AddToRoleAsync(user, roleToAssign);

        return user.Id;
    }

    public async Task<string> LoginAsync(LoginDto dto)
    {
        ApplicationUser user = null;

        // إذا فيه @ نعتبره إيميل، غير ذلك نعامله كاسم مستخدم
        if (dto.UserNameOrEmail.Contains("@"))
        {
            user = await _userManager.FindByEmailAsync(dto.UserNameOrEmail);
        }
        else
        {
            user = await _userManager.FindByNameAsync(dto.UserNameOrEmail);
        }

        if (user == null || !await _userManager.CheckPasswordAsync(user, dto.Password))
            throw new Exception("Invalid credentials");

        return await GenerateJwtToken(user);
    }

    private async Task<string> GenerateJwtToken(ApplicationUser user)
    {
        var jwtSettings = _configuration.GetSection("Jwt");
        var secretKey = jwtSettings["Key"];
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];

        var roles = await _userManager.GetRolesAsync(user); // لو تعيّن أدوار لاحقاً من لوحة تحكم مثلاً

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(ClaimTypes.Name, user.UserName ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}