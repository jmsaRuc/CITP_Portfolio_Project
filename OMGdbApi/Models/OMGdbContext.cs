using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Npgsql;
using OMGdbApi.Models.Generic;
using OMGdbApi.Models.Users;
using OMGdbApi.Models.Users.Ratings;
using OMGdbApi.Models.Users.Recent_View;
using OMGdbApi.Models.Users.Watchlist;

namespace OMGdbApi.Models;

public class OMGdbContext : DbContext
{
    public OMGdbContext(DbContextOptions<OMGdbContext> options)
        : base(options) { }

    ////// "Main" Entitys

    public DbSet<Episode> Episode { get; set; } = null!;

    public DbSet<Movie> Movie { get; set; } = null!;

    public DbSet<Series> Series { get; set; } = null!;

    public DbSet<SeriesEpisode> SeriesEpisode { get; set; } = null!;

    // Person
    public DbSet<Person> Person { get; set; } = null!;

    public DbSet<Actor> Actor { get; set; } = null!;

    public DbSet<CastNotActor> CastNotActor { get; set; } = null!;

    public DbSet<PersonCredit> PersonCredit { get; set; } = null!;

    public DbSet<GenreAll> GenreAll { get; set; } = null!;

    public DbSet<Genre> Genre { get; set; } = null!;

    ////// User
    public DbSet<User> Users { get; set; } = null!;

    // Watchlist
    public DbSet<WatchlistAll> WatchlistAll { get; set; } = null!;

    public DbSet<WatchlistEpisode> WatchlistEpisode { get; set; } = null!;

    public DbSet<WatchlistMovie> WatchlistMovie { get; set; } = null!;

    public DbSet<WatchlistSeries> WatchlistSeries { get; set; } = null!;

    // Rating
    public DbSet<RatingALL> RatingALL { get; set; } = null!;

    public DbSet<RatingEpisode> RatingEpisode { get; set; } = null!;

    public DbSet<RatingMovie> RatingMovie { get; set; } = null!;

    public DbSet<RatingSeries> RatingSeries { get; set; } = null!;

    // RecentView
    public DbSet<RecentViewAll> RecentViewAll { get; set; } = null!;

    public DbSet<RecentView> RecentView { get; set; } = null!;

    ////// Generic

    public DbSet<TopWeeklyTitles> TopWeeklyTitles { get; set; } = null!;

    public DbSet<SearchResult> SearchResult { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        /////////////////////////////////////////"Main" Entitys/////////////////////////////////////////

        //Episode
        modelBuilder
            .Entity<Episode>()
            .Property(b => b.Id)
            .HasDefaultValueSql(
                "('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))"
            );

        modelBuilder.Entity<Episode>().Property(b => b.AverageRating).HasDefaultValue("0");

        modelBuilder.Entity<Episode>().Property(b => b.ImdbRating).HasDefaultValue("0");

        modelBuilder.Entity<Episode>().Property(b => b.Popularity).HasDefaultValueSql("0");

        modelBuilder
            .Entity<Episode>()
            .HasIndex(b => new
            {
                b.Popularity,
                b.AverageRating,
                b.ImdbRating,
                b.ReleaseDate,
            })
            .HasDatabaseName("ix_episode_pop_avg_and_imdb_rating")
            .IsDescending();

        //Movie
        modelBuilder
            .Entity<Movie>()
            .Property(b => b.Id)
            .HasDefaultValueSql(
                "('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))"
            );

        modelBuilder.Entity<Movie>().Property(b => b.AverageRating).HasDefaultValue("0");

        modelBuilder.Entity<Movie>().Property(b => b.ImdbRating).HasDefaultValue("0");

        modelBuilder.Entity<Movie>().Property(b => b.Popularity).HasDefaultValue("0");

        modelBuilder
            .Entity<Movie>()
            .HasIndex(b => new
            {
                b.Popularity,
                b.AverageRating,
                b.ImdbRating,
                b.ReleaseDate,
            })
            .HasDatabaseName("ix_movie_pop_avg_and_imdb_rating")
            .IsDescending();

        //Series
        modelBuilder
            .Entity<Series>()
            .Property(b => b.Id)
            .HasDefaultValueSql(
                "('tt' || to_char(nextval('public.title_seq'::regclass),'FM00000000'))"
            );

        modelBuilder.Entity<Series>().Property(b => b.AverageRating).HasDefaultValue("0");

        modelBuilder.Entity<Series>().Property(b => b.ImdbRating).HasDefaultValue("0");

        modelBuilder.Entity<Series>().Property(b => b.Popularity).HasDefaultValue("0");

        modelBuilder
            .Entity<Series>()
            .HasIndex(b => new
            {
                b.Popularity,
                b.AverageRating,
                b.ImdbRating,
                b.StartYear,
            })
            .HasDatabaseName("ix_series_pop_avg_and_imdb_rating")
            .IsDescending();
        //SeriesEpisode
        modelBuilder.Entity<SeriesEpisode>(e =>
        {
            e.HasNoKey();
        });

        //Person
        modelBuilder
            .Entity<Person>()
            .Property(b => b.Id)
            .HasDefaultValueSql(
                "('nm' || to_char(nextval('public.person_seq'::regclass),'FM00000000'))"
            );

        modelBuilder.Entity<Person>().Property(b => b.Popularity).HasDefaultValue("0");

        modelBuilder
            .Entity<Person>()
            .HasIndex(b => b.Popularity)
            .HasDatabaseName("ix_person_popularity")
            .IsDescending();

        //Top_Actor
        modelBuilder.Entity<Actor>(e =>
        {
            e.HasNoKey();
        });

        //CastNoActor
        modelBuilder.Entity<CastNotActor>(e =>
        {
            e.HasNoKey();
        });

        //PersonCredit
        modelBuilder.Entity<PersonCredit>(e =>
        {
            e.HasNoKey();
        });

        //GenreAll
        modelBuilder.Entity<GenreAll>(e =>
        {
            e.HasNoKey();
        });

        //Genre
        modelBuilder.Entity<Genre>(e =>
        {
            e.HasNoKey();
        });

        /////////////////////////////////////////////User/////////////////////////////////////////////

        //User
        modelBuilder
            .Entity<User>()
            .Property(b => b.Id)
            .HasDefaultValueSql(
                "('ur' || to_char(nextval('public.user_seq'::regclass), 'FM00000000'))"
            );

        modelBuilder.Entity<User>().Property(b => b.Created_at).HasDefaultValueSql("getdate()");

        modelBuilder
            .Entity<User>()
            .HasIndex(b => b.Created_at)
            .HasDatabaseName("ix_user_created_at")
            .IsDescending();

        //WatchlistAll
        modelBuilder.Entity<WatchlistAll>(e =>
        {
            e.HasNoKey();
        });

        //WatchlistEpisode
        modelBuilder.Entity<WatchlistEpisode>().HasKey(b => new { b.UserId, b.EpisodeId });

        modelBuilder
            .Entity<WatchlistEpisode>()
            .Property(b => b.Watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

        //WatchlistMovie
        modelBuilder.Entity<WatchlistMovie>().HasKey(b => new { b.UserId, b.MovieId });

        modelBuilder
            .Entity<WatchlistMovie>()
            .Property(b => b.Watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

        //WatchlistSeries
        modelBuilder.Entity<WatchlistSeries>().HasKey(b => new { b.UserId, b.SeriesId });

        modelBuilder
            .Entity<WatchlistSeries>()
            .Property(b => b.Watchlist_order)
            .HasDefaultValueSql("nextval('public.watchlist_seq'::regclass)");

        //RatingAll
        modelBuilder.Entity<RatingALL>(e =>
        {
            e.HasNoKey();
        });

        //RatingEpisode
        modelBuilder.Entity<RatingEpisode>().HasKey(b => new { b.UserId, b.EpisodeId });

        //RatingMovie
        modelBuilder.Entity<RatingMovie>().HasKey(b => new { b.UserId, b.MovieId });

        //RatingSeries
        modelBuilder.Entity<RatingSeries>().HasKey(b => new { b.UserId, b.SeriesId });

        //RecentViewAll
        modelBuilder.Entity<RecentViewAll>(e =>
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

            e.Property(b => b.CreatedAt).HasDefaultValueSql("now()");
        });

        ///////////////////////////////////////////////////Generic///////////////////////////////////////////////

        //TopWeeklyTitles
        modelBuilder.Entity<TopWeeklyTitles>(e =>
        {
            e.HasNoKey();
        });

        modelBuilder
            .Entity<TopWeeklyTitles>()
            .HasIndex(b => new
            {
                b.Popularity,
                b.DailyTimeStampFromRecentV,
                b.AverageRating,
                b.ImdbRating,
            })
            .HasDatabaseName("ix_t_week_pop_avg_and_imdb_rating")
            .IsDescending();

        modelBuilder
            .Entity<TopWeeklyTitles>()
            .HasIndex(b => b.TitleId)
            .HasDatabaseName("ix_t_week_type_id");

        //Search
        modelBuilder.Entity<SearchResult>(e =>
        {
            e.HasNoKey();
        });
    }
}
