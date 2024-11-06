using System;
using System.Collections.Generic;
using test.PersonTest;


namespace test.PersonTest
{
    public class PersonRequestClass
    {
        public static List<PersonSchema> GetSamplePersons()
        {
            return new List<PersonSchema>
            {
                new PersonSchema
                {
                    Id = "1",
                    Name = "Person 1",
                    BirthYear = "1990",
                    DeathYear = "2022",
                    PrimaryProfession = "Actor"
                },
                new PersonSchema
                {
                    Id = "2",
                    Name = "Person 2",
                    BirthYear = "1995",
                    DeathYear = "2022",
                    PrimaryProfession = "Actress"
                }

            };
        }
    }
}
