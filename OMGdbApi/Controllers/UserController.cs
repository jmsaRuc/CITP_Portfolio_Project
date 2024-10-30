using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using OMGdbApi.Models;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/user")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly OMGdbContext _context;
        private readonly Hashing _hasing = new Hashing();

        public UserController(OMGdbContext context, Hashing hasing)
        {
            _context = context;

            _hasing = hasing;
        }

        // GET: api/user
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetUsers()
        {
            return await _context.Users.ToListAsync();
        }

        // GET: api/user/5
        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetUser(string id)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound();
            }

            return user;
        }

        // PUT: api/user/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUser(string email, string id, User user)
        {
            if (id != user.Id)
            {
                return BadRequest();
            }

            _context.Entry(user).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!UserExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/user/create
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("create")]
        public async Task<ActionResult<User>> CreateUser(
            string userName,
            string loginPassword,
            string user_email
        )
        {
            if (
                string.IsNullOrEmpty(userName)
                || string.IsNullOrEmpty(loginPassword)
                || string.IsNullOrEmpty(user_email)
            )
            {
                return BadRequest();
            }

            (var hashedPWD, var salt) = _hasing.Hash(loginPassword);

            var user = new User
                {
                    Name = userName,
                    Password = hashedPWD,
                    Salt = salt,
                    Email = user_email,
                };

            _context.Users.Add(
                user
            );
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (UserExists(userName))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
        }

         // PUT: api/user/login
        [HttpPut("login")]
        public async Task<ActionResult<User>> Login(
            string email,
            string loginPassword
        )
        {
            if (
                string.IsNullOrEmpty(email)
                || string.IsNullOrEmpty(loginPassword)
            )
            {
                return BadRequest();
            }

            var user = await _context.Users.FindAsync(email);
            

            if (user == null || user.Email == null || user.Password == null || user.Salt == null)
            {
                return NotFound();
            }

            if (!_hasing.Verify(loginPassword, user.Password, user.Salt))
            {
                return Unauthorized();
            }

            var claims = new List<Claim>
            {
                new(ClaimTypes.Name, user.Email),
                new(ClaimTypes.NameIdentifier, user.Email),
            };

            var secret = Environment.GetEnvironmentVariable("JWT_SECRET");

            if (string.IsNullOrEmpty(secret))
            {
                return StatusCode(500);
            }

            var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(secret));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                issuer: "OMGdbApi",
                audience: "OMGdbApi",
                claims: claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);

            return Ok(new { email = user.Email, token = jwt });
        }


        // DELETE: api/User/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool UserExists(string id)
        {
            return _context.Users.Any(e => e.Id == id);
        }

    }
}
