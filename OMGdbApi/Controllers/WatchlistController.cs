using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using OMGdbApi.Models;
using OMGdbApi.Models.Users.Watchlist;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/user/")]
    [ApiController]
    public class WatchlistController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new(); 

        public WatchlistController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;
            
            _validateIDs = validateIDs;
        }

        ///////////////////////////////////////////////watchlist/"ALL"////////////////////////////////////////////////////////////////////////////
        
        // GET: api/user/{UserId}/watchlist
        [HttpGet("{UserId}/watchlist")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<WatchlistAll>>> GetWatchlist(
            string UserId,
            int? pageSize,
            int? pageNumber
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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
                .WatchlistAll.FromSqlInterpolated($"SELECT * FROM get_user_watchlist({UserId})")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) > totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
            }

            return await _context
                .WatchlistAll.FromSqlInterpolated($"SELECT * FROM get_user_watchlist({UserId})")
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        ///////////////////////////////////////////////watchlist/episode///////////////////////////////////////////////

        // GET: api/user/{UserId}/watchlist/episode/{EpisodeId}
        [HttpGet("{UserId}/watchlist/episode/{EpisodeId}")]
        [Authorize]
        public async Task<ActionResult<WatchlistEpisode>> GetWatchlistEpisode(
            string UserId,
            string EpisodeId
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(EpisodeId))
            {
                return BadRequest("Invalid EpisodeId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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
        public async Task<ActionResult<WatchlistEpisode>> PostWatchlistEpisode(
            WatchlistEpisode watchlistEpisode
        )
        {
            if (!_validateIDs.ValidateUserId(watchlistEpisode.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(watchlistEpisode.EpisodeId))
            {
                return BadRequest("Invalid EpisodeId");
            }

            if (!UserExists(watchlistEpisode.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(watchlistEpisode.EpisodeId!))
            {
                return BadRequest("Episode dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != watchlistEpisode.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.WatchlistEpisode.Add(watchlistEpisode);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (WatchlistEpisodeExists(watchlistEpisode.UserId!, watchlistEpisode.EpisodeId!))
                {
                    return Conflict("Episode already in User watchlist");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetWatchlistEpisode),
                new { watchlistEpisode.UserId, watchlistEpisode.EpisodeId },
                watchlistEpisode
            );
        }

        // DELETE: api/{UserId}/watchlist/episode/{EpisodeId}
        [HttpDelete("{UserId}/watchlist/episode/{EpisodeId}")]
        [Authorize]
        public async Task<IActionResult> DeleteWatchlistEpisode(string UserId, string EpisodeId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(EpisodeId))
            {
                return BadRequest("Invalid EpisodeId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!EpisodeExists(EpisodeId))
            {
                return BadRequest("Episode dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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
        public async Task<ActionResult<WatchlistMovie>> GetWatchlistMovie(
            string UserId,
            string MovieId
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(MovieId))
            {
                return BadRequest("Invalid MovieId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!MovieExists(MovieId))
            {
                return BadRequest("Movie dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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
        public async Task<ActionResult<WatchlistMovie>> PostWatchlistMovie(
            WatchlistMovie watchlistMovie
        )
        {
            if (!_validateIDs.ValidateUserId(watchlistMovie.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(watchlistMovie.MovieId))
            {
                return BadRequest("Invalid MovieId");
            }

            if (!UserExists(watchlistMovie.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!MovieExists(watchlistMovie.MovieId!))
            {
                return BadRequest("Movie dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != watchlistMovie.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.WatchlistMovie.Add(watchlistMovie);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (WatchlistMovieExists(watchlistMovie.UserId!, watchlistMovie.MovieId!))
                {
                    return Conflict("Movie already in User watchlist");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetWatchlistMovie),
                new { watchlistMovie.UserId, watchlistMovie.MovieId },
                watchlistMovie
            );
        }

        // DELETE: api/{UserId}/watchlist/movie/{MovieId}
        [HttpDelete("{UserId}/watchlist/movie/{MovieId}")]
        [Authorize]
        public async Task<IActionResult> DeleteWatchlistMovie(string UserId, string MovieId)
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(MovieId))
            {
                return BadRequest("Invalid MovieId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!MovieExists(MovieId))
            {
                return BadRequest("Movie dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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
        public async Task<ActionResult<WatchlistSeries>> GetWatchlistSeries(
            string UserId,
            string SeriesId
        )
        {
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(SeriesId))
            {
                return BadRequest("Invalid SeriesId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!SeriesExists(SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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
        public async Task<ActionResult<WatchlistSeries>> PostWatchlistSeries(
            WatchlistSeries watchlistSeries
        )
        {
            if (!_validateIDs.ValidateUserId(watchlistSeries.UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(watchlistSeries.SeriesId))
            {
                return BadRequest("Invalid SeriesId");
            }

            if (!UserExists(watchlistSeries.UserId!))
            {
                return BadRequest("User dose not exist");
            }

            if (!SeriesExists(watchlistSeries.SeriesId!))
            {
                return BadRequest("Series dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != watchlistSeries.UserId)
            {
                return Unauthorized("Unauthorized");
            }

            _context.WatchlistSeries.Add(watchlistSeries);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (WatchlistSeriesExists(watchlistSeries.UserId!, watchlistSeries.SeriesId!))
                {
                    return Conflict("Series already in User watchlist");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(
                nameof(GetWatchlistSeries),
                new { watchlistSeries.UserId, watchlistSeries.SeriesId },
                watchlistSeries
            );
        }

        // DELETE: api/{UserId}/watchlist/series/{SeriesId}
        [HttpDelete("{UserId}/watchlist/series/{SeriesId}")]
        [Authorize]
        public async Task<IActionResult> DeleteWatchlistSeries(string UserId, string SeriesId)
        {
            
            if (!_validateIDs.ValidateUserId(UserId))
            {
                return BadRequest("Invalid UserId");
            }

            if (!_validateIDs.ValidateTitleId(SeriesId))
            {
                return BadRequest("Invalid SeriesId");
            }

            if (!UserExists(UserId))
            {
                return BadRequest("User dose not exist");
            }

            if (!SeriesExists(SeriesId))
            {
                return BadRequest("Series dose not exist");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != UserId)
            {
                return Unauthorized("Unauthorized");
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

        private bool UserExists(string UserId)
        {
            return _context.Users.Any(e => e.Id == UserId);
        }

        private bool WatchlistEpisodeExists(string UserId, string EpisodeId)
        {
            return _context.WatchlistEpisode.Any(e =>
                e.UserId == UserId && e.EpisodeId == EpisodeId
            );
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
