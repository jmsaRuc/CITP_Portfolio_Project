﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/series")]
    [ApiController]
    public class SeriesController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new();

        public SeriesController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;
            _validateIDs = validateIDs;
        }

        // GET: api/Series
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Series>>> GetSeries(int? pageSize, int? pageNumber)
        {
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1) 
            {
                pageNumber = 1;
            }
            var totalRecords = await _context.Series.CountAsync();
            
            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }   

            return await _context.Series
            .AsNoTracking()
            .OrderBy(x => x.Popularity)
            .Skip((int)((pageNumber - 1) * pageSize))
            .Take((int)pageSize)
            .ToListAsync();
        }

        // GET: api/Series/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Series>> GetSeries(string id)
        {   
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            var series = await _context.Series.FindAsync(id);

            if (series == null)
            {
                return NotFound("No series found with this id");
            }

            return series;
        }

        // PUT: api/Series/{id}/actors
        [HttpGet("{id}/actors")]
        public async Task<ActionResult<IEnumerable<Actor>>> GetActor(string id, int? pageSize, int? pageNumber)
        {
            if (!_validateIDs.ValidateTitleId(id))
            {
                return BadRequest("Invalid title id");
            }

            if (!SeriesExists(id))
            {
                return BadRequest("Series dose not exist");
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
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_series({id})")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }

            return await _context
                .Actor.FromSqlInterpolated($"SELECT * FROM get_top_actors_in_series({id})")
                .AsNoTracking()
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();

        }
        
        private bool SeriesExists(string id)
        {
            return _context.Series.Any(e => e.Id == id);
        }
    }
}
