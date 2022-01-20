#line 1 "KSE/GUI/Soundset.pm"
package KSE::GUI::Soundset;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $type = shift;
	my $game = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'} = $type;
	$self->{'Game'} = $game;
	$self->{'Data'} = {};
	$self->{'GUI'} = {};
    bless $self,$class;
    return $self;
}

sub GetDataPiece
{
	my ($self, $piece) = @_;

	return $self->{'Data'}{$piece};
}

sub SetDataPiece
{
	my ($self, $piece, $data) = @_;
	
	$self->{'Data'}{$piece} = $data;
}

sub ChangeTarget
{
	my ($self, $target) = @_;
	$self->{'Type'} = $target;
	
#	$self->{'Data'}{'Row'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'SoundSetFile');
#	$self->{'Data'}{'Label'} = $self->{'Data'}{'Row'} . ' - ' . KSE::Functions::Soundset::GetLabel($self->{'Data'}{'Row'});
	KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'SoundSetFile'), 'Soundset', 'Row');
	KSE::Data::SetGUIData(KSE::Data::GetGUIData('Soundset', 'Row') . ' - ' . KSE::Functions::Soundset::GetLabel(KSE::Data::GetGUIData('Soundset', 'Row')), 'Soundset', 'Label');
}

sub Create
{
	my ($self, $parent) = @_;
	
#	$self->{'Data'}{'Row'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'SoundSetFile');
#	$self->{'Data'}{'Label'} = $self->{'Data'}{'Row'} . ' - ' . KSE::Functions::Soundset::GetLabel($self->{'Data'}{'Row'});
	KSE::Data::SetGUIData(0, 'Soundset', 'Row');
	KSE::Data::SetGUIData(KSE::Data::GetGUIData('Soundset', 'Row') . ' - ' . KSE::Functions::Soundset::GetLabel(KSE::Data::GetGUIData('Soundset', 'Row')), 'Soundset', 'Label');
	
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'top', -fill=>'x', -padx=>5);
	
#	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->BrowseEntry(-label=>'  Soundset:          ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub { my ($widget, $data) = @_; $self->{'Data'}{'Row'} = $data; KSE::Functions::Soundset::ChangeSoundset($self); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>\$self->{'Data'}{'Label'})->pack(-side=>'left', -fill=>'x', -pady=>5);
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->BrowseEntry(-label=>'  Soundset:          ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub { my ($widget, $data) = @_; KSE::Data::SetGUIData($data, 'Soundset', 'Row'); KSE::Functions::Soundset::ChangeSoundset($self); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>KSE::Data::GetGUIDataRef('Soundset', 'Label'))->pack(-side=>'left', -fill=>'x', -pady=>5);
	
#	$self->{'GUI'}{'Row'} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);
#	$self->{'GUI'}{'Row'}->Label(-text=>'Row Number: ')->pack(-side=>'left', -padx=>5);
#	$self->{'GUI'}{'Row'}->Label(-textvariable=>\$self->{'Data'}{'Row'})->pack(-side=>'right', -padx=>5);

	$self->FillList();
}

sub FillList
{
	my ($self, @list) = (shift, @_);
	my @list = KSE::Functions::Soundset::GetRowLabels();
	$self->ClearList();
	
	my $count = -1;
	foreach my $choice (@list)
	{
		$count++;
		$self->{'GUI'}{'List'}->insert('end', $count . ' - ' . $choice);
	}
}

sub ClearList
{
	my $self = shift;
	
	$self->{'GUI'}{'List'}->delete(0, 'end');
}

sub destroy
{
	my $self = shift;
	
#	foreach ($self->{'GUI'}{'Frame'}->children)
#	{
#		$_->destroy;
#	}
	foreach (keys %{$self->{'GUI'}})
	{
		delete $self->{'GUI'}{$_};
	}
	foreach (keys %{$self->{'Data'}})
	{
		delete $self->{'Data'}{$_};
	}
	
	delete $self->{'GUI'};
	delete $self->{'Data'};
	delete $self->{'Type'};
	
	$self = undef;
}

return 1;