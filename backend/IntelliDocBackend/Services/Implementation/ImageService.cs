using IntelliDocBackend.Models;
using IntelliDocBackend.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace IntelliDocBackend.Services
{
    public class ImageService : IImageService
    {
        private readonly IImageRepository _imageRepository;
        private readonly IDocumentRepository _documentRepository;

        public ImageService(IImageRepository imageRepository, IDocumentRepository documentRepository)
        {
            _imageRepository = imageRepository;
            _documentRepository = documentRepository;
        }

        public async Task<(bool Success, string Message, int ImageId)> CreateImageAsync(int userId, int documentId, IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "No file uploaded.", 0);
            }

            if (file.Length > 5 * 1024 * 1024) // 5 MB limit
            {
                return (false, "File size exceeds 5 MB limit.", 0);
            }

            var extension = Path.GetExtension(file.FileName).ToLower();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
            {
                return (false, "Only JPG, JPEG, or PNG files are allowed.", 0);
            }

            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null || document.UserID != userId)
            {
                return (false, "Document not found or unauthorized.", 0);
            }

            var imagesDir = Path.Combine(Directory.GetCurrentDirectory(), "images");
            Directory.CreateDirectory(imagesDir);
            var filePath = Path.Combine(imagesDir, $"{Guid.NewGuid()}{extension}");

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var image = new Image
            {
                DocumentID = documentId,
                ExtractedDate = DateTime.UtcNow,
                Description = null, // Per requirement
                FilePath = filePath
            };

            await _imageRepository.AddAsync(image);
            return (true, "Image uploaded successfully.", image.ImageID);
        }

        public async Task<IEnumerable<Image>> GetImagesByDocumentAsync(int userId, int documentId)
        {
            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null || document.UserID != userId)
            {
                return Enumerable.Empty<Image>();
            }

            var images = await _imageRepository.GetByDocumentIdAsync(documentId);
            return images.Select(i => new Image
            {
                ImageID = i.ImageID,
                DocumentID = i.DocumentID,
                ExtractedDate = i.ExtractedDate,
                Description = i.Description
            });
        }

        public async Task<(bool Success, string Message, byte[] FileBytes, string FileName)> DownloadImageAsync(int userId, int imageId)
        {
            var image = await _imageRepository.GetByIdAsync(imageId);
            if (image == null)
            {
                return (false, "Image not found.", new byte[0], string.Empty);
            }

            var document = await _documentRepository.GetByIdAsync(image.DocumentID);
            if (document == null || document.UserID != userId)
            {
                return (false, "Image not found or unauthorized.", new byte[0], string.Empty);
            }

            if (!File.Exists(image.FilePath))
            {
                return (false, "Image file not found on server.", new byte[0], string.Empty);
            }

            try
            {
                var fileBytes = await File.ReadAllBytesAsync(image.FilePath);
                var fileName = Path.GetFileName(image.FilePath);
                return (true, "Image downloaded successfully.", fileBytes, fileName);
            }
            catch (Exception ex)
            {
                return (false, $"Error reading image file: {ex.Message}", new byte[0], string.Empty);
            }
        }

        public async Task<Image> RegisterImageMetadataAsync(Image image)
        {
            if (image == null)
                throw new ArgumentNullException(nameof(image));
            // Optionally set ExtractedDate if not set
            if (image.ExtractedDate == default)
                image.ExtractedDate = DateTime.UtcNow;

            var existing = await _imageRepository.GetByDocumentIdAndFilePathAsync(image.DocumentID, image.FilePath);
            if (existing != null)
            {
                existing.Description = image.Description;
                existing.ExtractedDate = image.ExtractedDate;
                await _imageRepository.UpdateAsync(existing);
                return existing;
            }
            else
            {
                await _imageRepository.AddAsync(image);
                return image;
            }
        }

        public async Task<Image?> GetImageByIdAsync(int imageId)
        {
            return await _imageRepository.GetByIdAsync(imageId);
        }

        public async Task UpdateImageAsync(Image image)
        {
            await _imageRepository.UpdateAsync(image);
        }
    }
} 