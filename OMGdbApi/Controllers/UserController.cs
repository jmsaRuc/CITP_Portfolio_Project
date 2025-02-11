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
using OMGdbApi.Models.Users;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/user")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly OMGdbContext _context;
        private readonly Hashing _hasing = new();

        private readonly ValidateIDs _validateIDs = new();

        public UserController(OMGdbContext context, Hashing hasing, ValidateIDs validateIDs)
        {
            _context = context;

            _hasing = hasing;

            _validateIDs = validateIDs;
        }

        // GET: api/user
        [HttpGet]
        [Authorize]
        public async Task<ActionResult<IEnumerable<UserDTO>>> GetUsers(
            int? pageSize,
            int? pageNumber
        )
        {
            if (pageSize == null || pageSize < 1 || pageSize > 1000)
            {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber < 1)
            {
                pageNumber = 1;
            }
            var totalRecords = await _context.Users.CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            return await _context
                .Users.OrderByDescending(x => x.Created_at)
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .Select(x => UserDTO(x))
                .ToListAsync();
        }

        // GET: api/user/5
        [HttpGet("{id}")]
        [Authorize]
        public async Task<ActionResult<UserDTO>> GetUser(string id)
        {
            if (!_validateIDs.ValidateUserId(id))
            {
                return BadRequest("Invalid User Id");
            }

            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound("User not found");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != user.Id)
            {
                return Unauthorized("Unauthorized");
            }

            return UserDTO(user);
        }

        // PUT: api/user/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        [Authorize]
        public async Task<ActionResult<UserDTO>> PutUser(string id, string name, string email)
        {
            if (!_validateIDs.ValidateUserId(id))
            {
                return BadRequest("Invalid User Id");
            }

            if (
                string.IsNullOrEmpty(name)
                || string.IsNullOrEmpty(email)
                || string.IsNullOrEmpty(id)
            )
            {
                return BadRequest("Name, email or id is null");
            }

            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound("User not found");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != user.Id)
            {
                return Unauthorized("Unauthorized");
            }

            user.Name = name;
            user.Email = email;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) when (!UserExists(id))
            {
                return NotFound("User not found");
            }

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, UserDTO(user));
        }

        // POST: api/user/create
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("create")]
        public async Task<ActionResult<UserDTO>> CreateUser(UserCreate userCreate)
        {
            if (
                string.IsNullOrEmpty(userCreate.Name)
                || string.IsNullOrEmpty(userCreate.Password)
                || string.IsNullOrEmpty(userCreate.Email)
            )
            {
                return BadRequest("Name, password or email is null");
            }

            // Check if email already exists
            if (_context.Users.Any(u => u.Email == userCreate.Email))
            {
                return Conflict("Email already exists.");
            }

            (var hashedPWD, var salt) = _hasing.Hash(userCreate.Password);

            var user = new User
            {
                Name = userCreate.Name,
                Password = hashedPWD,
                Salt = salt,
                Email = userCreate.Email,
            };

            _context.Users.Add(user);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (user.Id != null && UserExists(user.Id))
                {
                    return Conflict("User already exists.");
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, UserDTO(user));
        }

        // PUT: api/user/login
        [HttpPut("login")]
        public async Task<ActionResult<UserLogin>> Login(string email, string loginPassword)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(loginPassword))
            {
                return BadRequest("Email or password is null or empty");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null || user.Email == null || user.Password == null || user.Salt == null)
            {
                return NotFound("No user found with this email");
            }

            if (_validateIDs.ValidateUserId(user.Id) && !UserExists(user.Id!))
            {
                return NotFound("User does not exists");
            }

            if (!_hasing.Verify(loginPassword, user.Password, user.Salt))
            {
                return Unauthorized("Invalid password");
            }

            var claims = new List<Claim>();

            if (user.Id != null)
            {
                claims.Add(new Claim(ClaimTypes.Name, user.Id));
                claims.Add(new Claim(ClaimTypes.NameIdentifier, user.Id));
            }
            else
            {
                return NotFound("No user exists");
            }

            var secret = Environment.GetEnvironmentVariable("JWT_SECRET");

            if (string.IsNullOrEmpty(secret))
            {
                Console.WriteLine("ERROR: JWT_SECRET is not set");

                return StatusCode(500);
            }

            var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(secret));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                issuer: "OMGdbApi",
                audience: "OMGdbApi",
                claims: claims,
                expires: DateTime.Now.AddMinutes(1440),
                signingCredentials: creds
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);

            return Ok(new UserLogin { Id = user.Id, Token = jwt });
        }

        // DELETE: api/User/5
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteUser(string id)
        {
            if (!_validateIDs.ValidateUserId(id))
            {
                return BadRequest("Invalid User Id");
            }

            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound("User not found");
            }

            var token_id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (token_id != user.Id)
            {
                return Unauthorized();
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok();
        }

        private bool UserExists(string id)
        {
            return _context.Users.Any(e => e.Id == id);
        }

        private static UserDTO UserDTO(User user) =>
            new UserDTO
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email,
                Created_at = user.Created_at,
            };
    }
}
