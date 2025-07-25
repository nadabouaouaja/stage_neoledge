using IntelliDocBackend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace IntelliDocBackend.Services
{
    public interface IDocumentService
    {
        Task<(bool Success, string Message, int DocumentId)> CreateDocumentAsync(int userId, IFormFile file, string title, Category category);
        Task<Document?> GetDocumentAsync(int userId, int documentId);
        Task<IEnumerable<Document>> GetUserDocumentsAsync(int userId);
        Task<(bool Success, string Message)> UpdateDocumentAsync(int userId, int documentId, string title, Category category);
        Task<(bool Success, string Message)> DeleteDocumentAsync(int userId, int documentId);
        Task<IEnumerable<Document>> SearchDocumentsAsync(int userId, string? title, Category? category);
        Task<(bool Success, string Message, byte[] FileBytes, string FileName)> DownloadDocumentAsync(int userId, int documentId);
    }
} 