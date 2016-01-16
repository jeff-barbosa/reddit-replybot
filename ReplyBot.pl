#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use JSON;
use DBI;
use Reddit::Client;

# Reddit configuration
my $USERNAME = "";
my $PASSWORD = "";
my $APP_ID = "";
my $APP_SECRET = "";
my $USERAGENT = "Reddit-ReplyBot/1.0 by /u/". $USERNAME;

# Database configuration
my $DB_DRIVER = "SQLite";
my $DB_HOST = "localhost";
my $DB_USER = "";
my $DB_PASSWORD = "";
my $DB_NAME = "ReplyBot.db";

# General configuration
my $COOLDOWN = 5;
my $last_search = time;
my %seen_comments;
my @subreddits_list = ("");
my $trigger = 'ReplyBot define:\s*(.+)';
my $silent = 0;

# Bootstrap
print "Getting auth from Reddit...\n";
my $reddit = Reddit::Client->new(
	user_agent => $USERAGENT,
	client_id => $APP_ID,
	secret => $APP_SECRET,
	username => $USERNAME,
	password => $PASSWORD,
);

print "Setting a database connection...\n";
my $dbh = DBI->connect(
	'DBI:'.$DB_DRIVER.':dbname='.$DB_NAME, 
	$DB_USER, 
	$DB_PASSWORD,
	{RaiseError => 1, sqlite_unicode => 1}
) or die ("Error: Unable to connect to the database\n");


sub mainLoop {
	while (1) {
		next if (time - $last_search < $COOLDOWN);
		
		# Request data on new comments for each subreddit the bot is watching
		foreach my $subreddit (@subreddits_list) {
			# Just ask for the last comments of the subreddit
			my $data = $reddit->json_request(
				'GET',
				'/r/'.$subreddit.'/comments',
				{ sort => 'new' }
			);

			# Check each comment for a trigger
			foreach (@{$data->{data}->{children}}) {
				my $comment = $_->{data};
				next if ($seen_comments{$comment->{id}});
				$seen_comments{$comment->{id}} = 1;

				if ($comment->{body} =~ /$trigger/) {
					my $term = $1;
					my $query = "SELECT definition FROM defined_terms WHERE term = ?";
					my $stmt = $dbh->prepare($query);

					if (!$stmt->execute($term)) {
						print "Error: Unable to query the database\n";
						die;
					}

					my $results = $stmt->fetch();
					my $definition;
					if (!$results) {
						$definition = "No definition was found for \"". $term ."\"\n", 
					} else {
						$definition = $results->[0];
					}

					generateReply($term, $definition, $comment->{name});
				}
			}
		}
		$last_search = time;
	}
}

sub generateReply {
	my ($term, $definition, $target) = @_;
	my $reply = "";
	my $REDDIT_NEWLINE = "    \n";

	print "Replying to ". $target ." with the definition of: ". $term ."\n" unless ($silent);

	open (my $fh, "<:utf8", "reply.txt")
  or die ("Error: reply.txt not found or ReplyBot doesn't have read permission\n");

  while (<$fh>) {
  	if ($_ =~ /(.*)\{TERM\}(.*)/) {
  		$reply .= $1.$term.$2.$REDDIT_NEWLINE;
  	} elsif ($_ =~ /(.*)\{DEFINITION\}(.*)/) {
  		$reply .= $1.$definition.$2.$REDDIT_NEWLINE;
  	} else {
  		$reply .= $_.$REDDIT_NEWLINE;
  	}
  }

  # Send the reply
  $reddit->submit_comment(
  	parent_id => $target,
  	text => $reply
  );

	close ($fh);
}

print "Calling main...\n";
mainLoop();
