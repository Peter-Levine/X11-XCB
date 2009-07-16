package X11::XCB::Atom;

use Moose;
use X11::XCB::Connection;

has 'name' => (is => 'ro', isa => 'Str', required => 1, trigger => \&_request);
has 'id' => (is => 'ro', isa => 'Int', lazy_build => 1);
has '_sequence' => (is => 'rw', isa => 'Int');
has '_conn' => (is => 'ro', default => sub { X11::XCB::Connection->instance });

sub _build_id {
    my $self = shift;

    my $id = $self->_conn->intern_atom_reply($self->_sequence)->{atom};

    # None = 0 means the atom does not exist
    die "No such atom" if ($id == 0);

    return $id;
}

sub _request {
    my $self = shift;

    # Place the request directly after the name is set, we get the reply later
    my $request = $self->_conn->intern_atom(
        1, # do not create the atom if it does not exist
        length($self->name),
        $self->name
    );

    # Save the sequence to identify the response
    $self->_sequence($request->{sequence});
}

1
# vim:ts=4:sw=4:expandtab
