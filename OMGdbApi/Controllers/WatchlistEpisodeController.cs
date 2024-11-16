using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Models.Users.Watchlist;
using OMGdbApi.Service;
using System.Security.Claims;

namespace OMGdbApi.Controllers
{
    [Route("api/user/")]
    [ApiController]
    public class WatchlistEpisodeController : ControllerBase
    {
        private readonly OMGdbContext _context;
        
        public WatchlistEpisodeController(OMGdbContext context)
        {
            _context = context;
        }

    

        // GET: api/user/{UserId}/watchlist/episode/{EpisodeId}
        [HttpGet("{UserId}/watchlist/episode/{EpisodeId}")]
        [Authorize]
        public async Task<ActionResult<WatchlistEpisode>> GetWatchlistEpisode(string UserId, string EpisodeId)
        {   
            if (UserId == null || EpisodeId == null)
            {
                return BadRequest();
            }

            
            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (token_id != UserId)
            {
                return Unauthorized();
            }

            if (!EpisodeExists(EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var watchlistEpisode = await _context.WatchlistEpisode.FindAsync(UserId, EpisodeId);

            if (watchlistEpisode == null)
            {
                return NotFound();
            }

            return watchlistEpisode;
        }

        // POST: api/WatchlistEpisode
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("watchlist/episode")]
        [Authorize]
        public async Task<ActionResult<WatchlistEpisode>> PostWatchlistEpisode(WatchlistEpisode watchlistEpisode)
        {   
            

            if (watchlistEpisode.UserId == null || watchlistEpisode.EpisodeId == null)
            {
                return BadRequest("UserId or EpisodeId is null");
            }


            if (!UserExists(watchlistEpisode.UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (token_id != watchlistEpisode.UserId)
            {
                return Unauthorized();
            }

            if (!EpisodeExists(watchlistEpisode.EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            _context.WatchlistEpisode.Add(watchlistEpisode);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (WatchlistEpisodeExists(watchlistEpisode.UserId, watchlistEpisode.EpisodeId))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(GetWatchlistEpisode), new { watchlistEpisode.UserId, watchlistEpisode.EpisodeId }, watchlistEpisode);
        }

        // DELETE: api/WatchlistEpisode/5
        [HttpDelete("{UserId}/watchlist/episode/{EpisodeId}")]
        [Authorize]
        public async Task<IActionResult> DeleteWatchlistEpisode(string UserId, string EpisodeId)
        {
            if (UserId == null || EpisodeId == null)
            {
                return BadRequest();
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (token_id != UserId)
            {
                return Unauthorized();
            }

            if (!EpisodeExists(EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var watchlistEpisode = await _context.WatchlistEpisode.FindAsync(UserId, EpisodeId);
            if (watchlistEpisode == null)
            {
                return NotFound();
            }

            _context.WatchlistEpisode.Remove(watchlistEpisode);
            await _context.SaveChangesAsync();

            return Ok();
        }

        private bool WatchlistEpisodeExists(string UserId, string EpisodeId)
        {
            return _context.WatchlistEpisode.Any(e => e.UserId == UserId && e.EpisodeId == EpisodeId);
        }

        private bool UserExists(string  UserId)
        {
            return _context.Users.Any(e => e.Id ==  UserId);
        }

        private bool EpisodeExists(string EpisodeId)
        {
            return _context.Episodes.Any(e => e.Id == EpisodeId);
        }
    }
}
