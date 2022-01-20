#line 1 "KSE/GUI/Classes.pm"
package KSE::GUI::Classes;

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
	$self->{'Type'} = 'Player';
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
	
	KSE::Functions::Classes::GetClassInfo($self, 1);
	KSE::Functions::Classes::GetClassInfo($self, 2);
	
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	
	KSE::GUI::Main::SetResourceStep('Creating class info frame.');
	# Class Info Frames
	$self->{'GUI'}{'ClassFrame'} = $self->{'GUI'}{'Frame'}->Frame(-height=>500, -width=>150)->pack(-side=>'left', -anchor=>'nw', -padx=>15, -pady=>5);
	KSE::GUI::Main::SetResourceProgress(10);
	
	# Target list
#	$self->{'GUI'}{'TargetSelection'} = KSE::GUI::GameControls->new('Classes', $game);
#	$self->{'GUI'}{'TargetSelection'}->CreatePCorNPCDropdown($self->{'GUI'}{'ClassFrame'}, 'Classes');

	$self->{'GUI'}{'ClassFrame1'} = $self->{'GUI'}{'ClassFrame'}->Frame(-height=>100, -width=>150)->pack(-fill=>'x', -anchor=>'nw', -padx=>15, -pady=>5);
	$self->{'GUI'}{'ClassFrame2'} = $self->{'GUI'}{'ClassFrame'}->Frame(-height=>100, -width=>150)->pack(-fill=>'x', -anchor=>'nw', -padx=>15, -pady=>5);
	
	# Class 1 Info
	$self->{'GUI'}{'ClassFrame1'}->Label(-text=>'Class 1 and Level:  ')->pack(-fill=>'x');
	$self->{'GUI'}{'ClassFrame1'}->Label(-textvariable=>\$self->{'Data'}{'Class1Name'}, -width=>20)->pack(-side=>'left', -padx=>5);
	$self->{'GUI'}{'ClassFrame1'}->Spinbox(-from=>1, -to=>KSE::Functions::Classes::GetLevelCap($self), -increment=>1, -textvariable=>\$self->{'Data'}{'Class1Level'}, -width=>4, -command=>[\&KSE::Functions::Classes::SetClassLevel, $self, 1])->pack(-side=>'right', -padx=>10);
	
	# Class 2 Info
	$self->{'GUI'}{'ClassFrame2'}->Label(-text=>'Class 2 and Level:  ')->pack(-fill=>'x');
	$self->{'GUI'}{'ClassFrame2'}->Label(-textvariable=>\$self->{'Data'}{'Class2Name'}, -width=>20)->pack(-side=>'left', -padx=>5);
	$self->{'GUI'}{'ClassFrame2'}->Spinbox(-from=>1, -to=>KSE::Functions::Classes::GetLevelCap($self), -increment=>1, -textvariable=>\$self->{'Data'}{'Class2Level'}, -width=>4, -command=>[\&KSE::Functions::Classes::SetClassLevel, $self, 2])->pack(-side=>'right', -padx=>10);
	
	# Class Selection Frame
	$self->{'GUI'}{'ListFrame'} = $self->{'GUI'}{'Frame'}->Frame(-height=>500, -width=>150)->pack(-side=>'left', -anchor=>'nw', -padx=>15, -pady=>5);
	$self->{'GUI'}{'ListFrame1'} = $self->{'GUI'}{'ListFrame'}->Frame(-height=>400, -width=>150)->pack(-fill=>'x', -anchor=>'n', -padx=>5, -pady=>5);
	$self->{'GUI'}{'ListFrame2'} = $self->{'GUI'}{'ListFrame'}->Frame(-height=>100, -width=>150)->pack(-fill=>'x', -anchor=>'n', -padx=>5, -pady=>15);
	KSE::GUI::Main::SetResourceProgress(40);
	
	KSE::GUI::Main::SetResourceStep('Creating class buttons.');
	# Class Updating Buttons
	$self->{'GUI'}{'ListFrame2'}->Button(-text=>'Add Class 1',		-command=>[\&KSE::Functions::Classes::AddClass, $self, 1])->pack(-side=>'left', -padx=>10, -pady=>5);
	$self->{'GUI'}{'ListFrame2'}->Button(-text=>'Remove Class 1',	-command=>[\&KSE::Functions::Classes::RemoveClass, $self, 1])->pack(-side=>'left', -padx=>10, -pady=>5);
	$self->{'GUI'}{'ListFrame2'}->Button(-text=>'Add Class 2',		-command=>[\&KSE::Functions::Classes::AddClass, $self, 2])->pack(-side=>'left', -padx=>10, -pady=>5);
	$self->{'GUI'}{'ListFrame2'}->Button(-text=>'Remove Class 2',	-command=>[\&KSE::Functions::Classes::RemoveClass, $self, 2])->pack(-side=>'left', -padx=>10, -pady=>5);
	KSE::GUI::Main::SetResourceProgress(65);
	
	KSE::GUI::Main::SetResourceStep('Reading available classes.');
	# Class List
	$self->{'GUI'}{'List'} = $self->{'GUI'}{'ListFrame1'}->Scrolled('Listbox', -scrollbars=>'osoe', -background=>'white', -selectborderwidth=>'0', -selectforeground=>'#FFFFFF', -selectbackground=>'#009000', -selectmode=>'extended')->pack(-fill=>'both', -padx=>5, -pady=>5);
	$self->{'GUI'}{'List'}->bind('<<ListboxSelect>>'=>sub { SelectClass($self, ($self->{'GUI'}{'List'}->curselection())[0]); } );
	
	foreach(KSE::Functions::Classes::GetClassList())
	{
		$self->{'GUI'}{'List'}->insert('end', $_);
	}
	KSE::GUI::Main::SetResourceProgress(90);
}

sub SelectClass
{
	my $self = shift;
	my @data = @_;
	
	$self->{'Data'}{'CurrentClass'} = $data[-1];
}

sub ChangeClassExternal
{
	my ($self, $target) = @_;
	
#	print "Self: $self\nTarget: $target\n";
	$self->{'Type'} = $target;
	
	KSE::Functions::Classes::GetClassInfo($self, 1);
	KSE::Functions::Classes::GetClassInfo($self, 2);
		
#	UpdateClassDropdown($self);
}

sub ChangeTarget
{
	my $target = shift;
	my $self = KSE::GUI::Main::GetPanelSelf('Classes');
	$self->{'Type'} = $target;
	
#	print "self is $self\nTarget is $target\n";
	KSE::Functions::Classes::GetClassInfo($self, 1);
	KSE::Functions::Classes::GetClassInfo($self, 2);
	
	$self->{'Data'}{'Class1Name'} = $self->{'Data'}{'Class1Name'};
	$self->{'Data'}{'Class1Level'} = $self->{'Data'}{'Class1Level'};
	$self->{'Data'}{'Class2Name'} = $self->{'Data'}{'Class2Name'};
	$self->{'Data'}{'Class2Level'} = $self->{'Data'}{'Class2Level'};
	
#	UpdateClassDropdown($self);
}

sub CreateClassDropdown
{
	my ($self, $parent, $source) = @_;
	
	$self->{'Choices'}	= KSE::Functions::Classes::GetClasses(KSE::GUI::Target::GetTarget());
	$self->{'Source'}	= $source;
	$self->{'Typetext'} = @{$self->{'Choices'}}[0];
	
	KSE::Functions::Classes::SetCurrentClass(KSE::GUI::Target::GetTarget(), 1);
	
	$self->{'GUI'}{'ChoiceParent'}	= $parent;
	$self->{'GUI'}{'ChoiceFrame'}	= $self->{'GUI'}{'ChoiceParent'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -anchor=>'nw');
	$self->{'GUI'}{'ChoiceBrowse'}	= $self->{'GUI'}{'ChoiceFrame'}->BrowseEntry(-label=>'Class: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub {my ($widget, $data) = @_; $self->{'Data'}{'Row'} = $data; KSE::Functions::Classes::ChangeClass(KSE::GUI::Target::GetTarget(), $self->{'Data'}{'Row'} + 1); KSE::GUI::Powers::ChangePowersExternal(KSE::GUI::Main::GetPanelSelf('Powers'), KSE::GUI::Target::GetTarget()); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -choices=>$self->{'Choices'}, -variable=>\$self->{'Typetext'})->pack(-fill=>'x', -padx=>10, -pady=>5);
	
#	$self->{'GUI'}{'Row'} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);
#	$self->{'GUI'}{'Row'}->Label(-text=>'Row Number: ')->pack(-side=>'left', -padx=>5);
#	$self->{'GUI'}{'Row'}->Label(-textvariable=>\$self->{'Data'}->{'Row'})->pack(-side=>'right', -padx=>5);
}

sub UpdateClassDropdown
{
	my $self = shift;
	
	$self->{'GUI'}{'ChoiceBrowse'}->delete(0, 'end');
	
	my @choices = @{KSE::Functions::Classes::GetClasses(KSE::GUI::Target::GetTarget())};
	foreach(@choices)
	{
		$self->{'GUI'}{'ChoiceBrowse'}->insert('end', $_);
	}
	
	$self->{'Typetext'} = $self->{'GUI'}{'ChoiceBrowse'}->get(KSE::Functions::Classes::GetCurrentClass(KSE::GUI::Target::GetTarget()) - 1);
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