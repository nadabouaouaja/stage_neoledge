using IntelliDocBackend.Models;
using IntelliDocBackend.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;
using UglyToad.PdfPig;
using UglyToad.PdfPig.Content;
using System.Text;

namespace IntelliDocBackend.Services
{
    public class DocumentService : IDocumentService
    {
        private readonly IDocumentRepository _documentRepository;

        public DocumentService(IDocumentRepository documentRepository)
        {
            _documentRepository = documentRepository;
        }

        public async Task<(bool Success, string Message, int DocumentId)> CreateDocumentAsync(int userId, IFormFile file, string title, Category category)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "No file uploaded.", 0);
            }

            if (file.Length > 5 * 1024 * 1024) // 5 MB limit
            {
                return (false, "File size exceeds 5 MB limit.", 0);
            }

            if (Path.GetExtension(file.FileName).ToLower() != ".pdf")
            {
                return (false, "Only PDF files are allowed.", 0);
            }

            if (string.IsNullOrEmpty(title))
            {
                return (false, "Title is required.", 0);
            }

            var uploadsDir = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
            
            try
            {
                Directory.CreateDirectory(uploadsDir);
            }
            catch (Exception ex)
            {
                return (false, $"Failed to create upload directory: {ex.Message}", 0);
            }

            var filePath = Path.Combine(uploadsDir, $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}");

            try
            {
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
            }
            catch (Exception ex)
            {
                return (false, $"Failed to save file: {ex.Message}", 0);
            }

            var document = new Document
            {
                Title = title,
                Category = category,
                UploadDate = DateTime.UtcNow,
                UserID = userId,
                Content = string.Empty, // Will be set after extraction
                Status = Status.Uploaded,
                FilePath = filePath
            };

            // Extract text from PDF using PdfPig
            try
            {
                using (var pdf = PdfDocument.Open(filePath))
                {
                    var text = new StringBuilder();
                    foreach (Page page in pdf.GetPages())
                    {
                        text.AppendLine(page.Text);
                    }
                    document.Content = text.ToString();
                }
            }
            catch (Exception)
            {
                document.Content = string.Empty;
                // Status remains Uploaded even if extraction fails
            }

            await _documentRepository.AddAsync(document);
            return (true, "Document uploaded successfully.", document.DocumentID);
        }

        public async Task<Document?> GetDocumentAsync(int userId, int documentId)
        {
            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null || document.UserID != userId)
            {
                return null;
            }
            return document;
        }

        public async Task<IEnumerable<Document>> GetUserDocumentsAsync(int userId)
        {
            return await _documentRepository.GetByUserIdAsync(userId);
        }

        public async Task<(bool Success, string Message)> UpdateDocumentAsync(int userId, int documentId, string title, Category category)
        {
            if (string.IsNullOrEmpty(title))
            {
                return (false, "Title is required.");
            }

            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null || document.UserID != userId)
            {
                return (false, "Document not found or unauthorized.");
            }

            document.Title = title;
            document.Category = category;
            document.Status = Status.Uploaded; // Reset to Uploaded on update
            await _documentRepository.UpdateAsync(document);
            return (true, "Document updated successfully.");
        }

        public async Task<(bool Success, string Message)> DeleteDocumentAsync(int userId, int documentId)
        {
            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null || document.UserID != userId)
            {
                return (false, "Document not found or unauthorized.");
            }

            if (File.Exists(document.FilePath))
            {
                try
                {
                    File.Delete(document.FilePath);
                }
                catch (Exception ex)
                {
                    // Log the error but continue with database deletion
                    // You might want to add proper logging here
                    return (false, $"Document record deleted but failed to delete file: {ex.Message}");
                }
            }

            await _documentRepository.DeleteAsync(document);
            return (true, "Document deleted successfully.");
        }

        public async Task<IEnumerable<Document>> SearchDocumentsAsync(int userId, string? title, Category? category)
        {
            return await _documentRepository.SearchAsync(userId, title, category);
        }

        public async Task<(bool Success, string Message, byte[] FileBytes, string FileName)> DownloadDocumentAsync(int userId, int documentId)
        {
            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null || document.UserID != userId)
            {
                return (false, "Document not found or unauthorized.", new byte[0], string.Empty);
            }

            if (!File.Exists(document.FilePath))
            {
                return (false, "Document file not found on server.", new byte[0], string.Empty);
            }

            try
            {
                var fileBytes = await File.ReadAllBytesAsync(document.FilePath);
                var fileName = Path.GetFileName(document.FilePath);
                return (true, "Document downloaded successfully.", fileBytes, fileName);
            }
            catch (Exception ex)
            {
                return (false, $"Error reading document file: {ex.Message}", new byte[0], string.Empty);
            }
        }
    }
} 