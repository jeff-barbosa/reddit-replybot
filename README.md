# ReplyBot
General purpose reply bot for Reddit

### Requirements
* Perl interpreter
  * Reddit::Client module
  * DBI module
  * DBD::SQLite module
* SQLite 3

### Installation

Once you've installed the requirements, you'll need to set up a new SQLite database. The database schema already comes with this repository with the name `ReplyBot_schema.sql`.

You only need to run this command:    
`$ sqlite3 ReplyBot.db < ReplyBot_schema.sql`

And a new SQLite 3 database will be created. 

The only table the bot will use is "defined_terms". You can input new terms and their definitions to the database. How to work with the SQLite is beyond the scope of this README file.

#### Settings

Before running the bot, you must properly set its configuration. You'll find them at the beginning of the `ReplyBot.pl` file under three "categories" (so to speak): Reddit configuration, DB configuration and general configuration.

**Reddit configuration**    
You need to input the basic information so the bot can connect to Reddit. 

`$USERNAME` This is your Reddit username     
`$PASSWORD` This is your Reddit password    
`$APP_ID` The ID for your app     
`$APP_SECRET` The secret (private key) for you app    
`$USERAGENT` This is the user-agent of your bot, you don't really need to change this    

If you don't know what are the APP_ID and APP_SECRET, take a quick look at [Reddit's API guide](https://github.com/reddit/reddit/wiki/OAuth2). 

**Database configuration**    
This is the configuration used by your database. By default we're using the SQLite database. So you don't need to change anything here. Unless you want to use a different database.

**General configuration**    
Misc stuff. The most important thing here is the subreddit list that your bot must watch. 

`$COOLDOWN` How many seconds the bot will wait before requesting Reddit for new comments     
`$last_search` Stores the last time we checked for new comments    
`%seen_comments` This is a hash with the IDs of comments we already replied to    
`@subreddits_list` This is a list of subs the bot is watching, example: `@subreddits_list = ("MyAwesomeSub1","MyAwesomeSub2");`    
`$trigger` This is the trigger phrase. If the bot see this he'll try to reply. By default it is `ReplyBot define:\s*(.+)`, so if someone says "ReplyBot define: ThisWeirdTerm" the bot we'll try to define "ThisWeirdTerm"    
`$silent` Whether or not the bot should print a message to the console when he replies to a comment

**Reply.txt**

This file stores the message the bot will use to reply to a comment. You can change it at will. But you must remember to **keep** the keywords `{TERM}` and `{DEFINITION}` somewhere in the file. They're used by the bot as placeholders. So he knows where to put the "term" and "definition" he's commenting.

### Bugs and Suggestions

This is pretty much a quick hack. It ought have some bugs. So any reports are very welcome. You can [open a new issue](https://github.com/jefferson-dab/reddit-replybot/issues/new) stating the problem. 
