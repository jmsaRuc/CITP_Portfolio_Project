using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/movie")]
    [ApiController]
    public class MovieController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new();

        public MovieController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;
            _validateIDs = validateIDs;
        }

        // GET: api/movie
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Movie>>> GetMovie(int? pageSize, int? pageNumber, string? sortBy)
        {
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1) 
            {
                pageNumber = 1;
            }
            var totalRecords = await _context.Movie.CountAsync();
            
            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

             var movie = from e in _context.Movie select e;

            switch (sortBy)
            {
                case "imdbRating":
                    movie = movie.OrderByDescending(e => e.ImdbRating);
                    break;
                case "averageRating":
                    movie = movie.OrderByDescending(e => e.AverageRating);
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


        // GET: api/movie/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Movie>> GetMovie(string id)
        {
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            var movie = await _context.Movie.FindAsync(id);

            if (movie == null)
            {
                return NotFound("No movie found with this id");
            }

            return movie;
        }

        // GET: api/movie/{id}/actors
        [HttpGet("{id}/actors")]
        public async Task<ActionResult<IEnumerable<Actor>>> GetMovieActors(string id, int? pageSize, int? pageNumber)
        {
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            if (!MovieExists(id))
            {
                return BadRequest("Movie does not exist");
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
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_movie({id})")
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
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_movie({id})")
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        private bool MovieExists(string id)
        {
            return _context.Movie.Any(e => e.Id == id);
        }
        
    }
}
