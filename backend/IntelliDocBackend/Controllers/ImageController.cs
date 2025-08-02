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
    public class ImageController : ControllerBase
    {
        private readonly IImageService _imageService;

        public ImageController(IImageService imageService)
        {
            _imageService = imageService;
        }

        [HttpPost("{documentId}")]
        public async Task<IActionResult> CreateImage(int documentId, [FromForm] IFormFile file)
        {
            if (file == null)
            {
                return BadRequest(new { Message = "File is required." });
            }

            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var (success, message, imageId) = await _imageService.CreateImageAsync(userId, documentId, file);
            if (!success)
            {
                return BadRequest(new { Message = message });
            }
            return Ok(new { Message = message, ImageID = imageId });
        }

        [HttpGet("document/{documentId}")]
        public async Task<IActionResult> GetImagesByDocument(int documentId)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var images = await _imageService.GetImagesByDocumentAsync(userId, documentId);
            return Ok(images);
        }

        [HttpGet("{imageId}/download")]
        public async Task<IActionResult> DownloadImage(int imageId)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? throw new UnauthorizedAccessException("User ID not found in token."));
            var (success, message, fileBytes, fileName) = await _imageService.DownloadImageAsync(userId, imageId);
            
            if (!success)
            {
                return BadRequest(new { Message = message });
            }

            // Determine content type based on file extension
            var extension = Path.GetExtension(fileName).ToLower();
            var contentType = extension switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                _ => "application/octet-stream"
            };

            return File(fileBytes, contentType, fileName);
        }

        [HttpPut("update-description/{id}")]
        public async Task<IActionResult> UpdateDescription(int id, [FromBody] string description)
        {
            var image = await _imageService.GetImageByIdAsync(id);
            if (image == null)
                return NotFound();

            image.Description = description;
            await _imageService.UpdateImageAsync(image);

            return Ok(image);
        }

        [HttpPost]
        [AllowAnonymous] // Remove or adjust as needed for your auth
        public async Task<IActionResult> RegisterImageMetadata([FromBody] Image image)
        {
            if (image == null)
                return BadRequest();

            var createdImage = await _imageService.RegisterImageMetadataAsync(image);
            // No GetImageById action exists, so just return Ok or Created with no action reference
            return Ok(createdImage);
        }
    }
} 