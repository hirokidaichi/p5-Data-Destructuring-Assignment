use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::DestructuringAssignment qw/destruct/;


{
    ::lives_ok { destruct()} 'just call';
    ::lives_ok { destruct() = undef} 'assign undef';
    ::lives_ok { destruct(my $hoge) = undef } 'no ref';
    
    ::ok destruct( \my $hoge ) = 10;
    ::is $hoge ,10,'simple assign';

    ::ok destruct( [\my $a ,\my $b] ) = [1,2];
    ::is_deeply( [$a ,$b], [1,2],'simple array');

    ::ok not destruct( { hash => \my $hash } ) = [];
    ::is( $hash,undef, 'not match format');

    ::ok destruct( { hash => \$hash } ) = { hash => [1,2,3]};
    ::is_deeply( $hash,[1,2,3] ,q|simple hash|);

}
{
    destruct( { hash => [ undef,undef, \my $test ] } ) = { hash => [qw/a b c d e/] };
    ::is( $test, 'c' );
}

{
    my @array =  map{ +{ hoge => "$_",fuga => $_ * 2}} (1..10);
    for my $elem (@array){
        destruct({ hoge => \my $hoge, fuga => \my $fuga}) = $elem;
        ::ok $hoge;
        ::ok $fuga;
    }
    
}


{
    my @array =  map{ +{ hoge => "$_",fuga => $_ * 2}} (1..10);
    my $c = 1;
    while(destruct({ hoge => \my $hoge } ) = shift @array) {
        ::is $hoge,$c++,"hoge is $hoge";
    }
    
}

{
    my $template = { hoge => 1,fuga => 2};
    if( destruct({ hoge => \my $hoge , fuga => \my $fuga }) = $template ){
        ::pass 'matched';
    }else {
        ::fail 'matched';
    }
}
{
    my $template = { hoge => 1,fuga => 2};
    if( destruct({ hoge => \my $hoge ,piyo => \my $fuga }) = $template ){
        ::pass 'matched any';
    }else {
        ::fail 'matched any';
    }
}
{
    my $template = { hoge => 1,fuga => 2};
    if( destruct({ moga => \my $hoge ,piyo => \my $fuga }) = $template ){
        ::fail 'no matched ';
    }else {
        ::pass 'no matched';
    }
}
{
    my ($x,$y) = (10,20);
    destruct([\$y,\$x] ) = [$x,$y];
    ::is $x,20,'swap1';
    ::is $y,10,'swap2';
}

{
    package Person;
    use Data::DestructuringAssignment qw/destruct/;
    sub new {
        destruct([\my $class,{ name => \my $name , age => \my $age}]) = \@_;
        return bless { name => $name , age => $age } , $class;
    }
    sub age { shift->{age}}
}

{
    my $p = Person->new({ name => 'daichi hiroki', age => 28});
    is $p->age , 28;
}
::done_testing;
