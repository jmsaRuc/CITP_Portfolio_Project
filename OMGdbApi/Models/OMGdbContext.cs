using OMGdbApi.Models;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using OMGdbApi.Models.Users;
using OMGdbApi.Models.Users.Watchlist;
using OMGdbApi.Models.Users.Ratings;
using OMGdbApi.Models.Users.Recent_View;
using Microsoft.EntityFrameworkCore.Metadata;

namespace OMGdbApi.Models;

public class OMGdbContext : DbContext
{  

    public OMGdbContext(DbContextOptions<OMGdbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;
   
    public DbSet<Episode> Episode { get; set; } = null!;

    public DbSet<Movie> Movie { get; set; } = null!;

    public DbSet<Series> Series { get; set; } = null!;

    public DbSet<Person> Person { get; set; } = null!;

    public DbSet<Actor> Actor { get; set; } = null!;

    public DbSet<WatchlistAll> WatchlistAll { get; set; } = null!;

    public DbSet<WatchlistEpisode> WatchlistEpisode { get; set; } = null!;   

    public DbSet<WatchlistMovie> WatchlistMovie { get; set; } = null!;

    public DbSet<WatchlistSeries> WatchlistSeries { get; set; } = null!;

    public DbSet<RatingALL> RatingALL { get; set; } = null!;

    public DbSet<RatingEpisode> RatingEpisode { get; set; } = null!;

    public DbSet<RatingMovie> RatingMovie { get; set; } = null!;

    public DbSet<RatingSeries> RatingSeries { get; set; } = null!;

    public DbSet<RecentViewAll> RecentViewAll { get; set; } = null!;

    public DbSet<RecentView> RecentView { get; set; } = null!;



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
            .HasIndex(b => b.Created_at)
            .HasDatabaseName("ix_user_created_at")
            .IsDescending();    

        //Episode
        modelBuilder.Entity<Episode>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Episode>()
            .Property(b => b.AverageRating)
            .HasDefaultValue("0");

        modelBuilder.Entity<Episode>()
            .Property(b => b.ImdbRating)
            .HasDefaultValue("0");        

        modelBuilder.Entity<Episode>()
            .Property(b => b.Popularity)
            .HasDefaultValueSql("0");

                
        modelBuilder.Entity<Episode>()
            .HasIndex(b => new {b.Popularity, b.AverageRating, b.ImdbRating})
            .HasDatabaseName("ix_episode_pop_avg_and_imdb_rating")
            .IsDescending();

        //Movie
        modelBuilder.Entity<Movie>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Movie>()
            .Property(b => b.AverageRating)
            .HasDefaultValue("0");

        modelBuilder.Entity<Movie>()
            .Property(b => b.ImdbRating)
            .HasDefaultValue("0");     

        modelBuilder.Entity<Movie>()
            .Property(b => b.Popularity)
            .HasDefaultValue("0"); 

        modelBuilder.Entity<Movie>()
            .HasIndex(b => new {b.Popularity, b.AverageRating, b.ImdbRating})
            .HasDatabaseName("ix_movie_pop_avg_and_imdb_rating")
            .IsDescending();

        //Series
        modelBuilder.Entity<Series>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Series>()
            .Property(b => b.AverageRating)
            .HasDefaultValue("0");

        modelBuilder.Entity<Series>()
            .Property(b => b.ImdbRating)
            .HasDefaultValue("0");    

        modelBuilder.Entity<Series>()
            .Property(b => b.Popularity)
            .HasDefaultValue("0");

        modelBuilder.Entity<Series>()
            .HasIndex(b => new {b.Popularity, b.AverageRating, b.ImdbRating})
            .HasDatabaseName("ix_series_pop_avg_and_imdb_rating")
            .IsDescending();        

        
        //Person
        modelBuilder.Entity<Person>()
            .Property(b => b.Id)
            .HasDefaultValueSql("('nm' || to_char(nextval('public.person_seq'::regclass),'FM00000000'))");

        modelBuilder.Entity<Person>()
            .Property(b => b.Popularity)
            .HasDefaultValue("0");

        modelBuilder.Entity<Person>()
            .HasIndex(b => b.Popularity)
            .HasDatabaseName("ix_person_popularity")
            .IsDescending();

        //Actor
        modelBuilder.Entity<Actor>(e=>
        {
            e.HasNoKey();
        });  

        //WatchlistAll
        modelBuilder.Entity<WatchlistAll>(e=>
        {
            e.HasNoKey();
        });   
        
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
            .Property(b => b.Watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

       //WatchlistSeries
        modelBuilder.Entity<WatchlistSeries>()
            .HasKey(b => new { b.UserId, b.SeriesId });

        modelBuilder.Entity<WatchlistSeries>()
            .Property(b => b.Watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

       //RatingAll
           modelBuilder.Entity<RatingALL>(e=>
            {
                e.HasNoKey();
            });   
    
        //RatingEpisode
        modelBuilder.Entity<RatingEpisode>()
            .HasKey(b => new { b.UserId, b.EpisodeId });    

        //RatingMovie
        modelBuilder.Entity<RatingMovie>()
            .HasKey(b => new { b.UserId, b.MovieId });

        //RatingSeries
        modelBuilder.Entity<RatingSeries>()
            .HasKey(b => new { b.UserId, b.SeriesId });

        //RecentViewAll
        modelBuilder.Entity<RecentViewAll>(e=>
        {
            e.HasNoKey();
        });

        //RecentView
        modelBuilder.Entity<RecentView>(e =>
    {
        e.HasKey(b => new { b.UserId, b.TypeId });

        e.Property(b => b.ViewOrdering)
        .HasColumnName("view_ordering")
        .HasColumnType("bigint")
        .ValueGeneratedOnAdd()
        .Metadata.SetBeforeSaveBehavior(PropertySaveBehavior.Ignore);
                
        e.Property(b => b.ViewOrdering)
            .Metadata.SetAfterSaveBehavior(PropertySaveBehavior.Ignore);
    });
                          
    }
} 