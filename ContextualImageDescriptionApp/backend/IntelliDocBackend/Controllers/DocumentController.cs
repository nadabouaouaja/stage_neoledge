using IntelliDocBackend.Models;
using IntelliDocBackend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;


namespace IntelliDocBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DocumentController : ControllerBase
    {
        private readonly IDocumentService _documentService;

        public DocumentController(IDocumentService documentService)
        {
            _documentService = documentService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateDocument([FromForm] IFormFile file, [FromForm] string title, [FromForm] Category category)
        {
            if (file == null || string.IsNullOrEmpty(title))
            {
                return BadRequest(new { Message = "File and title are required." });
            }

            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var (success, message, documentId) = await _documentService.CreateDocumentAsync(userId, file, title, category);
            if (!success)
            {
                return BadRequest(new { Message = message });
            }
            return Ok(new { Message = message, DocumentID = documentId });
        }

        [HttpGet("{documentId}")]
        public async Task<IActionResult> GetDocument(int documentId)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var document = await _documentService.GetDocumentAsync(userId, documentId);
            if (document == null)
            {
                return NotFound(new { Message = "Document not found or unauthorized." });
            }
            return Ok(new
            {
                document.DocumentID,
                document.Title,
                document.Category,
                document.UploadDate,
                document.UserID,
                document.Content,
                document.Status,
                document.FilePath
            });
        }

        [HttpGet("{documentId}/download")]
        public async Task<IActionResult> DownloadDocument(int documentId)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var (success, message, fileBytes, fileName) = await _documentService.DownloadDocumentAsync(userId, documentId);
            
            if (!success)
            {
                return BadRequest(new { Message = message });
            }

            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet]
        public async Task<IActionResult> ListDocuments()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var documents = await _documentService.GetUserDocumentsAsync(userId);
            return Ok(documents);
        }

        [HttpPut("{documentId}")]
        public async Task<IActionResult> UpdateDocument(int documentId, [FromBody] UpdateDocumentRequest request)
        {
            if (string.IsNullOrEmpty(request.Title))
            {
                return BadRequest(new { Message = "Title is required." });
            }

            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var (success, message) = await _documentService.UpdateDocumentAsync(userId, documentId, request.Title, request.Category);
            if (!success)
            {
                return BadRequest(new { Message = message });
            }
            return Ok(new { Message = message });
        }

        [HttpDelete("{documentId}")]
        public async Task<IActionResult> DeleteDocument(int documentId)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var (success, message) = await _documentService.DeleteDocumentAsync(userId, documentId);
            if (!success)
            {
                return BadRequest(new { Message = message });
            }
            return Ok(new { Message = message });
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchDocuments([FromQuery] string? title, [FromQuery] Category? category)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var documents = await _documentService.SearchDocumentsAsync(userId, title, category);
            return Ok(documents);
        }
    }

    public class UpdateDocumentRequest
    {
        public string? Title { get; set; }
        public Category Category { get; set; }
    }
}