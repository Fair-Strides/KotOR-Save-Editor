my @test = ('a', 'b', 'c');

my %has;
$has{0}{'a'}{'b'}{'c'} = 'No';

my $test1 = check('a', 'b', 'c');
Set('Yes', 'a', 'b', 'c');
my $test2 = check('a', 'b', 'c');

print "hash " . $has{0} . "\n";
print "test1 " . $test1 . "\n";
print "test2 " . $test2 . "\n";
#my $t = <STDIN>;

sub check
{
	my @paths = @_;
	
	my $path = $has{0};

	foreach my $p (@paths)
	{
		print "$p %$path " . %$path{$p} . "\n";
		if ($p eq $paths[-1]) { print "yes"; next; }
		
		$path = $path->{$p};
	}
	print "%$path $paths[-1]\n";
	return $path->{$paths[-1]};
}

sub Set
{
	my ($data, @paths) = @_;
	
	my $path = $has{0};
	
	foreach my $p (@paths)
	{
		next if $p eq $paths[-1];
		
		$path = $path->{$p};
	}
	
	$path->{$paths[-1]} = $data;
}