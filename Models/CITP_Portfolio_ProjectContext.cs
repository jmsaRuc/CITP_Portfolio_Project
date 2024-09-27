using Microsoft.EntityFrameworkCore;

namespace CITP_Portfolio_Project.Models;

public class CITP_Portfolio_ProjectContext : DbContext
{
    public CITP_Portfolio_ProjectContext(DbContextOptions<CITP_Portfolio_ProjectContext> options)
        : base(options)
    {
    }

    public DbSet<CITP_Portfolio_ProjectItem> CITP_Portfolio_ProjectItems { get; set; } = null!;
}
