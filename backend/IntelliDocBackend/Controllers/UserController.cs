using IntelliDocBackend.Models;
using IntelliDocBackend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace IntelliDocBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (string.IsNullOrEmpty(request.Email) || string.IsNullOrEmpty(request.Password) ||
                string.IsNullOrEmpty(request.FirstName) || string.IsNullOrEmpty(request.LastName))
            {
                return BadRequest(new { Message = "Email, password, first name, and last name are required." });
            }

            var (success, message, user) = await _userService.RegisterAsync(request.Email, request.Password, request.FirstName, request.LastName);
            if (!success)
            {
                return BadRequest(new { Message = message });
            }

            return Ok(new { Message = message, UserID = user?.UserID ?? 0 });
        }

        [Authorize]
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetUserDetails(int userId)
        {
            var tokenUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            if (tokenUserId != userId)
            {
                return Unauthorized(new { Message = "You are not authorized to access this user's details." });
            }

            var user = await _userService.GetUserDetailsAsync(userId);
            if (user == null)
            {
                return NotFound(new { Message = "User not found." });
            }
            return Ok(new { user.UserID, user.Email, user.FirstName, user.LastName, user.CreatedAt, user.LastLogin });
        }

        [Authorize]
        [HttpPut("{userId}/profile")]
        public async Task<IActionResult> UpdateProfile(int userId, [FromBody] UpdateProfileRequest request)
        {
            var tokenUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            if (tokenUserId != userId)
            {
                return Unauthorized(new { Message = "You are not authorized to update this user's profile." });
            }

            if (string.IsNullOrEmpty(request.Email) || string.IsNullOrEmpty(request.FirstName) || string.IsNullOrEmpty(request.LastName))
            {
                return BadRequest(new { Message = "Email, first name, and last name are required." });
            }

            var (success, message) = await _userService.UpdateProfileAsync(userId, request.Email, request.FirstName, request.LastName);
            if (!success)
            {
                return BadRequest(new { Message = message });
            }
            return Ok(new { Message = message });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrEmpty(request.Email) || string.IsNullOrEmpty(request.Password))
            {
                return BadRequest(new { Message = "Email and password are required." });
            }

            var (success, token, message) = await _userService.LoginAsync(request.Email, request.Password);
            if (!success)
            {
                return Unauthorized(new { Message = message });
            }
            return Ok(new { Token = token, Message = message });
        }
    }

    public class RegisterRequest
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
    }

    public class UpdateProfileRequest
    {
        public string? Email { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
    }

    public class LoginRequest
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
    }
}