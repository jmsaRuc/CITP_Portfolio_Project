using OMGdbApi.Models;
using Microsoft.EntityFrameworkCore;

namespace OMGdbApi.Models;

public class OMGdbContext : DbContext
{

    public OMGdbContext(DbContextOptions<OMGdbContext> options)
        : base(options)
    {
    }

    public DbSet<OMGdbItem> OMGdbItems { get; set; } = null!;
}
