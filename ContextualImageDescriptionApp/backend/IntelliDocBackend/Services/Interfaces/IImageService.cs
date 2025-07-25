using IntelliDocBackend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace IntelliDocBackend.Services
{
    public interface IImageService
    {
        Task<(bool Success, string Message, int ImageId)> CreateImageAsync(int userId, int documentId, IFormFile file);
        Task<IEnumerable<Image>> GetImagesByDocumentAsync(int userId, int documentId);
        Task<(bool Success, string Message, byte[] FileBytes, string FileName)> DownloadImageAsync(int userId, int imageId);
        Task<Image> RegisterImageMetadataAsync(Image image);
        Task<Image?> GetImageByIdAsync(int imageId);
        Task UpdateImageAsync(Image image);
    }
} 