#line 1 "KSE/Functions/Portrait.pm"
package KSE::Functions::Portrait;

use KSE::GUI::Portrait;
use KSE::GUI::Main;
use KSE::Functions::Saves;
use KSE::Functions::Directory;
use Bioware::TwoDA;

my $table = Bioware::TwoDA->new();

sub Assign2da
{
	$table->read2da(KSE::Functions::Directory::GetFile('portraits.2da'));
}

sub GetRowLabels
{
	my @labels = ();
	for (my $i = 0; $i < $table->{rows}; $i++)
	{
#		print "I $i label " . $table->get_cell($i, 'label') . "\n";
		
		push(@labels, uc($table->get_cell($i, 'baseresref')));
	}
	
	return @labels;
}

sub GetLabel
{
	my $row = shift;
	
	return uc($table->get_cell($row, 'baseresref'));
}

sub GetPortraitByAlignment
{
	my ($row, $alignment) = @_;
	
	my $column = 'baseresref';
	
	if($alignment <= 10)
	{
		$column = 'baseresrefvvve';
	}
	elsif($alignment <= 20)
	{
		$column = 'baseresrefvve';
	}
	elsif($alignment <= 30)
	{
		$column = 'baseresrefve';
	}
	elsif($alignment <= 40)
	{
		$column = 'baseresrefe';
	}
	
#	print "Row: $row\tAlignment: $alignment\tValue: " . $table->get_cell($row, $column) . "\n";
	return $table->get_cell($row, $column);
}

sub GetPortraitFileByAlignment
{
	my ($row, $alignment) = @_;
	
	my $column = 'baseresref';
	
	if($alignment <= 10)
	{
		$column = 'baseresrefvvve';
	}
	elsif($alignment <= 20)
	{
		$column = 'baseresrefvve';
	}
	elsif($alignment <= 30)
	{
		$column = 'baseresrefve';
	}
	elsif($alignment <= 40)
	{
		$column = 'baseresrefe';
	}
	
	my $portrait = $table->get_cell($row, $column);
	if($portrait eq '****' or $portrait eq '') { $portrait = $table->get_cell($row, 'baseresref'); }
	
#	print "Row: $row\tAlignment: $alignment\tValue: " . $portrait . "\n";
	return KSE::Functions::Directory::GetFileImage($portrait);
}

sub GetPortraitFile
{
	my ($row, $column) = @_;
#	print "Row: $row, Column: $column\n";
	return(KSE::Functions::Directory::GetFileImage($table->get_cell($row, $column)));
}

sub ChangePortrait
{
	my $portrait_object = shift;
	my $type = $portrait_object->{'Type'};
	
	if($type eq 'Player')
	{
		KSE::Functions::Saves::SetSaveData($portrait_object->{'Data'}->{'Row'}, 'Player', 'PortraitId');
	}
	elsif($type =~ /NPC(\d)/)
	{
		my $npc_num = $1;
		
		KSE::Functions::NPC::SetData($npc_num, $portrait_object->{'Data'}->{'Row'}, 'PortraitId');
	}
}

return 1;