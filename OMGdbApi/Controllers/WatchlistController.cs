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
    public class WatchlistController : ControllerBase
    {
        private readonly OMGdbContext _context;
        
        public WatchlistController(OMGdbContext context)
        {
            _context = context;
        }

         ///////////////////////////////////////////////watchlist/episode///////////////////////////////////////////////

        // GET: api/user/{UserId}/watchlist/episode/{EpisodeId}
        [HttpGet("{UserId}/watchlist/episode/{EpisodeId}")]
        [Authorize]
        public async Task<ActionResult<WatchlistEpisode>> GetWatchlistEpisode(string UserId, string EpisodeId)
        {   
            if (UserId == null || EpisodeId == null)
            {
                return BadRequest("UserId or EpisodeId is null");
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
                return NotFound("Episode not in User watchlist");
            }

            return watchlistEpisode;
        }

        // POST: api/user/watchlist/episode

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
                    return Conflict("Episode already in User watchlist");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(GetWatchlistEpisode), new { watchlistEpisode.UserId, watchlistEpisode.EpisodeId }, watchlistEpisode);
        }

        // DELETE: api/{UserId}/watchlist/episode/{EpisodeId}
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
                return NotFound("Episode not in User watchlist");
            }

            _context.WatchlistEpisode.Remove(watchlistEpisode);
            await _context.SaveChangesAsync();

            return Ok("Episode removed from User watchlist");
        }

        ///////////////////////////////////////////////watchlist/movie///////////////////////////////////////////////

        // GET: api/user/{UserId}/watchlist/movie/{MovieId}¨
        [HttpGet("{UserId}/watchlist/movie/{MovieId}")]
        [Authorize]
        public async Task<ActionResult<WatchlistMovie>> GetWatchlistMovie(string UserId, string MovieId)
        {   
            if (UserId == null || MovieId == null)
            {
                return BadRequest("UserId or MovieId is null");
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

            if (!MovieExists(MovieId))
            {
                return BadRequest("Movie dose not exist");
            }

            var watchlistMovie = await _context.WatchlistMovie.FindAsync(UserId, MovieId);

            if (watchlistMovie == null)
            {
                return NotFound("Movie not in User watchlist");
            }
           

            return watchlistMovie;
        }

        // POST: api/user/watchlist/movie
        [HttpPost("watchlist/movie")]
        [Authorize]
        public async Task<ActionResult<WatchlistMovie>> PostWatchlistMovie(WatchlistMovie watchlistMovie)
        {   
                
            if (watchlistMovie.UserId == null || watchlistMovie.MovieId == null)
            {
                return BadRequest("UserId or MovieId is null");
            }

        
            if (!UserExists(watchlistMovie.UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != watchlistMovie.UserId)
            {
                return Unauthorized();
            }

            if (!MovieExists(watchlistMovie.MovieId))
            {
                return BadRequest("Movie dose not exist");
            }

            _context.WatchlistMovie.Add(watchlistMovie);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (WatchlistMovieExists(watchlistMovie.UserId, watchlistMovie.MovieId))
                {
                    return Conflict("Movie already in User watchlist");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(GetWatchlistMovie), new { watchlistMovie.UserId, watchlistMovie.MovieId }, watchlistMovie);
        }

        // DELETE: api/{UserId}/watchlist/movie/{MovieId}
        [HttpDelete("{UserId}/watchlist/movie/{MovieId}")]
        [Authorize]
        public async Task<IActionResult> DeleteWatchlistMovie(string UserId, string MovieId)
        {
            if (UserId == null || MovieId == null)
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

            if (!MovieExists(MovieId))
            {
                return BadRequest("Movie dose not exist");
            }

            var watchlistMovie = await _context.WatchlistMovie.FindAsync(UserId, MovieId);
            if (watchlistMovie == null)
            {
                return NotFound("Movie not in User watchlist");
            }

            _context.WatchlistMovie.Remove(watchlistMovie);
            await _context.SaveChangesAsync();

            return Ok("Movie removed from User watchlist");
        }

        ///////////////////////////////////////////////watchlist/series///////////////////////////////////////////////
        
        // GET: api/user/{UserId}/watchlist/series/{SeriesId}
        [HttpGet("{UserId}/watchlist/series/{SeriesId}")]
        [Authorize]
        public async Task<ActionResult<WatchlistSeries>> GetWatchlistSeries(string UserId, string SeriesId)
        {   
            if (UserId == null || SeriesId == null)
            {
                return BadRequest("UserId or SeriesId is null");
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

            if (!SeriesExists(SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            var watchlistSeries = await _context.WatchlistSeries.FindAsync(UserId, SeriesId);

            if (watchlistSeries == null)
            {
                return NotFound("Series not in User watchlist");
            }

            return watchlistSeries;
        }

        // POST: api/user/watchlist/series
        [HttpPost("watchlist/series")]
        [Authorize]
        public async Task<ActionResult<WatchlistSeries>> PostWatchlistSeries(WatchlistSeries watchlistSeries)
        {   
            

            if (watchlistSeries.UserId == null || watchlistSeries.SeriesId == null)
            {
                return BadRequest("UserId or SeriesId is null");
            }

            if (!UserExists(watchlistSeries.UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (token_id != watchlistSeries.UserId)
            {
                return Unauthorized();
            }

            if (!SeriesExists(watchlistSeries.SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            _context.WatchlistSeries.Add(watchlistSeries);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (WatchlistSeriesExists(watchlistSeries.UserId, watchlistSeries.SeriesId))
                {
                    return Conflict("Series already in User watchlist");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(GetWatchlistSeries), new { watchlistSeries.UserId, watchlistSeries.SeriesId }, watchlistSeries);
        }

        // DELETE: api/{UserId}/watchlist/series/{SeriesId}
        [HttpDelete("{UserId}/watchlist/series/{SeriesId}")]
        [Authorize]
        public async Task<IActionResult> DeleteWatchlistSeries(string UserId, string SeriesId)
        {
            if (UserId == null || SeriesId == null)
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

            if (!SeriesExists(SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            var watchlistSeries = await _context.WatchlistSeries.FindAsync(UserId, SeriesId);
            if (watchlistSeries == null)
            {
                return NotFound("Series not in User watchlist");
            }

            _context.WatchlistSeries.Remove(watchlistSeries);
            await _context.SaveChangesAsync();

            return Ok("Series removed from User watchlist");
        }
        
        private bool UserExists(string  UserId)
        {
            return _context.Users.Any(e => e.Id ==  UserId);
        }    
        private bool WatchlistEpisodeExists(string UserId, string EpisodeId)
        {
            return _context.WatchlistEpisode.Any(e => e.UserId == UserId && e.EpisodeId == EpisodeId);
        }

        private bool EpisodeExists(string EpisodeId)
        {
            return _context.Episodes.Any(e => e.Id == EpisodeId);
        }

        private bool WatchlistMovieExists(string UserId, string MovieId)
        {
            return _context.WatchlistMovie.Any(e => e.UserId == UserId && e.MovieId == MovieId);
        }

        private bool MovieExists(string MovieId)
        {
            return _context.Movie.Any(e => e.Id == MovieId);
        }

         private bool WatchlistSeriesExists(string UserId, string MovieId)
        {
            return _context.WatchlistMovie.Any(e => e.UserId == UserId && e.MovieId == MovieId);
        }

        private bool SeriesExists(string MovieId)
        {
            return _context.Series.Any(e => e.Id == MovieId);
        }

    }
}
