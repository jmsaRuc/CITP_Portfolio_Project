using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OMGdbApi.Controllers;  // Adjust if necessary to match actual controller   
using OMGdbApi.Models;  // Adjust if necessary to match actual models
using test.PersonTest;
using Xunit;
using Xunit.Abstractions;


namespace test.PersonTest
{
    public class PersonApiTest
    {

        readonly PersonRequestClass request = new();

        private PersonSchema Person = new PersonSchema();

        [Fact]
        public void GetPerson_ValidId_ReturnsPersonName()
        {
            // Arrange
            var persons = PersonRequestClass.GetSamplePersons();
            var personId = "1";
            var expectedPersonName = "Person 1";

            // Act
            var person = persons.FirstOrDefault(e => e.Id == personId);

            // Assert
            Assert.NotNull(person);
            Assert.Equal(expectedPersonName, person!.Name);

        }
        [Fact]
        public void GetPerson_InvalidId_ReturnsNull()
        {
            // Arrange
            var persons = PersonRequestClass.GetSamplePersons();
            var personId = "3";

            // Act
            var person = persons.FirstOrDefault(e => e.Id == personId);

            // Assert
            Assert.Null(person);
        }

    }
}