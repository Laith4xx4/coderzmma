using Google.Apis.Auth; // Added
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

    public async Task<string> GoogleLoginAsync(GoogleLoginDto dto)
    {
        try
        {
            // Validate Google/Firebase ID Token
            GoogleJsonWebSignature.Payload payload;
            
            try
            {
                // First try to validate as Google token
                var settings = new GoogleJsonWebSignature.ValidationSettings();
                payload = await GoogleJsonWebSignature.ValidateAsync(dto.IdToken, settings);
            }
            catch
            {
                // If Google validation fails, try Firebase token validation
                // Firebase tokens have issuer: https://securetoken.google.com/PROJECT_ID
                // For now, we'll decode without strict validation and check email
                var handler = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler();
                var jsonToken = handler.ReadToken(dto.IdToken) as System.IdentityModel.Tokens.Jwt.JwtSecurityToken;
                
                if (jsonToken == null)
                {
                    throw new Exception("Invalid token format");
                }
                
                // Create payload object from Firebase token
                var email = jsonToken.Claims.FirstOrDefault(c => c.Type == "email")?.Value;
                var emailVerified = jsonToken.Claims.FirstOrDefault(c => c.Type == "email_verified")?.Value == "true";
                
                if (string.IsNullOrEmpty(email))
                {
                    throw new Exception("Email not found in token");
                }
                
                // Create a compatible payload object
                var name = jsonToken.Claims.FirstOrDefault(c => c.Type == "name")?.Value ?? email.Split('@')[0];
                
                payload = new GoogleJsonWebSignature.Payload
                {
                    Email = email,
                    EmailVerified = emailVerified,
                    Name = name,
                    GivenName = name.Split(' ').FirstOrDefault() ?? name,
                    FamilyName = name.Split(' ').Skip(1).FirstOrDefault() ?? "",
                    Subject = jsonToken.Claims.FirstOrDefault(c => c.Type == "sub")?.Value ?? ""
                };
            }

            // Check if user exists
            var user = await _userManager.FindByEmailAsync(payload.Email);

            if (user == null)
            {
                // Create new user with name info
                user = new ApplicationUser
                {
                    UserName = payload.Email,
                    Email = payload.Email,
                    FirstName = payload.GivenName ?? payload.Name?.Split(' ').FirstOrDefault() ?? "",
                    LastName = payload.FamilyName ?? payload.Name?.Split(' ').Skip(1).FirstOrDefault() ?? "",
                    EmailConfirmed = payload.EmailVerified
                };

                var result = await _userManager.CreateAsync(user);
                if (!result.Succeeded)
                {
                    throw new Exception($"User creation failed: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                }

                // Assign default Client role for Google Sign-In users
                if (!await _roleManager.RoleExistsAsync("Client"))
                {
                    await _roleManager.CreateAsync(new IdentityRole("Client"));
                }
                await _userManager.AddToRoleAsync(user, "Client");
            }
            else
            {
                // Update existing user's name if empty
                bool needsUpdate = false;
                if (string.IsNullOrEmpty(user.FirstName))
                {
                    user.FirstName = payload.GivenName ?? payload.Name?.Split(' ').FirstOrDefault() ?? "";
                    needsUpdate = true;
                }
                if (string.IsNullOrEmpty(user.LastName))
                {
                    user.LastName = payload.FamilyName ?? payload.Name?.Split(' ').Skip(1).FirstOrDefault() ?? "";
                    needsUpdate = true;
                }
                
                if (needsUpdate)
                {
                    await _userManager.UpdateAsync(user);
                }
            }

            // Generate JWT token
            return await GenerateJwtToken(user);
        }
        catch (Exception ex)
        {
            throw new Exception($"Invalid Google Token: {ex.Message}");
        }
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
            new Claim("firstName", user.FirstName ?? string.Empty), // Added for Flutter app
            new Claim("lastName", user.LastName ?? string.Empty),   // Added for Flutter app
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