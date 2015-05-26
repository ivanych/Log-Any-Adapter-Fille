package Log::Any::Adapter::Fille;

#
# Advanced adapter for logging to files
#

use 5.008001;
use strict;
use warnings;
use utf8::all;

use Config;
use Fcntl qw(:flock);
use POSIX;
use IO::File;
use Time::HiRes qw(gettimeofday);
use Log::Any '$log';
use Log::Any::Adapter::Util ();

use base qw/Log::Any::Adapter::Base/;

our $VERSION = '0.01';

#---

# Value assignment is needed for futher learning in the PRINT method where the message came from
$SIG{__DIE__} = sub { $@ = 'DIE' };
$SIG{__WARN__} = sub { $@ = 'WARN'; print STDERR @_ };

# We connect the descriptor STDERR with the current packet for interception of all error messages
tie *STDERR, __PACKAGE__;

# Redefinition of standard constructor for the connnected descriptor STDERR
sub TIEHANDLE {
    my $class = shift;

    bless {}, $class;
}

# Redefinition of standart method PRINT for the connected descriptor STDERR
sub PRINT {
    my ( $self, @msg ) = @_;

    chomp(@msg);

    # Current value in $@ says where the message came from
    if ( $@ eq 'DIE' ) {
        $log->emergency(@msg);
    }
    elsif ( $@ eq 'WARN' ) {
        $log->warning(@msg);
    }
    else {
        $log->notice(@msg);
    }

    # Reset to the default value
    $@ = '';
}

# Redefinition of standard methode BINMODE for the connected descriptor STDERR
# In fact this method makes no sense here but it has to be fulfiled for the backward compatibility
# with the modules that call this method for their own purposes
sub BINMODE { }

# Log levels (names satisfy the official log names Log::Any)
my %levels = (
    0 => 'EMERGENCY',
    1 => 'ALERT',
    2 => 'CRITICAL',
    3 => 'ERROR',
    4 => 'WARNING',
    5 => 'NOTICE',
    6 => 'INFO',
    7 => 'DEBUG',
    8 => 'TRACE',
);

my $HAS_FLOCK = $Config{d_flock} || $Config{d_fcntl_can_lock} || $Config{d_lockf};

sub new {
    my ( $class, @args ) = @_;

    return $class->SUPER::new(@args);
}

sub init {
    my $self = shift;

    if ( exists $self->{log_level} ) {
        $self->{log_level} = Log::Any::Adapter::Util::numeric_level( $self->{log_level} )
            unless $self->{log_level} =~ /^\d+$/;
    }
    else {
        $self->{log_level} = Log::Any::Adapter::Util::numeric_level('info');
    }

    open( $self->{fh}, ">>", $self->{file} ) or die "Не удалось открыть файл '$self->{file}': $!";
    $self->{fh}->autoflush(1);
}

foreach my $method ( Log::Any::Adapter::Util::logging_methods() ) {
    no strict 'refs';    ## no critic (ProhibitNoStrict)

    my $method_level = Log::Any::Adapter::Util::numeric_level($method);

    *{$method} = sub {
        my ( $self, $text ) = @_;

        return if $method_level > $self->{log_level};

        my ( $sec, $msec ) = gettimeofday;

        # Log line in "date time pid level message" format
        my $msg = sprintf( "%s.%.6d %5d %s %s\n", strftime( "%Y-%m-%d %H:%M:%S", localtime($sec) ), $msec, $$, $levels{$method_level}, $text );

        flock( $self->{fh}, LOCK_EX ) if $HAS_FLOCK;
        $self->{fh}->print($msg);
        flock( $self->{fh}, LOCK_UN ) if $HAS_FLOCK;
        }
}

foreach my $method ( Log::Any::Adapter::Util::detection_methods() ) {
    no strict 'refs';    ## no critic (ProhibitNoStrict)

    my $base = substr( $method, 3 );

    my $method_level = Log::Any::Adapter::Util::numeric_level($base);

    *{$method} = sub {
        return !!( $method_level <= $_[0]->{log_level} );
        }
}

1;
