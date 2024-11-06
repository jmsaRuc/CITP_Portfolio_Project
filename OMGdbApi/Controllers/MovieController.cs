using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;

namespace OMGdbApi.Controllers
{
    [Route("api/movie")]
    [ApiController]
    public class MovieController : ControllerBase
    {
        private readonly OMGdbContext _context;

        public MovieController(OMGdbContext context)
        {
            _context = context;
        }

        // GET: api/Movie
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Movie>>> GetMovie(int? pageSize, int? pageNumber)
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
            
            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }   

            return await _context.Movie
            .AsNoTracking()
            .OrderByDescending(x => x.Popularity)
            .Skip((int)((pageNumber - 1) * pageSize))
            .Take((int)pageSize)
            .ToListAsync();
        }


        // GET: api/Movie/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Movie>> GetMovie(string id)
        {
            var movie = await _context.Movie.FindAsync(id);

            if (movie == null)
            {
                return NotFound();
            }

            return movie;
        }
        
    }
}
