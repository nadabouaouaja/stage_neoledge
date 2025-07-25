using IntelliDocBackend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace IntelliDocBackend.Services
{
    public interface IUserService
    {
        Task<(bool Success, string Message, User? User)> RegisterAsync(string email, string password, string firstName, string lastName);
        Task<User?> GetUserDetailsAsync(int userId);
        Task<(bool Success, string Message)> UpdateProfileAsync(int userId, string email, string firstName, string lastName);
        Task<(bool Success, string? Token, string Message)> LoginAsync(string email, string password);
    }
} 