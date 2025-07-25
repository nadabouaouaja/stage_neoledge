using Microsoft.EntityFrameworkCore;
using IntelliDocBackend.Models;

namespace IntelliDocBackend.Data
{
    public class IntelliDocContext : DbContext
    {
        public IntelliDocContext(DbContextOptions<IntelliDocContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Document> Documents { get; set; }
        public DbSet<Image> Images { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();

            modelBuilder.Entity<Document>().HasOne(d => d.User).WithMany(u => u.Documents).HasForeignKey(d => d.UserID);

            modelBuilder.Entity<Image>().HasOne(i => i.Document).WithMany(d => d.Images).HasForeignKey(i => i.DocumentID);

            modelBuilder.Entity<Document>().Property(d => d.Category).HasConversion<string>();
            modelBuilder.Entity<Document>().Property(d => d.Status).HasConversion<string>();
        }
    }
}
