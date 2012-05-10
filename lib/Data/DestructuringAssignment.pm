package Data::DestructuringAssignment;
use strict;
use warnings;
use Exporter qw/import/;
use List::MoreUtils qw/all/;
use base qw/Tie::Scalar/;

our $VERSION = '0.01';

our @EXPORT_OK = qw/destruct/;

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
    $self->{is_assigned};
}

sub STORE {
    my ( $self,$value ) = @_;
    $self->{is_assigned} = $self->assign($value);
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
    return unless defined $data;
    $$ref = $data;
    return 1;
}
sub __assign_hash {
    my ( $data,$target ) = @_;
    my $flag = 0;
    for my $key ( keys %$data ) {
        next unless exists $target->{$key};
        my $element = $data->{$key};
        $flag |= __assign( $element,$target->{$key});
    }
    return $flag;
}

sub __assign_array{
    my ( $data,$target ) = @_;
    my $flag = 0;
    for my $index (0..(scalar @$data) -1) {
        next unless exists $target->[$index];
        my $element = $data->[$index];
        $flag |= __assign( $element,$target->[$index]);
    }
    return $flag;
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

    destruct( \my $hoge ) = 10;

    destruct( [\my $a ,\my $b] ) = [1,2];

    destruct( { hash => \my $hash } ) = { hash => [1,2,3]};

    my @array =  map{ +{ hoge => "$_",fuga => $_ * 2}} (1..10);
    while(destruct({ hoge => \my $hoge } ) = shift @array) {
        # $hoge..;
    }
    
    my @array =  map{ +{ hoge => "$_",fuga => $_ * 2}} (1..10);
    for my $elem (@array){
        destruct({ hoge => \my $hoge, fuga => \my $fuga}) = $elem;
    }
    
    my $template = { hoge => 1,fuga => 2};
    if( destruct({ hoge => \my $hoge ,piyo => \my $fuga }) = $template ){
        ::pass 'matched any';
    }else {
        # not come here
    }

=head1 DESCRIPTION

Data::DestructuringAssignment provides harmony's destructuring assignment for perl5

=head1 AUTHOR

Daichi HirokiE<lt>hirokidaichi {at} gmail.comE<gt>

=head1 SEE ALSO

L<http://wiki.ecmascript.org/doku.php?id=harmony:destructuring>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
