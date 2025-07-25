using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace IntelliDocBackend.Models
{
    public class Document
    {
        [Key]
        public int DocumentID { get; set; }

        [Required]
        public int UserID { get; set; } 

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [StringLength(500)]
        public string FilePath { get; set; } = string.Empty;

        [Required]
        public Category Category { get; set; }

        public DateTime UploadDate { get; set; } = DateTime.UtcNow;

        public string Content { get; set; } = string.Empty;

        [Required]
        public Status Status { get; set; } = Status.Uploaded;

        public List<Image> Images { get; set; } = new();

        [JsonIgnore]
        public User User { get; set; } = null!; 
    }
}