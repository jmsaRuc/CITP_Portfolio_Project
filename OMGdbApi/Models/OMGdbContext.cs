using OMGdbApi.Models;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using OMGdbApi.Models.Users;
using OMGdbApi.Models.Users.Watchlist;
namespace OMGdbApi.Models;

public class OMGdbContext : DbContext
{  

    public OMGdbContext(DbContextOptions<OMGdbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;
   
    public DbSet<Episodes> Episodes { get; set; } = null!;

    public DbSet<Movie> Movie { get; set; } = null!;

    public DbSet<Series> Series { get; set; } = null!;

    public DbSet<Person> Person { get; set; } = null!;

    public DbSet<WatchlistEpisode> WatchlistEpisode { get; set; } = null!;   

    public DbSet<WatchlistMovie> WatchlistMovie { get; set; } = null!;

    public DbSet<WatchlistSeries> WatchlistSeries { get; set; } = null!;


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        //User
        modelBuilder.Entity<User>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('ur' || to_char(nextval('public.user_seq'::regclass), 'FM00000000'))"); 

        modelBuilder.Entity<User>()
           .Property(b => b.Created_at)
           .HasDefaultValueSql("getdate()");

        modelBuilder.Entity<User>()
            .HasIndex(b => b.Created_at);     

        //Episodes
        modelBuilder.Entity<Episodes>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Episodes>()
            .Property(b => b.Popularity)
            .HasDefaultValueSql("0");    

        modelBuilder.Entity<Episodes>()
            .HasIndex(b => b.Popularity);    

        //Movie
        modelBuilder.Entity<Movie>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Movie>()
            .Property(b => b.Popularity)
            .HasDefaultValue("0");    

        modelBuilder.Entity<Movie>()
            .HasIndex(b => b.Popularity);

        //Series
        modelBuilder.Entity<Series>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Series>()
            .Property(b => b.Popularity)
            .HasDefaultValue("0");    

        modelBuilder.Entity<Series>()
            .HasIndex(b => b.Popularity);    
            
        //Person
        modelBuilder.Entity<Person>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('nm' || to_char(nextval('public.person_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Person>()
            .Property(b => b.Popularity)
            .HasDefaultValue("0");

        modelBuilder.Entity<Person>()
            .HasIndex(b => b.Popularity);

        //WatchlistEpisode
        modelBuilder.Entity<WatchlistEpisode>()
            .HasKey(b => new { b.UserId, b.EpisodeId });

        modelBuilder.Entity<WatchlistEpisode>()
            .Property(b => b.Watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

        //WatchlistMovie
        modelBuilder.Entity<WatchlistMovie>()
            .HasKey(b => new { b.UserId, b.MovieId });

        modelBuilder.Entity<WatchlistMovie>()
            .Property(b => b.watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

       //WatchlistSeries
        modelBuilder.Entity<WatchlistSeries>()
            .HasKey(b => new { b.UserId, b.SeriesId });

        modelBuilder.Entity<WatchlistSeries>()
            .Property(b => b.watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");                      
    }

     
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

