#!/usr/bin/perl -w
#
# install.pl [--uninstall] sourcefile targetfile [install options]
#

use File::Copy;
use Perl::OSType ':all';
use File::Slurp;
use File::Path qw(make_path);
use File::Basename qw(dirname);
  
my $os_is_windows = is_os_type('Windows');

my $uninstall;
my $source;
my $target;
my $params;

sub print_usage
{
	print "Usage: ".basename($0)." [--uninstall] source target [install options]\n";
	exit 1;
}

# Check for uninstall option
if( !defined $ARGV[0] )
{
	print_usage;
}
elsif( $ARGV[0] eq "--uninstall" )
{
	$uninstall = 1;
	$source = $ARGV[1];
	$target = $ARGV[2];
}
else
{
	$uninstall = 0;
	$source = $ARGV[0];
	$target = $ARGV[1];
	$params = $ARGV[2];
}

if( $os_is_windows )
{
	$source =~ s/\//\\/g;
	$target =~ s/\//\\/g;
}

sub do_install($$$)
{
	my ($source, $target, $params) = @_;

	if( $os_is_windows )
	{
#		print "#### Copying $source => $target\n";
		make_path( dirname( $target ) );
		copy( $source, $target );
	}
	else
	{
		system( "install -p -D $source $target $params" );
	}
}

sub do_uninstall($$)
{
	my( $source, $target ) = @_;

	# Does target exist?
	if( -r $target )
	{
		# Is target of the same version as this package?
		my $source_text = read_file( $source );
		my $target_text = read_file( $target );
		
		$source_text =~ s/^our \$lcov_version.*?$//mg;
		$target_text =~ s/^our \$lcov_version.*?$//mg;

		$source_text =~ s/^\.TH.*?$//mg;
		$target_text =~ s/^\.TH.*?$//mg;

		if( $source_text eq $target_text )
		{
			unlink( $target );
		}
		else
		{
			print "WARNING: Skipping uninstall for $target - versions differ!\n";
		}
	}
	else
	{
		print "WARNING: Skipping uninstall for $target - not installed!\n";
	}
}


# Call sub routine
if( $uninstall )
{
	do_uninstall( $source, $target );
}
else
{
	do_install( $source, $target, $params );
}

exit 0;
