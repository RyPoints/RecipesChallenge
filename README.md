# <img src="https://www.zendevelop.com/AppIcon.png" width="32" height="32" style="vertical-align: middle"> Recipes Challenge

### Summary: Include screen shots or a video of your app highlighting its features

Grid of items:

Item expansion within the grid:

Expansion behaviors:

Natural selection of next/previous:

Type filter:

Country filter:

Alphabetical sort:

Filter and sort:

Link to YouTube:

Link to source site:

System light mode compatible:

Pull to refresh:

Empty JSON result:

Malformed JSONresult:

Scraper:



### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

I put the basic interface together, then the image caching then the unit test.  Then I prettied up the basic interface a bit.  Then it was time to show the recipe content.  Webviews were an option for displaying recipes, but the web sites used are more formatted for web than mobile, so some customization for the content would help for the text content to be more digestable on mobile.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

The basic project up to the before the scraper and pretting up was put together rather quickly in a couple of hours.  Then I put the scraper and SQL database with cached recipe info together and loaded it and it works well and that took a good bit of Saturday.  Then I went though another round of quick UI improvements.
Now I'm just and reviewing the code for submission and making this documentation.  Several hours total.  Most of it just to add the scraping and grid expanding enhancements, but that's also what gets us beyond the basics.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

Only having one screen is a kind of trade-off and having non-mobile-formatted content is also a kind of trade-off, but I mitigated both trade-offs by putting the details screen that is often a subscreen in the Grid itself and using a webscraper and SQL database to standardize the content.

Another trade-off was I left about five of the custom sites out of the scraper because 95% of the content was enough for this demo, but if this was a real project I would have added those too and further enhanced the scraper.

### Weakest Part of the Project: What do you think is the weakest part of your project?

The scraper is likely the weakest part and also the strongest part.  Scapers are often weak because they are brittle and break easily on web changes, though they also are pretty easy to fix if they break.  While the scraper isn't perfect, it enabled much more standardized formatting of the content while still citing the full info.  Even after scaping one can manually review and edit the database before using it.  

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

Additionally for an actual project, one would have to review in practice that this scraping abided by the terms and agreements with any partner sites, though much of this info was on the public web to begin with, there was a login before some of the recipe data obtained, so for a real project that would have to be considered as well.