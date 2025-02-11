﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Models;
using OMGdbApi.Service;

namespace OMGdbApi.Controllers
{
    [Route("api/person")]
    [ApiController]
    public class PersonController : ControllerBase
    {
        private readonly OMGdbContext _context;

        private readonly ValidateIDs _validateIDs = new();

        public PersonController(OMGdbContext context, ValidateIDs validateIDs)
        {
            _context = context;
            _validateIDs = validateIDs;
        }

        // GET: api/Person
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Person>>> GetPerson(
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
            var totalRecords = await _context.Person.CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);

                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            return await _context
                .Person.AsNoTracking()
                .OrderByDescending(x => x.Popularity)
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        // GET: api/Person/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Person>> GetPerson(string id)
        {
            if (!_validateIDs.ValidatePersonId(id))
            {
                return BadRequest("Invalid person id");
            }
            var person = await _context.Person.FindAsync(id);

            if (person == null)
            {
                return NotFound("Person does not exist");
            }

            return person;
        }

        // GET: api/person/{id}/credit
        [HttpGet("{id}/credit")]
        public async Task<ActionResult<IEnumerable<PersonCredit>>> GetPersonCredit(
            string id,
            int? pageSize,
            int? pageNumber
        )
        {
            if (!_validateIDs.ValidatePersonId(id))
            {
                return BadRequest("Invalid person id");
            }

            if (!PersonExists(id))
            {
                return BadRequest("Person does not exist");
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
                .PersonCredit.FromSqlInterpolated($"SELECT * FROM get_person_credit({id})")
                .CountAsync();

            if ((int)((pageNumber - 1) * pageSize) >= totalRecords)
            {
                pageNumber = (int)Math.Ceiling((double)totalRecords / (double)pageSize);
                if (pageNumber <= 0)
                {
                    pageNumber = 1;
                }
            }

            return await _context
                .PersonCredit.FromSqlInterpolated($"SELECT * FROM get_person_credit({id})")
                .AsNoTracking()
                .OrderByDescending(x => x.Popularity)
                .Skip((int)((pageNumber - 1) * pageSize))
                .Take((int)pageSize)
                .ToListAsync();
        }

        private bool PersonExists(string id)
        {
            return _context.Person.Any(e => e.Id == id);
        }
    }
}
