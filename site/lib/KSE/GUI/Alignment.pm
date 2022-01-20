#line 1 "KSE/GUI/Alignment.pm"
package KSE::GUI::Alignment;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Data;

use Tk;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::Scale;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $type = shift;
	my $game = shift;
	
#	print "Invocant: $invocant\tType: $type\tGame: $game\n";
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
	
#	$self->{'Data'}{'Row'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'GoodEvil');
	KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'GoodEvil'), 'Alignment', 'Row');
}

sub Create
{
	my ($self, $parent) = @_;
	
	KSE::Data::SetGUIData(50, 'Alignment', 'Row');
#	print "Alignment of " . $self->{Type} . " is " . $self->{'Data'}{'Row'} . "\n";
	
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'top', -fill=>'x', -padx=>5);
	
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->Scale(
	-label=>"Alignment     (<=40 -> Evil, 41-59 -> Neutral, 60=> -> Good)",
	-command=>[\&AdjustAlignment, $self],
	-from=>0,
	-to=>100,
	-tickinterval=>10,
	-length=>500,
	-orient=>'horizontal',
	-variable=>KSE::Data::GetGUIDataRef('Alignment', 'Row')
	)->pack(-side=>'left', -fill=>'x', -pady=>5);
}

sub AdjustAlignment
{
	my $self = shift;
	
#	$self->{'Data'}{'Row'} = $data;
#	
#	print "Setting Alignment for " . KSE::GUI::Target::GetTarget() . " to " . $self->{'Data'}{'Row'} . ".\n";
	KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Alignment', 'Row'), KSE::GUI::Target::GetTarget(), 'GoodEvil');
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