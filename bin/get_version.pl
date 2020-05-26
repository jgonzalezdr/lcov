#!/usr/bin/perl -w

use strict;
use warnings;
use File::Basename;
use Cwd qw/abs_path/;

our $os_is_windows = $^O =~ /^MSWin/;
our $tool_dir = abs_path(dirname($0));
our $redirect_to_null = $os_is_windows ? "2>NUL" : "2>/dev/null";
our $git_version = `git -C $tool_dir describe --tags $redirect_to_null`;
our $version_file = $tool_dir."/../.version.pl";
our $version;
our $release;
our $full;

sub print_usage
{
	print "Usage: ".basename($0)." (--version|--release|--full)\n";
	exit 1;
}

if (length($git_version))
{
	$full = substr($git_version, 1);
	if ($git_version =~ /^(.+?)-(.*)$/)
	{
		$version = $1;
		$release = $2;
		$release =~ tr/-/./;
	}
	else
	{
		$version = $full;
	}
}
elsif (-f $version_file)
{
	my $fh;
	if (open($fh, '<', $version_file ))
	{
		while (<$fh>)
		{
			eval;
		}
		close($fh);
	}
}

# Fallback values 
$version ||= "1.11";
$release ||= "1";
$full ||= "$version-$release";

if (!defined $ARGV[0])
{
	print_usage;
}
elsif ($ARGV[0] eq "--version")
{
	print $version;
}
elsif ($ARGV[0] eq "--release")
{
	print $release;
}
elsif ($ARGV[0] eq "--full")
{
	print $full;
}
else
{
	print_usage;
}
