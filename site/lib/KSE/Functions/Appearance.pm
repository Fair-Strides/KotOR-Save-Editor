#line 1 "KSE/Functions/Appearance.pm"
package KSE::Functions::Appearance;

use KSE::GUI::Appearance;
use KSE::GUI::Main;
use KSE::Functions::Saves;
use KSE::Functions::Directory;
use Bioware::TwoDA;

my $table = Bioware::TwoDA->new();

sub Assign2da
{
	$table->read2da(KSE::Functions::Directory::GetFile('appearance.2da'));
}

sub GetModel
{
	my ($row, $cell) = @_;
	
	return $table->get_cell($row, 'model' . lc($cell));
}

sub GetLabel
{
	my $row = shift;
	
	return $table->get_cell($row, 'label');
}

sub GetRowLabels
{
	my @labels = ();
	for (my $i = 0; $i < $table->{rows}; $i++)
	{
		push(@labels, $table->get_cell($i, 'label'));
	}
	
	return @labels;
}

sub ChangeAppearance
{
	my $appearance_object = shift;
	my $type = $appearance_object->{'Type'};
	
	if($type eq 'Player')
	{
		KSE::Functions::Saves::SetSaveData($appearance_object->{'Data'}->{'Row'}, 'Player', 'Appearance_Type');
	}
	elsif($type =~ /NPC(\d)/)
	{
		my $npc_num = $1;
		
		KSE::Functions::NPC::SetData($npc_num, $appearance_object->{'Data'}->{'Row'}, 'Appearance_Type');
	}
}

return 1;