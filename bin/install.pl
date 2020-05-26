#!/usr/bin/perl -w
#
# install.pl [--uninstall] sourcefile targetfile [install options]
#

use File::Copy;
use File::Path qw(make_path);
use File::Basename qw(dirname);

our $os_is_windows = $^O =~ /^MSWin/;
our $uninstall;
our $source;
our $target;
our @params;

sub print_usage
{
	print "Usage: ".basename($0)." [--uninstall] source target [install options]\n";
	exit 1;
}

# Check for uninstall option
if (!defined $ARGV[0])
{
	print_usage;
}
elsif ($ARGV[0] eq "--uninstall")
{
	$uninstall = 1;
	shift @ARGV;
	($source, $target) = @ARGV;
}
else
{
	$uninstall = 0;
	($source, $target, @params) = @ARGV;
}

sub read_file_ignore_version($)
{
	my $fh;
	my $contents = "";
	if (open($fh, '<', $_[0] ))
	{
		while (<$fh>)
		{
			s/^our \$lcov_version.*?$//;
			s/^\.TH.*?$//;
			$contents = $contents.$_."\n";
		}
		close($fh);
	}
	return $contents;
}

sub do_install($$$)
{
	my ($source, $target, $params) = @_;

	make_path(dirname($target));
	if ($os_is_windows)
	{
		copy($source, $target);
	}
	else
	{
		system("install", "-p", $source, $target, @params);
	}
}

sub do_uninstall($$)
{
	my ($source, $target) = @_;

	# Does target exist?
	if (-r $target)
	{
		# Is target of the same version as this package?
		my $source_text = read_file_ignore_version($source);
		my $target_text = read_file_ignore_version($target);

		if ($source_text eq $target_text)
		{
			unlink($target);
		}
		else
		{
			print "WARNING: Skipping uninstall for $target - not equivalent version!\n";
		}
	}
	else
	{
		print "WARNING: Skipping uninstall for $target - not installed!\n";
	}
}


# Call sub routine
if ($uninstall)
{
	do_uninstall($source, $target);
}
else
{
	do_install($source, $target, $params);
}

exit 0;
