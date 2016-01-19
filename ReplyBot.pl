#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use JSON;
use DBI;
use Reddit::Client;

# The Reddit::Client object
my $reddit;
# The handler for the database
my $dbh;
# Config structures
my $reddit_conf;
my $database_conf;
my $general_conf;

my $config_file = "config.json";
my $last_search = time;
my %seen_comments;

# Set everything up before running the main loop
sub bootstrap {
	# Get configuration
	print "Parsing ". $config_file ."\n";
	open(my $fh, "<:utf8", $config_file) or die ($!);
	{
		local $/ = undef;
		my $json_data = decode_json(<$fh>);
		$reddit_conf = $json_data->{reddit_conf};
		$database_conf = $json_data->{database_conf};
		$general_conf = $json_data->{general_conf};
	}
	close($fh);

	# Connect to Reddit
	print "Connecting to Reddit...\n";
	$reddit = Reddit::Client->new(
		user_agent => $reddit_conf->{user_agent} . $reddit_conf->{username},
		client_id => $reddit_conf->{app_id},
		secret => $reddit_conf->{app_secret},
		username => $reddit_conf->{username},
		password => $reddit_conf->{password},
	);

	unless ($reddit->has_token()) {
		die("Error: Unable to connect to Reddit\n");
	}

	# Connect to the Database
	print "Setting database connection...\n";
	$dbh = DBI->connect(
		'DBI:'.$database_conf->{db_driver}.
		':dbname='.$database_conf->{db_name}, 
		$database_conf->{db_user}, 
		$database_conf->{db_password},
		{RaiseError => 1, sqlite_unicode => 1}
	) or die ("Error: Unable to connect to the database\n");

	print "All set. Calling main loop.\n";
	mainLoop();
}

sub mainLoop {
	printInfo();

	while (1) {
		next if (time - $last_search < $general_conf->{cooldown});
		
		# Request data on new comments for each subreddit the bot is watching
		foreach my $subreddit (@{$general_conf->{subreddits_list}}) {
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

				if ($comment->{body} =~ /$general_conf->{trigger}/) {
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

	unless ($general_conf->{silent}) {
		print "Replying to ". $target ." with the definition of: ". $term ."\n";
	}

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

# Just an utility that prints the username and subreddit list to the console
sub printInfo {
	print "---------- BOT INFO ----------\n";
	print "User: ". $reddit_conf->{username} ."\n";
	print "Watching subs: ";
	print " ". $_ ." " foreach (@{$general_conf->{subreddits_list}});
	print "\n";
	print "------------------------------\n";
}

bootstrap();
