#line 1 "KSE/GUI/Globals.pm"
package KSE::GUI::Globals;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Functions::Globals;

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::Radiobutton;
use Tk::Spinbox;

sub MoveList;

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
	
	$self->{'Data'}{'Type'} = 'Number';
	
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}		= $self->{'GUI'}{'Parent'}->Frame(-height=>700, -width=>900)->pack(-fill=>'both');
	
	$self->{'GUI'}{'FrameL'}	= $self->{'GUI'}{'Frame'}->Frame(-height=>700, -width=>300)->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameR'}	= $self->{'GUI'}{'Frame'}->Frame(-height=>700, -width=>300)->pack(-side=>'left', -padx=>25);
	
	KSE::GUI::Main::SetResourceStep('Creating Global Variable choice selection.');
	# Choice Dropdown
	$self->{'GUI'}{'Choice'}	= $self->{'GUI'}{'FrameL'}->BrowseEntry(-label=>'Global Type: ', -autolimitheight=>1, -listheight=>4, -autolistwidth=>1, -choices=>['Number', 'Boolean', 'String', 'Location'], -browsecmd=>sub {my ($widget, $data) = @_; $self->{'Data'}{'Type'} = $data; $self->RefreshEntries(); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10)->pack(-fill=>'x', -padx=>10, -pady=>5);
	
	# Variable Display
	$self->{'GUI'}{'FrameL'}->Label(-text=>'Current Global Variable: ', -width=>32, -font=>[-size=>15])->pack(-fill=>'x', -padx=>10);
	$self->{'GUI'}{'FrameL'}->Label(-textvariable=>\$self->{'Data'}{'Variable'}, -width=>32, -font=>[-size=>15])->pack(-fill=>'x', -padx=>10);
	
	# Choice Container
	$self->{'GUI'}{'TypeFrame'} = $self->{'GUI'}{'FrameL'}->Frame(-height=>200, -width=>300)->pack(-fill=>'x', -padx=>10, -pady=>15);
	KSE::GUI::Main::SetResourceProgress(20);
	
	KSE::GUI::Main::SetResourceStep('Creating Global Variable Number layout.');
	# Numeric Frame
	$self->{'Data'}{'NValue'} = 0;
	
	$self->{'GUI'}{'NumberFrame'} = $self->{'GUI'}{'TypeFrame'}->Frame(-height=>100, -width=>300);
	$self->{'GUI'}{'NumberCVFrame'} = $self->{'GUI'}{'NumberFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{'NumberVFrame'} = $self->{'GUI'}{'NumberFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	
	$self->{'GUI'}{'NumberCVFrame'}->Label(-text=>'Current Value: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left');
	$self->{'GUI'}{'NumberCVFrame'}->Label(-textvariable=>\$self->{'Data'}{'NCurrentValue'}, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>15);
	
	$self->{'GUI'}{'NumberVFrame'}->Label(-text=>'New Value: ', -width=>15, -anchor=>'w')->pack(-side=>'left');
	$self->{'GUI'}{'NumberVFrame'}->Spinbox(-from=>-128, -to=>127, -increment=>1, -textvariable=>\$self->{'Data'}{'NValue'}, -width=>4)->pack(-side=>'left', -padx=>15);
	$self->{'GUI'}{'NumberVFrame'}->Button(-text=>'Assign', -command=>sub { $self->{'Data'}{'NCurrentValue'} = $self->{'Data'}{'NValue'}; KSE::Functions::Globals::SetGlobalValue($self->{'Data'}{'Variable'}, 'Number', $self->{'Data'}{'NValue'}); }, -width=>5)->pack(-side=>'left', -padx=>15);
	KSE::GUI::Main::SetResourceProgress(35);
	
	KSE::GUI::Main::SetResourceStep('Creating Global Variable Boolean layout.');
	# Boolean Frame
	$self->{'Data'}{'BValue'} = 0;
	
	$self->{'GUI'}{'BooleanFrame'} = $self->{'GUI'}{'TypeFrame'}->Frame(-height=>100, -width=>300);
	$self->{'GUI'}{'BooleanCVFrame'} = $self->{'GUI'}{'BooleanFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{'BooleanVFrame'} = $self->{'GUI'}{'BooleanFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	
	$self->{'GUI'}{'BooleanCVFrame'}->Label(-text=>'Current Value: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left');
	$self->{'GUI'}{'BooleanCVFrame'}->Label(-textvariable=>\$self->{'Data'}{'BCurrentValue'})->pack(-side=>'left', -padx=>15);
	
	$self->{'GUI'}{'BooleanVFrame'}->Label(-text=>'New Value: ', -width=>15, -anchor=>'w')->pack(-side=>'left');
	$self->{'GUI'}{'BooleanVFrame'}->Checkbutton(-indicatoron=>1, -onvalue=>1, -offvalue=>0, -variable=>\$self->{'Data'}{'BValue'}, -width=>4)->pack(-side=>'left');
	$self->{'GUI'}{'BooleanVFrame'}->Button(-text=>'Assign', -command=>sub { if($self->{'Data'}{'BValue'} == 1) { $self->{'Data'}{'BCurrentValue'} = 'TRUE'; } else { $self->{'Data'}{'BCurrentValue'} = 'FALSE'; } KSE::Functions::Globals::SetGlobalValue($self->{'Data'}{'Variable'}, 'Boolean', $self->{'Data'}{'BValue'}); }, -width=>5)->pack(-side=>'left', -padx=>15);
	KSE::GUI::Main::SetResourceProgress(55);
	
	KSE::GUI::Main::SetResourceStep('Creating Global Variable string/text layout.');
	# String Frame
	$self->{'Data'}{'SValue'} = '';
	
	$self->{'GUI'}{'StringFrame'} = $self->{'GUI'}{'TypeFrame'}->Frame(-height=>100, -width=>300);
	$self->{'GUI'}{'StringCVFrame'} = $self->{'GUI'}{'StringFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{'StringVFrame'} = $self->{'GUI'}{'StringFrame'}->Frame(-height=>100, -width=>400)->pack(-fill=>'x', -padx=>5, -pady=>5);
	
	$self->{'GUI'}{'StringCVFrame'}->Label(-text=>'Current Value: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left');
	$self->{'GUI'}{'StringCVFrame'}->Label(-textvariable=>\$self->{'Data'}{'SCurrentValue'})->pack(-side=>'left', -padx=>15);
	
	$self->{'GUI'}{'StringVFrame'}->Label(-text=>'New Value: ', -width=>15, -anchor=>'w')->pack(-side=>'left');
	$self->{'GUI'}{'StringVFrame'}->Entry(-width=>20, -textvariable=>\$self->{'Data'}{'SValue'})->pack(-side=>'left', -padx=>15);
	$self->{'GUI'}{'StringVFrame'}->Button(-text=>'Assign', -command=>sub { $self->{'Data'}{'SCurrentValue'} = $self->{'Data'}{'SValue'}; KSE::Functions::Globals::SetGlobalValue($self->{'Data'}{'Variable'}, 'String', $self->{'Data'}{'SValue'}); }, -width=>5)->pack(-side=>'left', -padx=>15);	
	KSE::GUI::Main::SetResourceProgress(70);
	
	KSE::GUI::Main::SetResourceStep('Creating Global Variable Location layout.');
	# Location Frame
	# Locations are a bulk binary data section in the 'GLOBALVARS.RES' file.
	# Each Location is a 48-byte chunk, with the bytes as follows:
	# (Each is a 32-bit (4-byte) floating point value in IEEE Std 754-1985 format.)
	# X-Coord
	# Y-Coord
	# Z-Coord
	# X-Orientation		THIS IS A RADIAN
	# X-Orientation		THIS IS A RADIAN
	# 28 NULL (\000) Bytes
	$self->{'Data'}{'LValueX'} = 0.0;
	$self->{'Data'}{'LValueY'} = 0.0;
	$self->{'Data'}{'LValueZ'} = 0.0;
	$self->{'Data'}{'LValueFace'} = 0.0;
	
	$self->{'GUI'}{'LocationFrame'}		= $self->{'GUI'}{'TypeFrame'}->Frame(-height=>100, -width=>300);
	$self->{'GUI'}{'LocationCVFrame'}	= $self->{'GUI'}{'LocationFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{'LocationVFrame'}	= $self->{'GUI'}{'LocationFrame'}->Frame(-height=>100, -width=>300)->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{'LocationVFrame1'} = $self->{'GUI'}{'LocationVFrame'}->Frame(-height=>100, -width=>300)->pack(-side=>'left', -padx=>1, -pady=>5);
	$self->{'GUI'}{'LocationVFrame2'} = $self->{'GUI'}{'LocationVFrame'}->Frame(-height=>100, -width=>300)->pack(-side=>'left', -padx=>1, -pady=>5);
	$self->{'GUI'}{'LocationVFrame3'} = $self->{'GUI'}{'LocationVFrame'}->Frame(-height=>100, -width=>300)->pack(-side=>'left', -padx=>1, -pady=>5);
	$self->{'GUI'}{'LocationVFrame4'} = $self->{'GUI'}{'LocationVFrame'}->Frame(-height=>100, -width=>300)->pack(-side=>'left', -padx=>1, -pady=>5);
	
	$self->{'GUI'}{'LocationCVFrame'}->Label(-text=>'Current Value: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-padx=>15);
	$self->{'GUI'}{'LocationCVFrame'}->Label(-textvariable=>\$self->{'Data'}{'LCurrentValue'})->pack(-fill=>'x', -padx=>15);
	$self->{'GUI'}{'LocationCVFrame'}->Label(-text=>"    X\t    Y\t    Z\tFacing", -width=>30)->pack(-fill=>'x', -padx=>15);
	#-text=>'New Value: ')->pack(-side=>'left');
	
	$self->{'GUI'}{'LocationVFrame1'}->Label(-text=>'X', -width=>4)->pack(-side=>'left');
	$self->{'GUI'}{'LocationVFrame1'}->Spinbox(-from=>-1000.0, -to=>1000.0, -increment=>1.0, -format=>"%0.4f", -textvariable=>\$self->{'Data'}{'LValueX'}, -width=>4)->pack(-side=>'left');

	$self->{'GUI'}{'LocationVFrame2'}->Label(-text=>'Y', -width=>4)->pack(-side=>'left');
	$self->{'GUI'}{'LocationVFrame2'}->Spinbox(-from=>-1000.0, -to=>1000.0, -increment=>1.0, -format=>"%0.4f", -textvariable=>\$self->{'Data'}{'LValueY'}, -width=>4)->pack(-side=>'left');

	$self->{'GUI'}{'LocationVFrame3'}->Label(-text=>'Z', -width=>4)->pack(-side=>'left');
	$self->{'GUI'}{'LocationVFrame3'}->Spinbox(-from=>-1000.0, -to=>1000.0, -increment=>1.0, -format=>"%0.4f", -textvariable=>\$self->{'Data'}{'LValueZ'}, -width=>4)->pack(-side=>'left');

	$self->{'GUI'}{'LocationVFrame4'}->Label(-text=>'Orientation', -width=>10)->pack(-side=>'left');
	$self->{'GUI'}{'LocationVFrame4'}->Spinbox(-from=>0.0, -to=>359.9, -increment=>1.0, -format=>"%0.4f", -textvariable=>\$self->{'Data'}{'LValueFace'}, -width=>4)->pack(-side=>'left');
	
	$self->{'GUI'}{'LocationFrame'}->Button(-text=>'Assign', -command=>sub { $self->{'Data'}{'LCurrentValue'} = $self->{'Data'}{'LValueX'} . "\t" . $self->{'Data'}{'LValueY'} . "\t" . $self->{'Data'}{'LValueZ'} . "\t" . $self->{'Data'}{'LValueFace'}; KSE::Functions::Globals::SetGlobalValue($self->{'Data'}{'Variable'}, 'Location', [$self->{'Data'}{'LValueX'}, $self->{'Data'}{'LValueY'}, $self->{'Data'}{'LValueZ'}, $self->{'Data'}{'LValueFace'}]); }, -width=>5)->pack(-padx=>10);
	
	KSE::GUI::Main::SetResourceProgress(85);
	############
	
	KSE::GUI::Main::SetResourceStep('Creating Global Variable list interface.');
	# Global List
	$self->{'GUI'}{'canScroll'} = 0;
	$self->{'GUI'}{'GlobalList'} = $self->{'GUI'}{'FrameR'}->Scrolled('Listbox', -scrollbars=>'oe', -height=>25, -width=>50, -background=>'white', -selectborderwidth=>'0', -selectforeground=>'#FFFFFF', -selectbackground=>'#009000', -selectmode=>'browse')->pack(-fill=>'both', -padx=>5, -pady=>5);
	$self->{'GUI'}{'GlobalList'}->bind('<<ListboxSelect>>'=>sub { $self->SelectGlobal(); } );
#	$self->{'GUI'}{'GlobalList'}->bind('<MouseWheel>' =>[sub{ print "D is $_[0]\n"; $self->{'GUI'}{'GlobalList'}->yview('scroll', -($_[1] / 120) * 3, 'units'); }, Ev('D')]);
#	$self->{'GUI'}{'GlobalList'}->bind('<Leave>' => sub{$self->{'GUI'}{'canScroll'} = 0; print "leaving\n";});
#	$self->{'GUI'}{'GlobalList'}->bind('<Enter>' => sub{$self->{'GUI'}{'canScroll'} = 1; print "entering\n"; });

	$self->{'GUI'}{'GlobalList'}->bind('<KeyPress-Up>'=>[\&MoveList, 'Up']);
	$self->{'GUI'}{'GlobalList'}->bind('<KeyPress-Down>'=>[\&MoveList, 'Down']);
	
	RefreshEntries($self);
}

sub MoveList
{
	print "Arguments:\n\t";
	print join "\n\t", @_;
	print "\n";
	my ($widget, $direction) = @_;
	
	if($direction eq 'Up')
	{
		$self->{'GUI'}{'GlobalList'}->activate(($self->{'GUI'}{'GlobalList'}->curselection)[0] - 1);
	}
	else
	{
		$self->{'GUI'}{'GlobalList'}->activate(($self->{'GUI'}{'GlobalList'}->curselection)[0] + 1);
	}
}

sub RefreshEntries
{
	my $self = shift;
	
	$self->HideFrames();
	$self->ShowFrame($self->{'Data'}{'Type'});
	
	$self->{'GUI'}{'GlobalList'}->delete(0, 'end');
	
	foreach my $entry (KSE::Functions::Globals::GetGlobals($self->{'Data'}{'Type'}))
	{
		$self->{'GUI'}{'GlobalList'}->insert('end', $entry);
	}
	
	$self->SelectGlobal(0);
}

sub SelectGlobal
{
	my $self	= shift;
	my $other	= shift;
	
	if(defined($other) == 0)
	{
		$self->{'Data'}{'Variable'} = $self->{'GUI'}{'GlobalList'}->get(($self->{'GUI'}{'GlobalList'}->curselection)[0]);
	}
	else
	{
		$self->{'Data'}{'Variable'} = $self->{'GUI'}{'GlobalList'}->get($other);
	}
	
	if($self->{'Data'}{'Type'} eq 'Number')
	{
		$self->{'Data'}{'NCurrentValue'} = KSE::Functions::Globals::GetGlobalValue($self->{'Data'}{'Variable'}, 'Number');
	}
	elsif($self->{'Data'}{'Type'} eq 'Boolean')
	{
		$self->{'Data'}{'BCurrentValue'} = KSE::Functions::Globals::GetGlobalValue($self->{'Data'}{'Variable'}, 'Boolean');
		
		if($self->{'Data'}{'BCurrentValue'} == 0)	{ $self->{'Data'}{'BCurrentValue'} = 'FALSE';	}
		else										{ $self->{'Data'}{'BCurrentValue'} = 'TRUE';	}
	}
	elsif($self->{'Data'}{'Type'} eq 'String')
	{
		$self->{'Data'}{'SCurrentValue'} = KSE::Functions::Globals::GetGlobalValue($self->{'Data'}{'Variable'}, 'String');
	}
	else
	{
	#	print "Location pieces: " . KSE::Functions::Globals::GetGlobalValue($self->{'Data'}{'Variable'}, 'Location') . "\n";
		my $location = KSE::Functions::Globals::GetGlobalValue($self->{'Data'}{'Variable'}, 'Location');
		my @pieces = @$location;
		$self->{'Data'}{'LCurrentValue'} = $pieces[0] . "\t" . $pieces[1] . "\t" . $pieces[2] . "\t" . $pieces[3];
	}
}

sub HideFrames
{
	my $self = shift;
	
	foreach('Number', 'Boolean', 'String', 'Location')
	{
		$self->{'GUI'}{$_ . 'Frame'}->packForget();
	}
}

sub ShowFrame
{
	my ($self, $frame) = @_;
	
	$self->{'GUI'}{$frame . 'Frame'}->pack(-fill=>'x', -padx=>5, -pady=>5);
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