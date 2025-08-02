using IntelliDocBackend.Models;
using IntelliDocBackend.Data;
using Microsoft.EntityFrameworkCore;


namespace IntelliDocBackend.Repositories
{
    public class DocumentRepository : IDocumentRepository
    {
        private readonly IntelliDocContext _context;

        public DocumentRepository(IntelliDocContext context)
        {
            _context = context;
        }

        public async Task AddAsync(Document document)
        {
            await _context.Documents.AddAsync(document);
            await _context.SaveChangesAsync();
        }

        public async Task<Document?> GetByIdAsync(int documentId)
        {
            return await _context.Documents
                .Include(d => d.User)
                .FirstOrDefaultAsync(d => d.DocumentID == documentId);
        }

        public async Task<List<Document>> GetByUserIdAsync(int userId)
        {
            return await _context.Documents
                .Include(d => d.User)
                .Where(d => d.UserID == userId)
                .ToListAsync();
        }

        public async Task UpdateAsync(Document document)
        {
            _context.Documents.Update(document);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Document document)
        {
            _context.Documents.Remove(document);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Document>> SearchAsync(int userId, string? title, Category? category)
        {
            var query = _context.Documents
                .Include(d => d.User)
                .Where(d => d.UserID == userId);

            if (!string.IsNullOrEmpty(title))
            {
                query = query.Where(d => d.Title.Contains(title));
            }

            if (category.HasValue)
            {
                query = query.Where(d => d.Category == category.Value);
            }

            return await query.ToListAsync();
        }
    }
} 