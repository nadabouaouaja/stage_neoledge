using IntelliDocBackend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace IntelliDocBackend.Repositories
{
    public interface IDocumentRepository
    {
        Task AddAsync(Document document);
        Task<Document?> GetByIdAsync(int documentId);
        Task<List<Document>> GetByUserIdAsync(int userId);
        Task UpdateAsync(Document document);
        Task DeleteAsync(Document document);
        Task<List<Document>> SearchAsync(int userId, string? title, Category? category);
    }
} 