using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;

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
        public async Task<ActionResult<IEnumerable<Episodes>>> GetEpisodes()
        {
            return await _context.Episodes.ToListAsync();
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

