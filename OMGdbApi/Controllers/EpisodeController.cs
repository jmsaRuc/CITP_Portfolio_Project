using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Service;
namespace OMGdbApi.Controllers
{
    [Route("api/episode")]
    [ApiController]
    public class EpisodeController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new();

        public EpisodeController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;

            _validateIDs = validateIDs;
        }

        // GET: api/episode
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Episode>>> GetEpisode(int? pageSize, int? pageNumber, string? sortBy)
        {    

            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1) 
            {
                pageNumber = 1;
            }
            var totalRecords = await _context.Episode.CountAsync();
            
            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
                
                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            var episode = from e in _context.Episode select e;

            switch (sortBy)
            {
                case "imdbRating":
                    episode = episode.OrderByDescending(e => e.ImdbRating);
                    break;
                case "averageRating":
                    episode = episode.OrderByDescending(e => e.AverageRating);
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

        // GET: api/episode/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Episode>> GetEpisode(string id)
        {   
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            var episode = await _context.Episode.FindAsync(id);

            if (episode == null)
            {
                return NotFound("No episode found with this id");
            }

            return episode;
        }
        
        // GET: api/episode/{id}/actors
        [HttpGet("{id}/actors")]
        public async Task<ActionResult<IEnumerable<Actor>>> GetActor(string id, int? pageSize, int? pageNumber)
        {
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            if (!EpisodeExists(id))
            {
                return BadRequest("Episode dose not exist");
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
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_episode({id})")
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
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_episode({id})")
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();

        }

        private bool EpisodeExists(string id)
        {
            return _context.Episode.Any(e => e.Id == id);
        }
    }

}  

