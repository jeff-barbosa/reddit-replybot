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

Next thing you should do is rename the file `config.json.sample` to `config.json` and fill in your information (Read next section).

#### Settings

Before running the bot, you must properly set its configuration. After properly renaming `config.json.sample` to `config.json`, open the file with any text editor. Inside there's a JSON object. There are three main sections: reddit_conf, database_conf and general_conf.

**Reddit configuration**    
You need to input the basic information so the bot can connect to Reddit. 

`username` This is your Reddit username     
`password` This is your Reddit password    
`app_id` The ID for your app     
`app_secret` The secret (private key) for you app    
`user_agent` This is the user-agent of your bot, you don't really need to change this    

If you don't know what are the APP_ID and APP_SECRET, take a quick look at [Reddit's API guide](https://github.com/reddit/reddit/wiki/OAuth2). 

**Database configuration**    
This is the configuration used by your database. By default we're using the SQLite database. So you don't need to change anything here. Unless you want to use a different database.

**General configuration**    
Misc stuff. The most important thing here is the subreddit list that your bot must watch. 

`cooldown` How many seconds the bot will wait before requesting Reddit for new comments     
`subreddits_list` This is a list of subs the bot is watching, example:    
  ```
 "subreddits_list": [
  "MyAwesomeSub1",
  "MyAwesomeSub2",
  "MyAwesomeSub3"
 ]
 
 ```
`trigger` This is the trigger phrase. If the bot see this he'll try to reply. By default it is `ReplyBot define:\s*(.+)`, so if someone says "ReplyBot define: ThisWeirdTerm" the bot we'll try to define "ThisWeirdTerm"    
`silent` Whether or not the bot should print a message to the console when he replies to a comment

**Reply.txt**

This file stores the message the bot will use to reply to a comment. You can change it at will. But you must remember to **keep** the keywords `{TERM}` and `{DEFINITION}` somewhere in the file. They're used by the bot as placeholders. So he knows where to put the "term" and "definition" he's commenting.

### Bugs and Suggestions

This is pretty much a quick hack. It ought have some bugs. So any reports are very welcome. You can [open a new issue](https://github.com/jefferson-dab/reddit-replybot/issues/new) stating the problem. 
