use v5.36;
use autodie       qw(system);
use File::Slurper qw(read_dir read_binary);

# Re-build assets if we're running on dev.
system './build-assets' if -e 'build-assets';

my %routes;

# Assets are fingerprinted and cached, public files aren't.
$routes{"/$_" }{GET} = serve( "assets/$_", 1 ) for read_dir 'assets';
$routes{"/$_" }{GET} = serve( "public/$_", 0 ) for read_dir 'public';

# FIXME Side-effect of how the HTML is built.
delete $routes{'/play.html'};

# HTML.
$routes{'/'}{GET} = $routes{'/dev'}{GET} = serve('assets/play.html');

# Run code.
$routes{'/'}{POST} = $routes{'/dev'}{POST} = sub ($env) {
    use Data::Dumper;
    warn Dumper $env;

    return [ 204, [], [] ];
};

# Tidy code. Should this run under the sandbox?
$routes{'/tidy'}{POST} = sub ($env) {
    use Data::Dumper;
    warn Dumper $env;

    return [ 204, [], [] ];
};

# Print routes.
for my $path ( sort keys %routes ) {
    printf "%4s %s\n", $_, $path for sort keys $routes{$path}->%*;
}

# TODO Serve pre-compressed versions.
sub serve($path, $cache = 0) {
    my $blob = read_binary $path;
    my $mime = $path =~ /\.  css$/x ? 'text/css'
             : $path =~ /\. html$/x ? 'text/html; charset=utf-8'
             : $path =~ /\.  ico$/x ? 'image/x-icon'
             : $path =~ /\.   js$/x ? 'application/javascript'
             : $path =~ /\.  svg$/x ? 'image/svg+xml'
             :                        'application/octet-stream';

    my @headers = ( 'Content-Type' => $mime );

    push @headers, 'Cache-Control' => 'max-age=31536000, public, immutable'
        if $cache;

    push @headers, 'Content-Security-Policy' =>
        "default-src 'self'; style-src 'self' 'unsafe-inline'"
        if $path =~ /\.html$/;

    return sub { return [ 200, \@headers, [$blob] ] };
}

# TODO HTML error pages.
sub ($env) {
    return [ 404, [], [] ] unless $_ = $routes{ $env->{PATH_INFO} || '/' };
    return [ 405, [], [] ] unless $_ = $_->{ $env->{REQUEST_METHOD} };
    return $_->($env);
};
