#line 1 "KSE/Functions/Powers.pm"
package KSE::Functions::Powers;

use List::MoreUtils;

use KSE::GUI::Powers;
use KSE::GUI::Main;

use KSE::Functions::Saves;
use KSE::Functions::Directory;

use Bioware::TLK;
use Bioware::TwoDA;

my $table = Bioware::TwoDA->new();

sub Assign2da
{
	$table->read2da(KSE::Functions::Directory::GetFile('spells.2da'));
}

sub FillPowers
{
	my $self = shift;
	my $target = $self->{'Type'};
	
	my ($image, $name, $value, $index) = (undef, undef, undef, undef);

	my @ordered_powers = ();
	foreach my $power (0 .. $table->{rows})
	{
		if (grep(/^$power$/, @ordered_powers))
		{
#			print "power1 $power is already in\n";
			next;
		}
		
		my $pre_power1 = GetPrerequisite($power, 1);
		my $pre_power2 = GetPrerequisite($power, 2);
		
#		print "Processing power $power\n";
#		print "\tprereq 1 for $power is $pre_power1. Indexed at: " . (List::MoreUtils::first_index {$_ == $pre_power1} @ordered_powers) . "\n";
#		print "\tprereq 2 for $power is $pre_power2. Indexed at: " . (List::MoreUtils::first_index {$_ == $pre_power2} @ordered_powers) . "\n\n";

		if(defined($pre_power2) == 1)
		{
#			print "Adding powers: $pre_power1, $pre_power2, $power\n";
			if((List::MoreUtils::first_index {$_ == $pre_power2} @ordered_powers) == -1)
			{
				if(defined($pre_power1) == 1)
				{
					if((List::MoreUtils::first_index {$_ == $pre_power1} @ordered_powers) == -1)
					{
						push(@ordered_powers, $pre_power1);
						push(@ordered_powers, $pre_power2);
						push(@ordered_powers, $power);
					}
					else
					{
						splice(@ordered_powers, (List::MoreUtils::first_index {$_ == $pre_power1} @ordered_powers) + 1, 0, $pre_power2);
						splice(@ordered_powers, (List::MoreUtils::first_index {$_ == $pre_power2} @ordered_powers) + 1, 0, $power);
					}
				}
			}
			else
			{
				splice(@ordered_powers, (List::MoreUtils::first_index {$_ == $pre_power2} @ordered_powers) + 1, 0, $power);
			}
		}
		elsif(defined($pre_power1) == 1)
		{
			if((List::MoreUtils::first_index {$_ == $pre_power1} @ordered_powers) == -1)
			{
				push(@ordered_powers, $pre_power1);
				push(@ordered_powers, $power);
			}
			else
			{
				splice(@ordered_powers, (List::MoreUtils::first_index {$_ == $pre_power1} @ordered_powers) + 1, 0, $power);
			}
		}
		else
		{
			push(@ordered_powers, $power);
		}
	}
	
	@ordered_powers = List::MoreUtils::uniq(@ordered_powers);
#	print join " ", @ordered_powers;
#	print "\n";
#	exit;
	my $i = 0;
	foreach my $power_row (@ordered_powers)
	{
		next if ($table->get_cell($power_row, 'iconresref') eq '');
		$i++;
				
		$name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($power_row, 'name'));
		if($name eq 'Bad StrRef') { $name .= ' (' . $table->get_cell($power_row, 'label') . ')'; }

		KSE::GUI::Main::SetResourceStep("Populating power table.\nGetting image for power \"$name\": ");
		$image = KSE::Functions::Directory::GetFileImage($table->get_cell($power_row, 'iconresref'));		
		KSE::GUI::Main::SetResourceStep("Populating power table.\nGetting image for power \"$name\": $image");
		
		$value = GetHasPower($target, $power_row);
		
		$index = $power_row;
		
		KSE::GUI::Main::SetResourceStep("Populating power table.\nAdding power \"$name\" to the list.");
		$self->PopulatePowers($image, $name, $value, $index);
		KSE::GUI::Main::SetResourceStep("Populating power table.\nFinished power \"$name\".");
		
		KSE::GUI::Main::SetResourceProgress(20 + (($i / scalar(@ordered_powers)) * 80));
	}
}

sub GetPrerequisite
{
	my ($power, $column) = @_;
	
	my $pre = $table->get_cell($power, 'prerequisites');
	
	my ($pre1, $pre2) = split(/\_/, $pre);
	
#	print "Power: $power\nPre1: $pre1\nPre2: $pre2\n\n";
	if(defined($pre1) == 1 && $pre1 ne '' && $column == 1)		{ return $pre1; }
	elsif(defined($pre2) == 1 && $pre2 ne '' && $column == 2)	{ return $pre2; }
	else														{ return undef; }
}

sub GetHasPower
{
	my ($target, $power_index) = @_;
	my $class = KSE::Functions::Classes::GetCurrentClass($target);
#	print "Class2: $class\n";
	
	my $value = 0;
	my @powers = @{KSE::Functions::Saves::GetSaveData($target, 'Class' . $class, 'Powers')};
	
	if((List::MoreUtils::first_index {$_ == $power_index} @powers) == -1)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

sub GetDescription
{
	my $power_index = shift;
	
	my $desc_strref = $table->get_cell($power_index, 'spelldesc');
	my $description = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $desc_strref);
	
	return $description;
}

sub AddPower
{
	my ($target, $power_to_add) = @_;
	my $class = KSE::Functions::Classes::GetCurrentClass($target);
	
#	print "Class is $class\n";
	
	my @powers = @{KSE::Functions::Saves::GetSaveData($target, 'Class' . $class, 'Powers')};
	
#	print "Before: ";
#	print join " ", @powers;
#	print "\n";

	my $power_exists = 0;
	foreach (@powers)
	{
		if($_ == $power_to_add) { $power_exists = 1; last; }
	}
	
	if($power_exists == 0)
	{
		push(@powers, $power_to_add);
	}
	
#	print "After: ";
#	print join " ", @powers;
#	print "\n";

	KSE::Functions::Saves::SetSaveData(\@powers, $target, 'Class' . $class, 'Powers');

	@powers = @{KSE::Functions::Saves::GetSaveData($target, 'Class' . $class, 'Powers')};
	
#	print "Now: ";
#	print join " ", @powers;
#	print "\n";

}

sub RemovePower
{
	my ($target, $power_to_remove) = @_;
	my $class = KSE::Functions::Classes::GetCurrentClass($target);

	my @powers = @{KSE::Functions::Saves::GetSaveData($target, 'Class' . $class, 'Powers')};
	
	my $power_count = (scalar @powers) - 1;
	my $power_index = -1;
	my $power_found = -1;
	
	foreach (@powers)
	{
		$power_index++;
		if($_ == $power_to_remove) { $power_found = $power_index; last; }
	}
	
	if($power_found >= 0)
	{
		splice(@powers, $power_found, 1);
	}
	
	KSE::Functions::Saves::SetSaveData(\@powers, $target, 'Class' . $class, 'Powers');
}

return 1;