using IntelliDocBackend.Models;
using IntelliDocBackend.Data;
using Microsoft.EntityFrameworkCore;

namespace IntelliDocBackend.Repositories
{
    public class ImageRepository : IImageRepository
    {
        private readonly IntelliDocContext _context;

        public ImageRepository(IntelliDocContext context)
        {
            _context = context;
        }

        public async Task AddAsync(Image image)
        {
            await _context.Images.AddAsync(image);
            await _context.SaveChangesAsync();
        }

        public async Task<Image?> GetByIdAsync(int imageId)
        {
            return await _context.Images
                .Include(i => i.Document)
                .FirstOrDefaultAsync(i => i.ImageID == imageId);
        }

        public async Task<List<Image>> GetByDocumentIdAsync(int documentId)
        {
            return await _context.Images
                .Where(i => i.DocumentID == documentId)
                .ToListAsync();
        }

        public async Task UpdateAsync(Image image)
        {
            _context.Images.Update(image);
            await _context.SaveChangesAsync();
        }

        public async Task<Image?> RegisterImageMetadataAsync(Image image)
        {
            await _context.Images.AddAsync(image);
            await _context.SaveChangesAsync();
            return image;
        }

        public async Task<Image?> GetByDocumentIdAndFilePathAsync(int documentId, string filePath)
        {
            return await _context.Images.FirstOrDefaultAsync(i => i.DocumentID == documentId && i.FilePath == filePath);
        }
    }
} 