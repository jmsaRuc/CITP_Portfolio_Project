using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Service;
namespace OMGdbApi.Controllers
{
    [Route("api/episodes")]
    [ApiController]
    public class EpisodesController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new();

        public EpisodesController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;

            _validateIDs = validateIDs;
        }

        // GET: api/episodes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Episodes>>> GetEpisodes(int? pageSize, int? pageNumber)
        {    
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1) 
            {
                pageNumber = 1;
            }
            var totalRecords = await _context.Episodes.CountAsync();
            
            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }   
            
            return await _context.Episodes
                .AsNoTracking()
                .OrderByDescending(x => x.Popularity)
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        // GET: api/episodes/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Episodes>> GetEpisodes(string id)
        {   
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            var episodes = await _context.Episodes.FindAsync(id);

            if (episodes == null)
            {
                return NotFound("No episode found with this id");
            }

            return episodes;
        }
        
        // GET: api/episodes/{id}/actors
        [HttpGet("{id}/actors")]
        public async Task<ActionResult<IEnumerable<Actor>>> GetActor(string id, int? pageSize, int? pageNumber)
        {
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            if (!EpisodesExists(id))
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

            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }

            return await _context
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_episode({id})")
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();

        }

        private bool EpisodesExists(string id)
        {
            return _context.Episodes.Any(e => e.Id == id);
        }
    }

}  

