using OMGdbApi.Models;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace OMGdbApi.Models;

public class OMGdbContext : DbContext
{  


    public OMGdbContext(DbContextOptions<OMGdbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('ur' || to_char(nextval('public.user_seq'::regclass), 'FM00000000'))");

         modelBuilder.Entity<User>()
            .Property(b => b.Created_at)
            .HasDefaultValueSql("getdate()"); 
    }  
   // public async Task<bool> CreateUser(string name, byte[] password, string email)
   // {
   //     try {
   //         await using var dataSource = Database.GetDbConnection();
   //         await using var cmd = dataSource.CreateCommand();
   //         cmd.CommandText = "SELECT create_user($1, $2, $3)";
//
   //         cmd.Parameters.Add(new NpgsqlParameter("1", name));
   //         cmd.Parameters.Add(new NpgsqlParameter("2", password));
   //         cmd.Parameters.Add(new NpgsqlParameter("3", email));
//
   //         await using var reader = await cmd.ExecuteReaderAsync();
//
   //         if (await reader.ReadAsync())
   //         {
   //             return reader.GetBoolean(0);
   //         }
//
   //     } 
   //     catch (Exception e)
   //     {
   //         Console.WriteLine(e);
   //     }
   //     return false;
   // }
}
