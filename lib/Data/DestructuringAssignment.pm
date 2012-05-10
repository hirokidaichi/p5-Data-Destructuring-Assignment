package Data::DestructuringAssignment;
use strict;
use warnings;
use Exporter qw/import/;
use List::MoreUtils qw/all/;
use base qw/Tie::Scalar/;

our $VERSION = '0.01';

our @EXOPORT_OK = qw/destruct/;

sub destruct : lvalue {
    my ($data) = @_;
    tie $data , __PACKAGE__,$data;
    $data;
}

sub TIESCALAR {
    my ( $class,$scalar ) = @_;
    $class->new($scalar);
}

sub FETCH {
    my ( $self ) = @_;
    die('Disallow Fetch');
}

sub STORE {
    my ( $self,$value ) = @_;
    $self->assign($value);
}
sub new {
    my ( $class,$data ) = @_;
    return bless { data =>$data },$class;
}

sub assign {
    my ( $self,$target ) = @_;
    return __assign($self->{data},$target );
}

sub __is_hash_ref{
    return __is_ref_of('HASH',@_);
}
sub __is_scalar_ref {
    return __is_ref_of('SCALAR',@_);
}
sub __is_array_ref{
    return __is_ref_of('ARRAY',@_);
}

sub __is_ref_of {
    my $ref = shift;
    all { ref $_ and ref $_ eq $ref } @_;
}
sub __assign {
    my ( $data,$target ) = @_;
    return __assign_scalar($data,$target) if __is_scalar_ref($data);
    return __assign_hash( $data,$target ) if __is_hash_ref($data,$target);
    return __assign_array($data,$target ) if __is_array_ref($data,$target);
}

sub __assign_scalar {
    my ( $ref,$data ) = @_;
    $$ref = $data;
}
sub __assign_hash {
    my ( $data,$target ) = @_;
    for my $key ( keys %$data ) {
        next unless exists $target->{$key};
        my $element = $data->{$key};
        __assign( $element,$target->{$key});
    }
}

sub __assign_array{
    my ( $data,$target ) = @_;
    for my $index (0..(scalar @$data) -1) {
        next unless exists $target->[$index];
        my $element = $data->[$index];
        __assign( $element,$target->[$index]);
    }
}

1;

1;
__END__

=head1 NAME

Data::DestructuringAssignment - harmony's destructuring assignment for perl5

=head1 SYNOPSIS

    use Data::DestructuringAssignment qw/destruct/;
    
    destruct([\my $hoge,\my $fuga]) = [10,20];
    print "hoge is $hoge";# hoge is 10
    print "fuga is $fuga";# fuga is 20

=head1 DESCRIPTION

Data::DestructuringAssignment provides perl harmony's destructuring assignment

=head1 AUTHOR

Daichi HirokiE<lt>hirokidaichi {at} gmail.comE<gt>

=head1 SEE ALSO


=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
