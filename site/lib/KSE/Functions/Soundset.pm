#line 1 "KSE/Functions/Soundset.pm"
package KSE::Functions::Soundset;

use KSE::GUI::Soundset;
use KSE::GUI::Main;
use KSE::Functions::Saves;
use KSE::Functions::Directory;
use Bioware::TwoDA;

my $table = Bioware::TwoDA->new();

sub Assign2da
{
	$table->read2da(KSE::Functions::Directory::GetFile('soundset.2da'));
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

sub ChangeSoundset
{
	my $soundset_object = shift;
	my $type = $soundset_object->{'Type'};
	
	if($type eq 'Player')
	{
		KSE::Functions::Saves::SetSaveData($soundset_object->{'Data'}->{'Row'}, 'Player', 'SoundSetFile');
	}
	elsif($type =~ /NPC(\d)/)
	{
		my $npc_num = $1;
		
		KSE::Functions::NPC::SetData($npc_num, $soundset_object->{'Data'}->{'Row'}, 'SoundSetFile');
	}
}

return 1;