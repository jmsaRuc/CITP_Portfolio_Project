using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Models.Users.Recent_View;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/genre")]
    [ApiController]
    public class GenreController : ControllerBase
    {
        private readonly OMGdbContext _context;
        private readonly ValidateIDs _validateIDs = new();

        public GenreController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;

            _validateIDs = validateIDs;
        }

        //////////////////////////////////////////////////////////////////////////base genre/////////////////////////////////////////////////////////////////////////

        // Get: api/genre
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GenreAll>>> GetGenreAll(
            int? pageSize,
            int? pageNumber
        )
        {
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }

            var totalRecords = await _context
                .Genre.FromSqlInterpolated($"SELECT * FROM public.get_all_genres()")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            return await _context
                .GenreAll.FromSqlInterpolated($"SELECT * FROM public.get_all_genres()")
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        // Get: api/genre/{name}
        [HttpGet("{GenreName}")]
        public async Task<ActionResult<Genre>> GetGenre(string GenreName)
        {
            _validateIDs.PossibleGenreNames = (await GetGenreAll(32, 1))?.Value?.ToArray();

            if (!_validateIDs.ValidateGenreName(GenreName))
            {
                return NotFound("Genre not found");
            }

            var genre = await _context
                .Genre.FromSqlInterpolated($"SELECT * FROM public.get_genre({GenreName})")
                .AsNoTracking()
                .FirstOrDefaultAsync();

            if (genre == null)
            {
                return NotFound("Genre does not exist");
            }

            return genre;
        }

        //////////////////////////////////////////////////////////////////////////genre/{GenreName}/titles/////////////////////////////////////////////////////////////////////////

        // Get: api/genre/{GenreName}/movies
        [HttpGet("{GenreName}/movies")]
        public async Task<ActionResult<IEnumerable<Movie>>> GetGenreMovies(
            string GenreName,
            int? pageSize,
            int? pageNumber,
            string? sortBy
        )
        {
            _validateIDs.PossibleGenreNames = (await GetGenreAll(32, 1))?.Value?.ToArray();

            if (!_validateIDs.ValidateGenreName(GenreName))
            {
                return NotFound("Genre not found");
            }

            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }

            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }

            var totalRecords = await _context
                .Movie.FromSqlInterpolated($"SELECT * FROM public.get_genre_movies({GenreName})")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            var movie =
                from e in _context.Movie.FromSqlInterpolated(
                    $"SELECT * FROM public.get_genre_movies({GenreName})"
                )
                select e;

            switch (sortBy)
            {
                case "imdbRating":
                    movie = movie
                        .OrderByDescending(e => e.ImdbRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                case "averageRating":
                    movie = movie
                        .OrderByDescending(e => e.AverageRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                case "releaseDate":
                    movie = movie
                        .OrderByDescending(e => e.ReleaseDate.HasValue)
                        .ThenByDescending(e => e.ReleaseDate)
                        .ThenByDescending(e => e.Popularity);
                    break;
                default:
                    movie = movie.OrderByDescending(e => e.Popularity);
                    break;
            }

            return await movie
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        // Get: api/genre/{GenreName}/series
        [HttpGet("{GenreName}/series")]
        public async Task<ActionResult<IEnumerable<Series>>> GetGenreSeries(
            string GenreName,
            int? pageSize,
            int? pageNumber,
            string? sortBy
        )
        {
            _validateIDs.PossibleGenreNames = (await GetGenreAll(32, 1))?.Value?.ToArray();

            if (!_validateIDs.ValidateGenreName(GenreName))
            {
                return NotFound("Genre not found");
            }

            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }

            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }

            var totalRecords = await _context
                .Series.FromSqlInterpolated($"SELECT * FROM public.get_genre_series({GenreName})")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            var series =
                from e in _context.Series.FromSqlInterpolated(
                    $"SELECT * FROM public.get_genre_series({GenreName})"
                )
                select e;

            switch (sortBy)
            {
                case "imdbRating":
                    series = series
                        .OrderByDescending(e => e.ImdbRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                case "averageRating":
                    series = series
                        .OrderByDescending(e => e.AverageRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                case "releaseDate":
                    series = series
                        .OrderByDescending(e => e.StartYear == null)
                        .ThenByDescending(e => e.StartYear)
                        .ThenByDescending(e => e.Popularity);
                    break;
                default:
                    series = series.OrderByDescending(e => e.Popularity);
                    break;
            }

            return await series
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        // Get: api/genre/{GenreName}/episodes
        [HttpGet("{GenreName}/episodes")]
        public async Task<ActionResult<IEnumerable<Episode>>> GetGenreEpisodes(
            string GenreName,
            int? pageSize,
            int? pageNumber,
            string? sortBy
        )
        {
            _validateIDs.PossibleGenreNames = (await GetGenreAll(32, 1))?.Value?.ToArray();

            if (!_validateIDs.ValidateGenreName(GenreName))
            {
                return NotFound("Genre not found");
            }

            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }

            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }

            var totalRecords = await _context
                .Episode.FromSqlInterpolated(
                    $"SELECT * FROM public.get_genre_episodes({GenreName})"
                )
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            var episode =
                from e in _context.Episode.FromSqlInterpolated(
                    $"SELECT * FROM public.get_genre_episodes({GenreName})"
                )
                select e;

            switch (sortBy)
            {
                case "imdbRating":
                    episode = episode
                        .OrderByDescending(e => e.ImdbRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                case "averageRating":
                    episode = episode
                        .OrderByDescending(e => e.AverageRating)
                        .ThenByDescending(e => e.Popularity);
                    break;
                case "releaseDate":
                    episode = episode
                        .OrderByDescending(e => e.ReleaseDate.HasValue)
                        .ThenByDescending(e => e.ReleaseDate)
                        .ThenByDescending(e => e.Popularity);
                    break;
                default:
                    episode = episode.OrderByDescending(e => e.Popularity);
                    break;
            }

            return await episode
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }
    }
}
