using IntelliDocBackend.Models;
using IntelliDocBackend.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using BCrypt.Net;

namespace IntelliDocBackend.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IConfiguration _configuration;

        public UserService(IUserRepository userRepository, IConfiguration configuration)
        {
            _userRepository = userRepository;
            _configuration = configuration;
        }

        public async Task<(bool Success, string Message, User? User)> RegisterAsync(string email, string password, string firstName, string lastName)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(firstName) || string.IsNullOrEmpty(lastName))
            {
                return (false, "Email, password, first name, and last name are required.", null);
            }

            var existingUser = await _userRepository.GetByEmailAsync(email);
            if (existingUser != null)
            {
                return (false, "Email is already associated with an account.", null);
            }

            var user = new User
            {
                Email = email,
                Password = BCrypt.Net.BCrypt.HashPassword(password),
                FirstName = firstName,
                LastName = lastName,
                CreatedAt = DateTime.UtcNow,
                LastLogin = null
            };

            await _userRepository.AddAsync(user);
            return (true, "User registered successfully.", user);
        }

        public async Task<User?> GetUserDetailsAsync(int userId)
        {
            return await _userRepository.GetByIdAsync(userId);
        }

        public async Task<(bool Success, string Message)> UpdateProfileAsync(int userId, string email, string firstName, string lastName)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(firstName) || string.IsNullOrEmpty(lastName))
            {
                return (false, "Email, first name, and last name are required.");
            }

            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                return (false, "User not found.");
            }

            var existingUser = await _userRepository.GetByEmailAsync(email);
            if (existingUser != null && existingUser.UserID != userId)
            {
                return (false, "Email is already associated with another account.");
            }

            user.Email = email;
            user.FirstName = firstName;
            user.LastName = lastName;
            await _userRepository.UpdateAsync(user);
            return (true, "Profile updated successfully.");
        }

        public async Task<(bool Success, string? Token, string Message)> LoginAsync(string email, string password)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                return (false, null, "Email and password are required.");
            }

            var user = await _userRepository.GetByEmailAsync(email);
            if (user == null || user.Password == null || !BCrypt.Net.BCrypt.Verify(password, user.Password))
            {
                return (false, null, "Invalid email or password.");
            }

            user.LastLogin = DateTime.UtcNow;
            await _userRepository.UpdateAsync(user);

            var token = GenerateJwtToken(user);
            return (true, token, "Login successful.");
        }

        private string GenerateJwtToken(User user)
        {
            var keyString = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key is not configured in appsettings.json.");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.UserID.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(60),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
} 