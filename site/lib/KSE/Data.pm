#line 1 "KSE/Data.pm"
package KSE::Data;

use strict;
#use warnings;

my %data = ('CurrentSave' => undef, 'GUI'=>undef, 'Items'=>undef);

sub SetCurrentSave
{
	my $save = shift;
	$data{'CurrentSave'} = $save;
}

sub ClearData
{
	delete $data{'CurrentSave'};
	$data{'CurrentSave'} = undef;
}

sub ClearGUIData
{
	delete $data{'GUI'};
	$data{'GUI'} = undef;
}

sub ClearItemData
{
	delete $data{'Items'};
	$data{'Items'} = undef;
}

sub GetData
{
	my ($target, @path) = @_;
	
	my $path_size = scalar (@path);
	my $path_data = $data{'CurrentSave'};
#	print "Getting Data: $target $path_size.\n";
	
	if($path_size == 1)
	{
		return $data{'CurrentSave'}{$target}{$path[0]};
	}
	elsif($path_size == 2)
	{
		return $data{'CurrentSave'}{$target}{$path[0]}{$path[1]};
	}
	elsif($path_size == 3)
	{
		return $data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]};
	}
	elsif($path_size == 4)
	{
		return $data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]};
	}
	elsif($path_size == 5)
	{
		return $data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]};
	}
	elsif($path_size == 6)
	{
		return $data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]};
	}
	else
	{
		print "Ran out of space trying to find $target! Need $path_size\n";
		return undef;
	}
	
#	if($path_size > 1)
#	{
#		foreach my $p (@_)
#		{
#			next if $p eq $_[-1];
#			
#			if(defined($path_data->{$p}) == 1)
#			{
#				$path_data = $path_data->{$p};
#			}
#			else
#			{
#				return undef;
#			}
#		}
#
#		return $path_data->{$_[-1]};
#	}
#	else
#	{
#		my $default = $_[0];
#		return $data{'CurrentSave'}{$default};
#	}
#	
#	return undef;
}

sub GetDataRef
{
	my ($target, @path) = @_;
	
	my $path_size = scalar (@path);
	my $path_data = $data{'CurrentSave'};

	if($path_size == 1)
	{
		return \$data{'CurrentSave'}{$path[0]};
	}
	elsif($path_size == 2)
	{
		return \$data{'CurrentSave'}{$path[0]}{$path[1]};
	}
	elsif($path_size == 3)
	{
		return \$data{'CurrentSave'}{$path[0]}{$path[1]}{$path[2]};
	}
	elsif($path_size == 4)
	{
		return \$data{'CurrentSave'}{$path[0]}{$path[1]}{$path[2]}{$path[3]};
	}
	elsif($path_size == 5)
	{
		return \$data{'CurrentSave'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]};
	}
	elsif($path_size == 6)
	{
		return \$data{'CurrentSave'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]};
	}
	else
	{
		print "Ran out of space trying to find $target! Need $path_size\n";
		return undef;
	}
#	if($path_size > 1)
#	{
#		foreach my $p (@_)
#		{
#			next if $p eq $_[-1];
#			
#			if(defined($path_data->{$p}) == 1)
#			{
#				$path_data = $path_data->{$p};
#			}
#			else
#			{
#				return undef;
#			}
#		}
#
#		return \$path_data->{$_[-1]};
#	}
#	else
#	{
#		my $default = $_[0];
#		return \$data{'CurrentSave'}{$default};
#	}
#	
#	return undef;
}

sub GetGUIData
{
	my @path = @_;
	
	my $path_size = scalar(@path);
	my $path_data = $data{'GUI'};
#	print "Getting GUI Data: $path[-1] $path_size.\n";
	
	if($path_size == 1)
	{
		return $data{'GUI'}{$path[0]};
	}
	elsif($path_size == 2)
	{
		return $data{'GUI'}{$path[0]}{$path[1]};
	}
	elsif($path_size == 3)
	{
		return $data{'GUI'}{$path[0]}{$path[1]}{$path[2]};
	}
	elsif($path_size == 4)
	{
		return $data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]};
	}
	elsif($path_size == 5)
	{
		return $data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]};
	}
	elsif($path_size == 6)
	{
		return $data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]};
	}
	else
	{
		print "Ran out of space! Need $path_size\n";
		return undef;
	}
#	if($path_size > 1)
#	{
#		print "Starting at ";
#		foreach my $p (@path)
#		{
#			next if $p eq $path[-1];
#			print "$p->";
#			
#			if(defined($path_data->{$p}) == 1)
#			{
#				$path_data = $path_data->{$p};
#			}
#			else
#			{
#				print "($p is undef)\n";
#				return undef;
#			}
#		}
#		print $path[-1] . "\n";
#		return $path_data->{$path[-1]};
#	}
#	else
#	{
#		my $default = $path[0];
#		return $data{'GUI'}{$default};
#	}
#	
#	return undef;
}

sub GetGUIDataRef
{
	my @path = @_;
	
	my $path_size = scalar(@path);
	my $path_data = $data{'GUI'};
	
	if($path_size == 1)
	{
		return \$data{'GUI'}{$path[0]};
	}
	elsif($path_size == 2)
	{
		return \$data{'GUI'}{$path[0]}{$path[1]};
	}
	elsif($path_size == 3)
	{
		return \$data{'GUI'}{$path[0]}{$path[1]}{$path[2]};
	}
	elsif($path_size == 4)
	{
		return \$data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]};
	}
	elsif($path_size == 5)
	{
		return \$data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]};
	}
	elsif($path_size == 6)
	{
		return \$data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]};
	}
	else
	{
		print "Ran out of space! Need $path_size\n";
		return undef;
	}
#	if($path_size > 1)
#	{
#		foreach my $p (@_)
#		{
#			next if $p eq $_[-1];
#			
#			if(defined($path_data->{$p}) == 1)
#			{
#				$path_data = $path_data->{$p};
#			}
#			else
#			{
#				return undef;
#			}
#		}
#
#		return \$path_data->{$_[-1]};
#	}
#	else
#	{
#		my $default = $_[0];
#		return \$data{'GUI'}{$default};
#	}
#	
#	return undef;
}

sub GetItemData
{
	my ($target, @path) = @_;
	
	my $path_size = scalar (@path);
	my $path_data = $data{'Items'};
#	print "Getting Data: $target $path_size.\n";
	
	if($path_size == 1)
	{
		return $data{'Items'}{$target}{$path[0]};
	}
	elsif($path_size == 2)
	{
		return $data{'Items'}{$target}{$path[0]}{$path[1]};
	}
	elsif($path_size == 3)
	{
		return $data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]};
	}
	elsif($path_size == 4)
	{
		return $data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]};
	}
	elsif($path_size == 5)
	{
		return $data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]};
	}
	elsif($path_size == 6)
	{
		return $data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]};
	}
	else
	{
		return $data{'Items'};
#		print "Ran out of space trying to find $target! Need $path_size\n";
#		return undef;
	}
}

sub SetData
{
	my ($target, $new_data, @path) = @_;
	
#	print "Target: $target\nNew Data: $new_data\nPath: " . scalar(@path) . "\n";
	my $path_size = scalar @path;
	my $path_data = $data{'CurrentSave'};

	if($path_size == 0)
	{
		$data{'CurrentSave'}{$target} = $new_data;
	}
	elsif($path_size == 1)
	{
		$data{'CurrentSave'}{$target}{$path[0]} = $new_data;
	}
	elsif($path_size == 2)
	{
		$data{'CurrentSave'}{$target}{$path[0]}{$path[1]} = $new_data;
	}
	elsif($path_size == 3)
	{
		$data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]} = $new_data;
	}
	elsif($path_size == 4)
	{
		$data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]} = $new_data;
	}
	elsif($path_size == 5)
	{
		$data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]} = $new_data;
	}
	elsif($path_size == 6)
	{
		$data{'CurrentSave'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]} = $new_data;
	}
	else
	{
		print "Ran out of space trying to find $target! Need $path_size\n";
		exit;
	}
	
#	if($path_size > 1)
#	{
#		foreach my $p (@path)
#		{
#			next if $p eq $path[-1];
#			
#			$path_data = $path_data->{$p};
#		}
#
#		$path_data->{$path[-1]} = $new_data;
#	}
#	else
#	{
#		$data{'CurrentSave'}{$path[0]} = $new_data;
#	}
}

sub SetGUIData
{
	my ($new_data, @path) = @_;
	
	my $path_size = scalar(@path);
	my $path_data = $data{'GUI'};

	if($path_size == 1)
	{
		$data{'GUI'}{$path[0]} = $new_data;
	}
	elsif($path_size == 2)
	{
		$data{'GUI'}{$path[0]}{$path[1]} = $new_data;
	}
	elsif($path_size == 3)
	{
		$data{'GUI'}{$path[0]}{$path[1]}{$path[2]} = $new_data;
	}
	elsif($path_size == 4)
	{
		$data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]} = $new_data;
	}
	elsif($path_size == 5)
	{
		$data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]} = $new_data;
	}
	elsif($path_size == 6)
	{
		$data{'GUI'}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]} = $new_data;
	}
	else
	{
		print "Ran out of space! Need $path_size\n";
		exit;
	}
	
#	print "Setting data: ";
#	if($path_size > 1)
#	{
#		foreach my $p (@path)
#		{
#			next if $p eq $path[-1];
#			print "$p->";
#			$path_data = $path_data->{$p};
#		}
#
#		print "$path[-1] to $new_data\n";
#		$path_data->{$path[-1]} = $new_data;
#	}
#	else
#	{
#		print "$path[0] to $new_data\n";
#		$data{'GUI'}{$path[0]} = $new_data;
#	}
}

sub SetItemData
{
	my ($target, $new_data, @path) = @_;
	
#	print "Target: $target\nNew Data: $new_data\nPath: " . scalar(@path) . "\n";
	my $path_size = scalar @path;
	my $path_data = $data{'Items'};

	if($path_size == 0)
	{
		$data{'Items'}{$target} = $new_data;
	}
	elsif($path_size == 1)
	{
		$data{'Items'}{$target}{$path[0]} = $new_data;
	}
	elsif($path_size == 2)
	{
		$data{'Items'}{$target}{$path[0]}{$path[1]} = $new_data;
	}
	elsif($path_size == 3)
	{
		$data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]} = $new_data;
	}
	elsif($path_size == 4)
	{
		$data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]} = $new_data;
	}
	elsif($path_size == 5)
	{
		$data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]} = $new_data;
	}
	elsif($path_size == 6)
	{
		$data{'Items'}{$target}{$path[0]}{$path[1]}{$path[2]}{$path[3]}{$path[4]}{$path[5]} = $new_data;
	}
	else
	{
		print "Ran out of space trying to find $target! Need $path_size\n";
		exit;
	}
}

return 1;