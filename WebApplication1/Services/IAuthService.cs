using System.Threading.Tasks;
using WebApplication1.DTOs; // تأكد من مسار DTOs
using WebApplication1.Identity;

public interface IAuthService
{
    Task<string> RegisterAsync(RegisterDto dto);
    Task<string> LoginAsync(LoginDto dto);
    Task<string> GoogleLoginAsync(GoogleLoginDto dto);
}
