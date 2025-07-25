using IntelliDocBackend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace IntelliDocBackend.Repositories
{
    public interface IImageRepository
    {
        Task AddAsync(Image image);
        Task<Image?> GetByIdAsync(int imageId);
        Task<List<Image>> GetByDocumentIdAsync(int documentId);
    }
} 