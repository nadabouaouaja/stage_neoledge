using IntelliDocBackend.Models;
using IntelliDocBackend.Data;
using Microsoft.EntityFrameworkCore;

namespace IntelliDocBackend.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly IntelliDocContext _context;
        public UserRepository(IntelliDocContext context)
        {
            _context = context;
        }

        public async Task<User?> GetByIdAsync(int id)
        {
            return await _context.Users.Include(u => u.Documents).FirstOrDefaultAsync(u => u.UserID == id);
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.Users.Include(u => u.Documents).FirstOrDefaultAsync(u => u.Email == email);
        }


        public async Task AddAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(User user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }

    }
} 