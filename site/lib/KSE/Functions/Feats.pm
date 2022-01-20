#line 1 "KSE/Functions/Feats.pm"
package KSE::Functions::Feats;

use Bioware::TLK;
use Bioware::TwoDA;

use List::MoreUtils;

use KSE::GUI::Feats;
use KSE::GUI::Main;

use KSE::Functions::Saves;
use KSE::Functions::Directory;

my $table = Bioware::TwoDA->new();

sub Assign2da
{
	$table->read2da(KSE::Functions::Directory::GetFile('feat.2da'));
}

# sub AddToArray
# {
	# my ($array, $element, $after) = @_;
#	
	# my @new = ();
#	
	# foreach my $piece (@$array)
	# {
		# if($piece == $after)
		# {
			# push (@new, $piece, $element);
		# }
		# else
		# {
			# push (@new, $piece);
		# }
	# }
#	
	# $array = \@new;
# }

sub CountFeatList
{
	return $table->{rows};
}

sub FillFeats
{
	my $self = shift;
	my $target = $self->{'Type'};
	
	my ($image, $name, $value, $index) = (undef, undef, undef, undef);

	my @ordered_feats = ();
	foreach my $feat (0 .. $table->{rows})
	{
		if (grep(/^$feat$/, @ordered_feats))
		{
#			print "Feat1 $feat is already in\n";
			next;
		}
		
		my $pre_feat1 = GetPrerequisite($feat, 1);
		my $pre_feat2 = GetPrerequisite($feat, 2);
		
#		print "Processing Feat $feat\n";
#		print "\tprereq 1 for $feat is $pre_feat1. Indexed at: " . (List::MoreUtils::first_index {$_ == $pre_feat1} @ordered_feats) . "\n";
#		print "\tprereq 2 for $feat is $pre_feat2. Indexed at: " . (List::MoreUtils::first_index {$_ == $pre_feat2} @ordered_feats) . "\n\n";

		if(defined($pre_feat2) == 1)
		{
#			print "Adding Feats: $pre_feat1, $pre_feat2, $feat\n";
			if((List::MoreUtils::first_index {$_ == $pre_feat2} @ordered_feats) == -1)
			{
				if(defined($pre_feat1) == 1)
				{
					if((List::MoreUtils::first_index {$_ == $pre_feat1} @ordered_feats) == -1)
					{
						push(@ordered_feats, $pre_feat1);
						push(@ordered_feats, $pre_feat2);
						push(@ordered_feats, $feat);
					}
					else
					{
						splice(@ordered_feats, (List::MoreUtils::first_index {$_ == $pre_feat1} @ordered_feats) + 1, 0, $pre_feat2);
						splice(@ordered_feats, (List::MoreUtils::first_index {$_ == $pre_feat2} @ordered_feats) + 1, 0, $feat);
					}
				}
			}
			else
			{
				splice(@ordered_feats, (List::MoreUtils::first_index {$_ == $pre_feat2} @ordered_feats) + 1, 0, $feat);
			}
		}
		elsif(defined($pre_feat1) == 1)
		{
			if((List::MoreUtils::first_index {$_ == $pre_feat1} @ordered_feats) == -1)
			{
				push(@ordered_feats, $pre_feat1);
				push(@ordered_feats, $feat);
			}
			else
			{
				splice(@ordered_feats, (List::MoreUtils::first_index {$_ == $pre_feat1} @ordered_feats) + 1, 0, $feat);
			}
		}
		else
		{
			push(@ordered_feats, $feat);
		}
	}
	
	@ordered_feats = List::MoreUtils::uniq(@ordered_feats);
#	print join " ", @ordered_feats;
#	print "\n";
#	exit;
	my $i = 0;
	my $ii = scalar @ordered_feats;
	foreach my $feat_row (@ordered_feats)
	{
		next if ($table->get_cell($feat_row, 'icon') eq '');
		$i++;
		
		$name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($feat_row, 'name'));
		if($name eq 'Bad StrRef') { $name .= ' (' . $table->get_cell($feat_row, 'label') . ')'; }

		KSE::GUI::Main::SetResourceStep("Populating feat table.\nGetting image for feat \"$name\": ");
		$image = KSE::Functions::Directory::GetFileImage($table->get_cell($feat_row, 'icon'));
		KSE::GUI::Main::SetResourceStep("Populating feat table.\nGetting image for feat \"$name\": $image");
		
		$value = GetHasFeat($target, $feat_row);

		$index = $feat_row;
		
		KSE::GUI::Main::SetResourceStep("Populating feat table.\nAdding feat \"$name\" to the list.");
		$self->PopulateFeats($image, $name, $value, $index);
		KSE::GUI::Main::SetResourceStep("Populating feat table.\nFinished feat \"$name\".");
		
		KSE::GUI::Main::SetResourceProgress(20 + int(($i / $ii) * 80));
	}
}

sub GetPrerequisite
{
	my ($feat, $column) = @_;
	
	my $pre = $table->get_cell($feat, 'prereqfeat' . $column);
	
	if(defined($pre) == 1 && $pre ne '')		{ return $pre; }
	else										{ return undef; }
}

sub GetHasFeat
{
	my ($target, $feat_index) = @_;
	
	my $value = 0;
	my @feats = @{KSE::Functions::Saves::GetSaveData($target, 'Feats')};
	
#	print "Feats: ";
#	print join " ", @feats;
#	print "\n";
	if((List::MoreUtils::first_index {$_ == $feat_index} @feats) == -1)
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
	my $feat_index = shift;
	
	my $desc_strref = $table->get_cell($feat_index, 'description');
	my $description = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $desc_strref);
	
	return $description;
}

sub AddFeat
{
	my ($target, $feat_to_add) = @_;
	my @feats = @{KSE::Functions::Saves::GetSaveData($target, 'Feats')};
	
#	print "Before: ";
#	print join " ", @feats;
#	print "\n";

	my $feat_exists = 0;
	foreach (@feats)
	{
#		print "checking feat $_\n";
		if($_ == $feat_to_add) { $feat_exists = 1; last; }
	}
	
	if($feat_exists == 0)
	{
		push(@feats, $feat_to_add);
	}

#	print "After: ";
#	print join " ", @feats;
#	print "\n";
	
	KSE::Functions::Saves::SetSaveData(\@feats, $target, 'Feats');
}

sub RemoveFeat
{
	my ($target, $feat_to_remove) = @_;
	my @feats = @{KSE::Functions::Saves::GetSaveData($target, 'Feats')};
	
	my $feat_count = (scalar @feats) - 1;
	my $feat_index = -1;
	my $feat_found = -1;
	
	foreach (@feats)
	{
		$feat_index++;
		if($_ == $feat_to_remove)	{ $feat_found = $feat_index; last; }
	}
	
	if($feat_found >= 0)
	{
		splice(@feats, $feat_found, 1);
	}
	
	KSE::Functions::Saves::SetSaveData(\@feats, $target, 'Feats');
}

return 1;