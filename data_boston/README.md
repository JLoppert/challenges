Problem
-------
Using the Boston Employee Earnings Report, create a simple web API service which given a job title, will respond with the average salary for that position.

## Requirements

* The average salary should be based on Total Earnings and not Regular.
* title should allow for case insensitve comparison.
* title should match on partials (example, teacher should match Teacher, Teacher I, Subsitute Teacher, etc)

## API
The application exposes an API to retrieve an average salary for a given employee title and year. The average salary is based on `Total Earnings` column of the Earnings Report for the provided year

- Valid `year` include 2011, 2012, 2013, 2014. Non-valid years default to 2014.
- `title` allows case insensitve comparison.
- `title` allows partial matches. For example: 'assi' matches 'Assistant'
- `title` is provided as a query parameter

### Generic example
Request
`
/earnings_report/:year/total_earnings.json?title=URL_ENCODED_TERM
`

Response
`
XXXX.XX
`

### Specific example
Request
<a href="http://sheltered-springs-64102.herokuapp.com/earnings_report/2014/total_earnings.json?title=Assistant" target="_blank">/earnings\_report/2014/total\_earnings.json?title=Assistant</a>


Response
`
47960.36
`

## Design Decisions
The initial application design did not utilize the [Socrata API](https://dev.socrata.com/) and instead would import data from CSVs. The CSV data would be parsed and stored in a Postgres database. The Employee Earnings Report would be divided into two tables, an Employees table and an Earnings_Report table. The separation enables multi-year associations for a single Employee.

However, the initial design was scraped after learning of the Socrata API. The current design only uses the Socrata API. A performance trade-off was made to decrease the development time. The application requests data from the Socrata API on each page view. If the Socrata API is down, or the application experiences network related issues, the application will not display any useful data. A hybrid approach was considered where the application would request data from the API the first time, then parse and store the data locally. Future requests to the service would return the local results. The hybrid approach was scraped as it was not clear if it violated any terms of service.

## Future Work
- Expand API to include other useful functions beyond average.
- Incorporate more document types beyond the Employee Earnings Report.
- Update search to retrieve results across multiple documents.
- Build out useful visualizations to show aggregations and trends over time.
