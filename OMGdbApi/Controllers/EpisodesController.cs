using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using System.Linq; 
namespace OMGdbApi.Controllers
{
    [Route("api/episodes")]
    [ApiController]
    public class EpisodesController : ControllerBase
    {
        private readonly OMGdbContext _context;

        public EpisodesController(OMGdbContext context)
        {
            _context = context;
        }

        // GET: api/Episodes
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

        // GET: api/Episodes/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Episodes>> GetEpisodes(string id)
        {
            var episodes = await _context.Episodes.FindAsync(id);

            if (episodes == null)
            {
                return NotFound();
            }

            return episodes;
        }
    }

}  

