#line 1 "KSE/GUI/GameControls.pm"
package KSE::GUI::GameControls;

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

sub CreatePCorNPCDropdown
{
	my ($self, $parent, $source) = @_;
	
	$self->{'Choices'}	= ['-1 - Player'];
	$self->{'Source'}	= $source;
	
	foreach my $npc (0 .. 12)
	{
		if(KSE::Functions::NPC::GetNPCExists($npc) == 1)
		{
#			print "Adding NPC$npc\n";
			push(@{$self->{'Choices'}}, $npc . ' - ' . KSE::Functions::NPC::GetName($npc));
		}
	}
	
	$self->{'GUI'}{'ChoiceParent'}	= $parent;
	$self->{'GUI'}{'ChoiceFrame'}	= $self->{'GUI'}{'ChoiceParent'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -anchor=>'nw');
	$self->{'GUI'}{'ChoiceBrowse'}	= $self->{'GUI'}{'ChoiceFrame'}->BrowseEntry(-label=>'Person: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub
	{
		my ($widget, $data) = @_;
		
		my $text = $widget->get($data);
#		print "\$data: $data\n\$text: $text\n";
		$text =~ /(\-?\d*) \-/;
#		print "\$1: $1\n";
		
		$self->{'Data'}{'Row'} = $1;
#		print "Row: " . $self->{'Data'}{'Row'} . "\n";
		
		if($self->{'Data'}{'Row'} > -1)
		{ $self->{'Type'} = 'NPC' . $self->{'Data'}{'Row'}; }
		else
		{ $self->{'Type'} = 'Player'; }
		
		$self->{'Data'}{'Row'} = $data;
		
		$self->ChangeTarget();
	}, -choices=>$self->{'Choices'}, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10)->pack(-fill=>'x', -padx=>10, -pady=>5);
	
#	$self->{'GUI'}{'Row'} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);
#	$self->{'GUI'}{'Row'}->Label(-text=>'Row Number: ')->pack(-side=>'left', -padx=>5);
#	$self->{'GUI'}{'Row'}->Label(-textvariable=>\$self->{'Data'}{'Row'})->pack(-side=>'right', -padx=>5);
}

sub UpdatePCorNPCDropdown
{
	my ($self, @choices) = @_;
	
	$self->{'GUI'}{'ChoiceBrowse'}->delete(0, 'end');

	foreach(@choices)
	{
		$self->{'GUI'}{'ChoiceBrowse'}->insert('end', $_);
	}
}

sub ChangeTarget
{
	my $self	= shift;
	my $self2	= KSE::GUI::Main::GetPanelSelf($self->{'Source'});
	my $source	= $self->{'Source'};
	my $target	= $self->{'Type'};
	
	if($source eq 'Classes')
	{
		$self2->KSE::GUI::Classes::ChangeClassExternal($target);
	}
	elsif($source eq 'Feats')
	{
		$self2->KSE::GUI::Feats::ChangeFeatsExternal($target);
	}
	elsif($source eq 'Powers')
	{
		$self2->KSE::GUI::Powers::ChangePowersExternal($target);
	}
	else # Equipment
	{
		$self2->KSE::GUI::Equipment::ChangeEquipmentExternal($target);
	}
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