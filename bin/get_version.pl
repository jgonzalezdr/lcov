#!/usr/bin/perl -w

use strict;
use warnings;
use File::Basename;
use File::Slurp;
use Cwd qw/abs_path/;

our $tool_dir = abs_path(dirname($0));
our $git_version = `git -C $tool_dir describe --tags 2>/dev/null`;
our $version_file = $tool_dir."/../.version.pl";

our $version;
our $release;

sub print_usage
{
	print "Usage: ".basename($0)." (--version|--release)\n";
	exit 1;
}

if( length($git_version) )
{
	if( $git_version =~ /^(.+?)-(.*)$/ )
	{
		$version = $1; 
		$release = $2;
		$release =~ s/-/\./g;
	}
}
elsif( -f $version_file )
{
	eval read_file( $version_file );
}

# Fallback values 
$version ||= "1.0";
$release ||= "1";

if( ! defined $ARGV[0] )
{
	print_usage();
}
elsif( $ARGV[0] eq "--version" )
{
	print $version;
}
elsif( $ARGV[0] eq "--release" )
{
	print $release;
}
else
{
	print_usage;
}

