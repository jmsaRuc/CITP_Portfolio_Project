using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;

namespace OMGdbApi.Controllers
{
    [Route("api/series")]
    [ApiController]
    public class SeriesController : ControllerBase
    {
        private readonly OMGdbContext _context;

        public SeriesController(OMGdbContext context)
        {
            _context = context;
        }

        // GET: api/Series
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Series>>> GetSeries()
        {
            return await _context.Series.ToListAsync();
        }

        // GET: api/Series/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Series>> GetSeries(string id)
        {
            var series = await _context.Series.FindAsync(id);

            if (series == null)
            {
                return NotFound();
            }

            return series;
        }
    }
}
