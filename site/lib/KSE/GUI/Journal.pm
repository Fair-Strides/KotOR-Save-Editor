#line 1 "KSE/GUI/Journal.pm"
package KSE::GUI::Journal;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::GUI::Main;
use KSE::GUI::Powers;

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $game = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };

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

sub Create
{
	my ($self, $parent) = @_;
		
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}		= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');

	KSE::GUI::Main::SetResourceStep('Creating Journal quest selection frame.');
	# Quest Selection Frame
	$self->{'GUI'}{'ListFrame'} = $self->{'GUI'}{'Frame'}->Frame(-height=>500, -width=>150)->pack(-side=>'right', -anchor=>'nw', -padx=>15, -pady=>5, -fill=>'x');
	KSE::GUI::Main::SetResourceProgress(20);
	
	KSE::GUI::Main::SetResourceStep('Creating Journal quest list.');
	# Quest List
	$self->{'GUI'}{'List'} = $self->{'GUI'}{'ListFrame'}->Scrolled('Listbox', -scrollbars=>'osoe', -background=>'white', -selectborderwidth=>'0', -selectforeground=>'#FFFFFF', -selectbackground=>'#009000', -height=>40, -width=>40, -selectmode=>'extended')->pack(-fill=>'both', -padx=>5, -pady=>5);
	$self->{'GUI'}{'List'}->bind('<<ListboxSelect>>'=>sub { SelectQuest($self, ($self->{'GUI'}{'List'}->curselection)[0]); } );
	KSE::GUI::Main::SetResourceProgress(40);
	
	KSE::GUI::Main::SetResourceStep('Creating Journal quest info frames.');
	# Quest Info Frames
	$self->{'GUI'}{'QuestFrame'} = $self->{'GUI'}{'Frame'}->Frame(-height=>500, -width=>150)->pack(-side=>'left', -anchor=>'nw', -padx=>15, -pady=>5);

	$self->{'GUI'}{'QuestFrame1'} = $self->{'GUI'}{'QuestFrame'}->Frame(-height=>100, -width=>150)->pack(-fill=>'x', -anchor=>'nw', -padx=>15, -pady=>5);
	$self->{'GUI'}{'QuestFrame2'} = $self->{'GUI'}{'QuestFrame'}->Frame(-height=>100, -width=>150)->pack(-fill=>'x', -anchor=>'nw', -padx=>15, -pady=>5);
	KSE::GUI::Main::SetResourceProgress(50);
	
	KSE::GUI::Main::SetResourceStep('Creating Journal quest info and progress display.');
	# Quest Info
	$self->{'GUI'}{'QuestFrame1'}->Label(-text=>'Quest State:  ')->pack();
#	$self->{'GUI'}{'QuestFrame1'}->Label(-textvariable=>\$self->{'Data'}{'QuestName'}, -width=>15)->pack(-side=>'left', -anchor=>'s', -padx=>5);
	$self->{'GUI'}{'EntryList'} = $self->{'GUI'}{'QuestFrame1'}->BrowseEntry(-label=>'Current Entry: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub {my ($widget, $data) = @_; $self->{'Data'}{'Row'} = $data; $self->RefreshEntryText($self->{'Data'}{'Label'}); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>\$self->{'Data'}{'Label'})->pack(-fill=>'x', -padx=>10, -pady=>5);
	$self->{'GUI'}{'QuestFrame1'}->Button(-text=>'Apply', -command=>sub { KSE::Functions::Journal::SetQuestState($self->{'Data'}{'CurrentQuest'}, $self->{'Data'}{'Label'}); $self->RefreshEntryText(); })->pack(-padx=>10, -pady=>5);
	KSE::GUI::Main::SetResourceProgress(70);
	
	# Quest Entry Display
	$self->{'GUI'}{'QuestText'} = $self->{'GUI'}{'QuestFrame2'}->Scrolled('ROText', -scrollbars=>'oe', -wrap=>'word', -background=>'SystemButtonFace', -font=>[-size=>12], -height=>25, -width=>60, -relief=>'flat', -state=>'disabled')->pack(-fill=>'both', -padx=>5, -pady=>5);
	KSE::GUI::Main::SetResourceProgress(90);
}

sub AddQuest
{
	my ($self, $quest) = @_;
	
	$self->{'GUI'}{'List'}->insert('end', $quest);
}

sub SelectQuest
{
	my $self = shift;
	my @data = @_;
	
	$self->{'Data'}{'CurrentQuest'} = $data[-1];
	$self->{'Data'}{'QuestName'}	= KSE::Functions::Journal::GetQuestName($self->{'Data'}{'CurrentQuest'});

	my @entries = KSE::Functions::Journal::GetQuestEntries($self->{'Data'}{'CurrentQuest'});
#	print "Array: @entries\nScalar: " . scalar(@entries) . "\n" . join("_", @entries) . "\n";
	
	$self->{'Data'}{'Label'} = KSE::Functions::Journal::GetQuestState($self->{'Data'}{'CurrentQuest'});
	$self->{'GUI'}{'EntryList'}->configure(-choices=>@entries);
	
	$self->RefreshEntryText();
}

sub RefreshEntryText
{
	my ($self, $state) = @_;
	
	$self->{'GUI'}{'QuestText'}->configure(-state=>'normal');
	if(defined($state) == 1)
	{
		$self->{'GUI'}{'QuestText'}->Contents(KSE::Functions::Journal::GetEntryText($self->{'Data'}{'CurrentQuest'}, $state));
	}
	else
	{
		$self->{'GUI'}{'QuestText'}->Contents(KSE::Functions::Journal::GetEntryText($self->{'Data'}{'CurrentQuest'}, KSE::Functions::Journal::GetQuestState($self->{'Data'}{'CurrentQuest'})));
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
	
	$self = undef;
}

return 1;