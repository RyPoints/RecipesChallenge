# <img src="https://www.zendevelop.com/AppIcon.png" width="32" height="32" style="vertical-align: middle"> Recipes Challenge

### Summary: Include screen shots or a video of your app highlighting its features

General idea:

<img src="https://www.zendevelop.com/preButterTart.jpg" width="390" height="844" alt="Recipe App Screenshot">

<img src="https://www.zendevelop.com/butterTart1.png" width="390" height="844" alt="Recipe App Screenshot">
<img src="https://www.zendevelop.com/butterTart2.png" width="390" height="844" alt="Recipe App Screenshot">
<img src="https://www.zendevelop.com/butterTart3.png" width="390" height="844" alt="Recipe App Screenshot">
<img src="https://www.zendevelop.com/butterTart4.png" width="390" height="844" alt="Recipe App Screenshot">
<img src="https://www.zendevelop.com/butterTart5.png" width="390" height="844" alt="Recipe App Screenshot">

[Grid of items:](https://youtube.com/shorts/mYBb0uQxanA?feature=share)

[![Demo Video](https://img.youtube.com/vi/mYBb0uQxanA/0.jpg)](https://youtube.com/shorts/mYBb0uQxanA?feature=share)

[Item expansion within the grid:](https://youtube.com/shorts/y3CRyKI4gJ4)

[![Demo Video](https://img.youtube.com/vi/y3CRyKI4gJ4/0.jpg)](https://youtube.com/shorts/y3CRyKI4gJ4?feature=share)

[Expansion behaviors:](https://youtube.com/shorts/Sy95JLy1xYo)

[![Demo Video](https://img.youtube.com/vi/Sy95JLy1xYo/0.jpg)](https://youtube.com/shorts/Sy95JLy1xYo?feature=share)

[Link to YouTube:](https://youtube.com/shorts/O1IRFHPnneI?feature=share)

[![Demo Video](https://img.youtube.com/vi/O1IRFHPnneI/0.jpg)](https://youtube.com/shorts/O1IRFHPnneI?feature=share)

[Link to source site:](https://youtube.com/shorts/0fu3lDfVU-4?feature=share)

[![Demo Video](https://img.youtube.com/vi/0fu3lDfVU-4/0.jpg)](https://youtube.com/shorts/0fu3lDfVU-4?feature=share)

[System light mode compatible:](https://youtube.com/shorts/w91z5MWUHJs)

[![Demo Video](https://img.youtube.com/vi/w91z5MWUHJs/0.jpg)](https://youtube.com/shorts/w91z5MWUHJs?feature=share)


[Pull to refresh:](https://youtube.com/shorts/zJGeULkvgVk)

[![Demo Video](https://img.youtube.com/vi/zJGeULkvgVk/0.jpg)](https://youtube.com/shorts/zJGeULkvgVk?feature=share)

[Empty JSON result:](https://youtube.com/shorts/7E2ajdWMdcA)

[![Demo Video](https://img.youtube.com/vi/7E2ajdWMdcA/0.jpg)](https://youtube.com/shorts/7E2ajdWMdcA?feature=share)


[Malformed JSON result:](https://youtube.com/shorts/qMBuH0F1jfQ?feature=share)

[![Demo Video](https://img.youtube.com/vi/qMBuH0F1jfQ/0.jpg)](https://youtube.com/shorts/qMBuH0F1jfQ?feature=share)

[Type filter:](https://youtube.com/shorts/RSigqepkh30)

[![Demo Video](https://img.youtube.com/vi/RSigqepkh30/0.jpg)](https://youtube.com/shorts/RSigqepkh30?feature=share)

[Country filter:](https://youtube.com/shorts/fBckRwehWIY)

[![Demo Video](https://img.youtube.com/vi/fBckRwehWIY/0.jpg)](https://youtube.com/shorts/OfBckRwehWIY?feature=share)

[Alphabetical sort:](https://youtube.com/shorts/G7ThB0770d8)

[![Demo Video](https://img.youtube.com/vi/G7ThB0770d8/0.jpg)](https://youtube.com/shorts/G7ThB0770d8?feature=share)

[Filter and sort:](https://youtube.com/shorts/-mBgTsVyaRw)

[![Demo Video](https://img.youtube.com/vi/-mBgTsVyaRw/0.jpg)](https://youtube.com/shorts/-mBgTsVyaRw?feature=share)


### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

I put the basic interface together, then the image caching then the unit test.  After that I prettied up the basic interface a bit.  Then it was time to show the recipe content.  Webviews were an option for displaying recipes, but the web sites used are more formatted for web than mobile, so some customization for the content would help for the text content to be more digestable on mobile.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

The basic project up to the before the scraper and pretting up was put together rather quickly in a couple of hours.  Then I put the scraper and SQL database with cached recipe info together and loaded it and it works well and that took a good bit of Saturday.  Then I went though another round of quick UI improvements.
Now I'm just and reviewing the code for submission and making this documentation.  Several hours total.  Most of it just to add the scraping and grid expanding enhancements, but that's also what gets us beyond the basics.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

Only having one screen is a kind of trade-off and having non-mobile-formatted web content is also a kind of trade-off, but I mitigated both trade-offs by putting the details screen that is often a subscreen in the Grid itself and using a webscraper and SQL database to standardize the content.

Another trade-off was I left about five of the custom sites out of the scraper because 95% of the content was enough for this demo, but if this was a real project I would have added those too and further enhanced the scraper.

I'd also probably add some indicators at the top to show what filter you are on just so that is clearer as well as next step from where things are at.

### Weakest Part of the Project: What do you think is the weakest part of your project?

The scraper is likely the weakest part and also the strongest part.  Scapers are often weak because they are brittle and break easily on web changes, though they also are pretty easy to fix if they break.  While the scraper isn't perfect, it enabled much more standardized formatting of the content while still citing the full info.  Even after scaping one can manually review and edit the database before using it.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

Additionally for an actual project, one would have to review in practice that this scraping abided by the terms and agreements with any partner sites, though much of this info was on the public web to begin with, there was a login before some of the recipe data obtained, so for a real project that would have to be considered as well.
