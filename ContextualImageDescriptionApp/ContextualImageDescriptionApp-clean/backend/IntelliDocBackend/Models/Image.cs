using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace IntelliDocBackend.Models
{
    public class Image
    {
        [Key]
        public int ImageID { get; set; }

        [Required]
        public int DocumentID { get; set; }

        public DateTime ExtractedDate { get; set; }

        public string? Description { get; set; }

        [Required]
        [StringLength(500)]
        public string FilePath { get; set; } = string.Empty;

        [JsonIgnore]
        public Document Document { get; set; } = null!; 
    }
} 